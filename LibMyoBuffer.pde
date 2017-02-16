import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.Map;
import java.util.Map.Entry;


class LibMyoBuffer {
  public final int NUM_SENSORS = 8;
  public final int MAX_MYO_READING = 127;

  ConcurrentLinkedQueue<Sample> sampleWindow;


  LibMyoBuffer(PApplet mainObject) throws MyoNotDetectectedError {
    this(mainObject, 150);
  }

  LibMyoBuffer(PApplet mainObject, int windowSizeMillis) throws MyoNotDetectectedError {
    sampleWindow = new ConcurrentLinkedQueue<Sample>();

    // fork a new thread to concurrently stream EMG data into sampleWindow
    Thread t = new Thread(new EmgCollector(mainObject, sampleWindow, windowSizeMillis));
    t.start();
  }


  // Returns an 8-element array of integers in the range [0, 1], representing
  // the MAV of the 8 armband sensors within the current sample window.
  //
  public float[] poll() {
    Sample[] windowSnapshot = {};
    windowSnapshot = sampleWindow.toArray(windowSnapshot);

    float[] toReturn = new float[NUM_SENSORS];
    for (int i=0; i<NUM_SENSORS; i++) {
      toReturn[i] = meanAbsoluteValue(windowSnapshot, i) / MAX_MYO_READING;
    }
    return toReturn;
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


private class EmgCollector implements Runnable {
  LibMyoStream myoStream;
  ConcurrentLinkedQueue<Sample> sampleWindow;
  long windowSizeMillis;

  public EmgCollector(PApplet mainObject, ConcurrentLinkedQueue<Sample> sampleWindow, long windowSizeMillis) throws MyoNotDetectectedError {
    this.myoStream = new LibMyoStream(mainObject);
    this.sampleWindow = sampleWindow;
    this.windowSizeMillis = windowSizeMillis;
  }

  public void run() {
    while (true) {
      // insert new reading
      Sample s = myoStream.readSample();
      sampleWindow.add(s);

      // maintain window
      Sample first = sampleWindow.peek();
      while (first!=null && s.timestamp > first.timestamp+windowSizeMillis)
        first = sampleWindow.poll();
    }
  }
}
