import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.Map;
import java.util.Map.Entry;

interface IMyoAPI {
  void registerAction(String label, int delayMillis) throws CalibrationFailedException;
  void registerActionManual(String label, int sensorID) throws CalibrationFailedException;
  void registerActionManual(String label, int sensorID, int maxReading) throws CalibrationFailedException;
  HashMap<String, Float> poll();
  HashMap<String, Float> pollRaw();
  void updateRegisteredSensorValues(String directionLabel, float sliderValue);
}

// Ensuring that only a single MyoAPI is ever instantiated is essential. Each
// instance requires a significant amount of computation to maintain the sample
// window, and having multiple instances creates a performance impact on
// gameplay.
//
// TODO: this is a hack. These methods should really be contained within a
// static class, but Processing is making it very hard to do so.
MyoAPI myoApiSingleton = null;

MyoAPI getMyoApiSingleton()  throws MyoNotDetectectedError {
  if (myoApiSingleton == null || !MYO_API_SUCCESSFULLY_INITIALIZED)
    myoApiSingleton = new MyoAPI();

  return myoApiSingleton;
}
// ================================================================================


class MyoAPI implements IMyoAPI {

  int NUM_SENSORS = 8;
  int MAX_MYO_READING = 127;

  HashMap<String, SensorConfig> registeredSensors;
  ConcurrentLinkedQueue<Sample> sampleWindow;


  MyoAPI(int windowSizeMillis) throws MyoNotDetectectedError {
    registeredSensors = new HashMap<String, SensorConfig>();
    sampleWindow = new ConcurrentLinkedQueue<Sample>();

    // fork a new thread to concurrently stream EMG data into sampleWindow
    Thread t = new Thread(new EmgCollector(sampleWindow, windowSizeMillis));
    t.start();

    MYO_API_SUCCESSFULLY_INITIALIZED = true;
  }

  MyoAPI() throws MyoNotDetectectedError {
    this(150); // default values
  }


  // define a query-able EMG position. Sensor ID and amplitude threshold is
  // calibrated based on the current EMG sensor readings. Calibration baselines
  // are captured <delayMillis> ms after invoking function.
  //
  void registerAction(String label, int delayMillis) throws CalibrationFailedException {
    int strongestID = -1;
    float strongestReading = 0;
    float mav = 0;

    sleep(delayMillis);

    Sample[] currentSamples = {};
    currentSamples = sampleWindow.toArray(currentSamples); // infers type-info
    for (int i=0; i<NUM_SENSORS; i++) {
      mav = meanAbsoluteValue(currentSamples, i);
      if (strongestReading < mav) {
        strongestReading = mav;
        strongestID = i;
      }
    }

    if (strongestID == -1 || strongestReading == 0) {
      throw new CalibrationFailedException();
    }

    SensorConfig s = new SensorConfig(strongestID, strongestReading);
    registeredSensors.put(label, s);
    println("Registered: "+label+" ["+s.sensorID+"] "+s.maxReading);
    HashMap<String, float[]> readingData = new HashMap<String, float[]>();
    readingData.put(label, new float[]{ s.sensorID, s.maxReading });
    options.getCalibrationData().setCalibrationData(readingData);
  }


  // Manually define a query-able EMG position. Amplitude threshold is left at
  // the default maximum. This function is useful for debugging/testing, but
  // could later provide a hook for user-specified settings.
  //
  void registerActionManual(String label, int sensorID) throws CalibrationFailedException {
    Sample[] currentSamples = {};
    currentSamples = sampleWindow.toArray(currentSamples); // infers type-info
    float mav = meanAbsoluteValue(currentSamples, sensorID);

    if (!(mav > 0)) {
      throw new CalibrationFailedException();
    }

    SensorConfig s = new SensorConfig(sensorID, mav);
    registeredSensors.put(label, s);
    println("Registered: "+label+" ["+s.sensorID+"] "+s.maxReading);
    HashMap<String, float[]> readingData = new HashMap<String, float[]>();
    readingData.put(label, new float[]{ s.sensorID, s.maxReading });
    options.getCalibrationData().setCalibrationData(readingData);
  }

  void registerActionManual(String label, int sensorID, int maxReading) throws CalibrationFailedException
  {
    SensorConfig s = new SensorConfig(sensorID, maxReading);
    registeredSensors.put(label, s);
    println("Registered: "+label+" ["+s.sensorID+"] "+s.maxReading);
    HashMap<String, float[]> readingData = new HashMap<String, float[]>();
    readingData.put(label, new float[]{ s.sensorID, s.maxReading });
    options.getCalibrationData().setCalibrationData(readingData);
  }


  // Query current EMG sensor readings. Mean-Absolute-Value is taken over
  // currently buffered window, and results are normalized using current
  // sensitivity settings (i.e., maxReading) and restricted to the range [0, 1].
  //
  // Returns:
  //   HashMap<k, v> where:
  //     - k : previously registed label (through registerAction())
  //     - v : normalized sensor reading (range [0, 1])
  //
  HashMap<String, Float> poll() {
    HashMap<String, Float> rawReadings = this.pollRaw();

    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    for (String k : rawReadings.keySet()) {
      toReturn.put(k, min(rawReadings.get(k), 1.0));
    }
    return toReturn;
  }


  // Query current EMG sensor readings. Mean-Absolute-Value is taken over
  // currently buffered window, results are normalized to current sensitivity
  // settings (i.e., maxReading), but no restrictions are applied to the range
  // of readings (i.e., readings above 1.0 can occur)
  //
  // Returns:
  //   HashMap<k, v> where:
  //     - k : previously registed label (through registerAction())
  //     - v : sensor reading
  //
  HashMap<String, Float> pollRaw() {
    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    String label;
    int sensorID;
    float maxReading;
    float result;

    Sample[] currentSamples = {};
    currentSamples = sampleWindow.toArray(currentSamples);
    for (Map.Entry<String, SensorConfig> entry : registeredSensors.entrySet()) {
      label = entry.getKey();
      sensorID = entry.getValue().sensorID;
      maxReading = entry.getValue().maxReading;

      result = meanAbsoluteValue(currentSamples, sensorID);
      result /= maxReading; // normalize

      toReturn.put(label, new Float(result));

    }
    return toReturn;
  }


  private void sleep(int milliseconds) {
    int now = millis();
    while (millis() < now+milliseconds) {} // spin
  }

  private float meanAbsoluteValue(Sample[] samples, int sensorID) {
    float mav = 0;
    for (int i=0; i<samples.length; i++) {
      mav += abs(samples[i].sensorData[sensorID]);
    }
    mav /= samples.length;
    return mav;
  }

  void updateRegisteredSensorValues(String directionLabel, float sliderValue) {
    int sensor = registeredSensors.get(directionLabel).sensorID;
    registeredSensors.put(directionLabel, new SensorConfig(sensor, sliderValue));
  }
}


private class EmgCollector implements Runnable {
  MyoEMG myoEmg;
  ConcurrentLinkedQueue<Sample> sampleWindow;
  long windowSizeMillis;

  public EmgCollector(ConcurrentLinkedQueue<Sample> sampleWindow, long windowSizeMillis) throws MyoNotDetectectedError {
    this.myoEmg = new MyoEMG(mainObject);
    this.sampleWindow = sampleWindow;
    this.windowSizeMillis = windowSizeMillis;
  }

  public void run() {
    while (true) {
      // insert new reading
      Sample s = myoEmg.readSample();
      sampleWindow.add(s);

      // maintain window
      Sample first = sampleWindow.peek();
      while (first!=null && s.timestamp > first.timestamp+windowSizeMillis)
        first = sampleWindow.poll();
    }
  }
}


private class SensorConfig {
  public int sensorID;
  public float maxReading;

  SensorConfig(int id, float maxReading) {
    this.sensorID = id;
    this.maxReading = maxReading;
  }
}

class CalibrationFailedException extends Exception {}
