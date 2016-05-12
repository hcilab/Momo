interface IEmgManager {
  void calibrate();
  HashMap<String, Float> poll();
  void onEmg(long nowMillis, int[] sensorData);
}


// Ensuring that only a single myo is ever instantiated is essential. Each myo
// instance requires a significant amount of computation, and having multiple
// instances creates a performance impact on gameplay.
//
// TODO: this is a hack. These methods should really be contained within a
// static class, but Processing is making it very hard to do so.
Myo myoSingleton = null;

Myo getMyoSingleton() throws MyoNotConnectedException {
  if (myoSingleton == null) {
    try {
      myoSingleton = new Myo(mainObject);
    } catch (RuntimeException e) {
      throw new MyoNotConnectedException();
    }
    myoSingleton.withEmg();
  }
  return myoSingleton;
}

class MyoNotConnectedException extends Exception {}
// ================================================================================


class EmgManager implements IEmgManager {
  Myo myo_unused;
  MyoAPI myoAPI;
  String SETTINGS_EMG_CONTROL_POLICY;
  boolean calibrated;

  EmgManager() throws MyoNotConnectedException {
    // not directly needed here, just need to make one in instantiated
    myo_unused = getMyoSingleton();

    myoAPI = new MyoAPI();
    SETTINGS_EMG_CONTROL_POLICY = "DIFF";
    calibrated = false;
  }

  void calibrate() {
    Event event;
    try {
      println("Left:");
      myoAPI.registerAction("LEFT", 5000);
      println("Right:");
      myoAPI.registerAction("RIGHT", 5000);
    } catch (CalibrationFailedException e) {
      println("[WARNING] No EMG activity detected. Aborting Calibration.");
      event = new Event(EventType.CALIBRATE_FAILURE);
      eventManager.queueEvent(event);
      return;
    }
    calibrated = true;
    event = new Event(EventType.CALIBRATE_SUCCESS);
    eventManager.queueEvent(event);
  }

  HashMap<String, Float> poll() {
    assert(calibrated);

    HashMap<String, Float> readings = myoAPI.poll();
    Float left = readings.get("LEFT");
    Float right = readings.get("RIGHT");
    Float jump = (readings.get("LEFT") > 0.8 && readings.get("RIGHT") > 0.8) ?  1.0 : 0.0;

    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    toReturn.put("JUMP", jump);
    switch (SETTINGS_EMG_CONTROL_POLICY) {
      case "DIFF":
        if (left > right) {
          toReturn.put("LEFT", left-right);
          toReturn.put("RIGHT", 0.0);
        } else {
          toReturn.put("RIGHT", right-left);
          toReturn.put("LEFT", 0.0);
        }
        break;

      case "MAX":
        if (left > right) {
          toReturn.put("LEFT", left);
          toReturn.put("RIGHT", 0.0);
        } else {
          toReturn.put("RIGHT", right);
          toReturn.put("LEFT", 0.0);
        }
        break;
    }
    return toReturn;
  }

  void onEmg(long nowMillis, int[] sensorData) {
    myoAPI.onEmg(nowMillis, sensorData);
  }
}


class NullEmgManager implements IEmgManager {

  void calibrate() {
    println("[WARNING] No myo armband detected. Aborting calibration");
    Event event = new Event(EventType.CALIBRATE_FAILURE);
    eventManager.queueEvent(event);
  }

  HashMap<String, Float> poll() {
    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    toReturn.put("LEFT", 0.0);
    toReturn.put("RIGHT", 0.0);
    toReturn.put("JUMP", 0.0);
    return toReturn;
  }

  void onEmg(long nowMillis, int[] sensorData) {} // no-op
}
