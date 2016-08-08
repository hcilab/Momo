interface IEmgManager {
  boolean registerAction(String label);
  HashMap<String, Float> poll();
  HashMap<String, Float> pollRaw();
  void onEmg(long nowMillis, int[] sensorData);
  boolean isCalibrated();
  void updateRegisteredSensorValues(String directionLabel, float sliderValue);
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

  float firstOver_threshold;
  boolean firstOver_leftOver;
  boolean firstOver_rightOver;

  EmgManager() throws MyoNotConnectedException {
    // not directly needed here, just need to make sure one is instantiated
    myo_unused = getMyoSingleton();
    myo_unused.withEmg();

    myoAPI = new MyoAPI();

    firstOver_threshold = options.getIOOptions().getMinInputThreshold();
    firstOver_leftOver = false;
    firstOver_rightOver = false;
  }

  boolean registerAction(String label) {
    Event event;

    try {
      if (calibrationMode == CalibrationMode.AUTO)
      {
        myoAPI.registerAction(label, 0);
      }
      else
      {
        if (label.equals(LEFT_DIRECTION_LABEL))
        {
          myoAPI.registerActionManual(label, leftSensor);
        }
        else
        {
          myoAPI.registerActionManual(label, rightSensor);
        }
      }

    } catch (CalibrationFailedException e) {
      return false;
    }
    return true;
  }

  HashMap<String, Float> poll() {
    HashMap<String, Float> readings = myoAPI.poll();
    Float left = readings.get(LEFT_DIRECTION_LABEL);
    Float right = readings.get(RIGHT_DIRECTION_LABEL);
    Float jump = (readings.get(LEFT_DIRECTION_LABEL) > 0.8 &&
    readings.get(RIGHT_DIRECTION_LABEL) > 0.8) ?  1.0 : 0.0;

    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    toReturn.put(JUMP_DIRECTION_LABEL, jump);

    EmgSamplingPolicy samplingPolicy = options.getIOOptions().getEmgSamplingPolicy();
    if (samplingPolicy == EmgSamplingPolicy.DIFFERENCE)
    {
      if (left > right) {
        toReturn.put(LEFT_DIRECTION_LABEL, left-right);
        toReturn.put(RIGHT_DIRECTION_LABEL, 0.0);
      } else {
        toReturn.put(RIGHT_DIRECTION_LABEL, right-left);
        toReturn.put(LEFT_DIRECTION_LABEL, 0.0);
      }
    }
    else if (samplingPolicy == EmgSamplingPolicy.MAX)
    {
      if (left > right) {
        toReturn.put(LEFT_DIRECTION_LABEL, left);
        toReturn.put(RIGHT_DIRECTION_LABEL, 0.0);
      } else {
        toReturn.put(RIGHT_DIRECTION_LABEL, right);
        toReturn.put(LEFT_DIRECTION_LABEL, 0.0);
      }
    }
    else if (samplingPolicy == EmgSamplingPolicy.FIRST_OVER)
    {
      if (firstOver_leftOver && left > firstOver_threshold)
      {
        toReturn.put(LEFT_DIRECTION_LABEL, left);
        toReturn.put(RIGHT_DIRECTION_LABEL, 0.0);
      }
      else if (firstOver_rightOver && right > firstOver_threshold)
      {
        toReturn.put(LEFT_DIRECTION_LABEL, 0.0);
        toReturn.put(RIGHT_DIRECTION_LABEL, right);
      }
      else
      {
        firstOver_leftOver = false;
        firstOver_rightOver = false;

        if (left > right && left > firstOver_threshold)
        {
          firstOver_leftOver = true;
          toReturn.put(LEFT_DIRECTION_LABEL, left);
          toReturn.put(RIGHT_DIRECTION_LABEL, 0.0);
        }
        else if (right > left && right > firstOver_threshold)
        {
          firstOver_rightOver = true;
          toReturn.put(LEFT_DIRECTION_LABEL, 0.0);
          toReturn.put(RIGHT_DIRECTION_LABEL, right);
        }
        else
        {
          toReturn.put(LEFT_DIRECTION_LABEL, 0.0);
          toReturn.put(RIGHT_DIRECTION_LABEL, 0.0);
        }
      }
    }
    else
    {
      println("[ERROR] Unrecognized emg sampling policy in EmgManager::poll()");
    }
    return toReturn;
  }

  HashMap<String, Float> pollRaw() {
    HashMap<String, Float> readings = myoAPI.poll();
    Float left = readings.get(LEFT_DIRECTION_LABEL);
    Float right = readings.get(RIGHT_DIRECTION_LABEL);

    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    toReturn.put(LEFT_DIRECTION_LABEL, left);
    toReturn.put(RIGHT_DIRECTION_LABEL, right);

    return toReturn;
  }

  void onEmg(long nowMillis, int[] sensorData) {
    myoAPI.onEmg(nowMillis, sensorData);
  }
  
  boolean isCalibrated() {
    return true;
  }

  void updateRegisteredSensorValues(String directionLabel, float sliderValue) {
    myoAPI.updateRegisteredSensorValues(directionLabel, sliderValue);
  }
}


class NullEmgManager implements IEmgManager {

  boolean registerAction(String label) {
    return false;
  }

  HashMap<String, Float> poll() {
    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    toReturn.put(LEFT_DIRECTION_LABEL, 0.0);
    toReturn.put(RIGHT_DIRECTION_LABEL, 0.0);
    toReturn.put(JUMP_DIRECTION_LABEL, 0.0);
    return toReturn;
  }

  HashMap<String, Float> pollRaw() {
    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    toReturn.put(LEFT_DIRECTION_LABEL, 0.0);
    toReturn.put(RIGHT_DIRECTION_LABEL, 0.0);
    return toReturn;
  }

  void onEmg(long nowMillis, int[] sensorData) {} // no-op
  
  boolean isCalibrated() {
    return false;
  }

  void updateRegisteredSensorValues(String directionLabel, float sliderValue) {} // no-op
}