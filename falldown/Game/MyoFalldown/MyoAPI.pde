import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.Map;
import java.util.Map.Entry;

interface IMyoAPI {
  void registerAction(String label, int delayMillis) throws CalibrationFailedException;
  void registerActionManual(String label, int sensorID);
  HashMap<String, Float> poll();
  void onEmg(long nowMicros, int[] sensorData);
}


class MyoAPI implements IMyoAPI {

  int NUM_SENSORS = 8;
  int MAX_MYO_READING = 127;

  int windowSizeMicros;
  int windowIncrementSizeMicros;

  HashMap<String, SensorConfig> registeredSensors;
  ConcurrentLinkedQueue<Sample> sampleWindow;


  MyoAPI(int windowSizeMicros, int windowIncrementSizeMicros) {
    this.windowSizeMicros = windowSizeMicros;
    this.windowIncrementSizeMicros = windowIncrementSizeMicros;
    registeredSensors = new HashMap<String, SensorConfig>();
    sampleWindow = new ConcurrentLinkedQueue<Sample>();
  }

  MyoAPI() {
    this(150000, 1000); // default values
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
  void registerActionManual(String label, int sensorID) {
    SensorConfig s = new SensorConfig(sensorID, MAX_MYO_READING);
    registeredSensors.put(label, s);
    println("Registered: "+label+" ["+s.sensorID+"] "+s.maxReading);
  }


  // Query current EMG sensor readings. Mean-Absolute-Value is taken over
  // currently buffered window, and results are normalized to the range [0, 1].
  //
  // Returns:
  //   HashMap<k, v> where:
  //     - k : previously registed label (through registerAction())
  //     - v : normalized sensor reading (range [0, 1])
  //
  HashMap<String, Float> poll() {
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
      result = min(result, 1.0); // cut-off if above threshold

      toReturn.put(label, new Float(result));

    }
    return toReturn;
  }


  // Maintains a buffered window of the most recent EMG sensor readings.
  //
  // Acts as hook-point to attach to the asychronous EMG signal handling coming
  // from the host application. Host application should call similar to:
  //   void myoOnEmg(Myo myo, long timestamp, int[] data) {
  //     api.onEmg(timestamp, data);
  //     ...
  //   }
  //
  void onEmg(long nowMicros, int[] sensorData) {
    Sample s = new Sample(nowMicros, sensorData.clone()); // create a local copy of sensor-data
    sampleWindow.add(s);
    Sample first = sampleWindow.peek();
    while (first!=null && nowMicros-first.timestampMicros > windowSizeMicros+windowIncrementSizeMicros) {
      first = sampleWindow.poll();
    }
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
}


private class SensorConfig {
  public int sensorID;
  public float maxReading;

  SensorConfig(int id, float maxReading) {
    this.sensorID = id;
    this.maxReading = maxReading;
  }
}

private class Sample {
  public long timestampMicros;
  public int[] sensorData;

  Sample(long timestampMicros, int[] sensorData) {
    this.timestampMicros = timestampMicros;
    this.sensorData = sensorData;
  }
}

class CalibrationFailedException extends Exception {}