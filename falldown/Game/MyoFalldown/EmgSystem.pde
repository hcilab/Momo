interface IEmgManager {
  boolean registerAction(String label);
  boolean registerActionManual(String label, int sensorID, int maxReading);
  HashMap<String, Float> poll();
  HashMap<String, Float> pollIgnoringControlStrategy();
  HashMap<String, Float> pollRaw();
  boolean isCalibrated();
  void updateRegisteredSensorValues(String directionLabel, float sliderValue);
}


class EmgManager implements IEmgManager {
  MyoAPI myoAPI;

  float firstOver_threshold;
  boolean firstOver_leftOver;
  boolean firstOver_rightOver;

  EmgManager() throws MyoNotDetectectedError {
    myoAPI = getMyoApiSingleton();

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

  boolean registerActionManual(String label, int sensorID, int maxReading)
  {
    try {
      myoAPI.registerActionManual(label, sensorID, maxReading);
    } catch (CalibrationFailedException e) {
      return false;
    }
    return true;
  }

  /*
  * Returns sensor readings that are normalized to current sensitivity settings,
  * restricted to the range [0.0, 1.0], and processed using the current control
  * policy settings (i.e., DIFFERENCE, MAXIMUM, FIRST_OVER)
  */
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

  /*
  * Returns sensor readings that are normalized to current sensitivity
  * settings, restricted to the range [0.0, 1.0], but are not affected by the
  * current control policy settings (i.e., DIFFERENCE, MAXIMUM, FIRST_OVER)
  */
  HashMap<String, Float> pollIgnoringControlStrategy() {
    HashMap<String, Float> readings = myoAPI.poll();
    Float left = readings.get(LEFT_DIRECTION_LABEL);
    Float right = readings.get(RIGHT_DIRECTION_LABEL);

    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    toReturn.put(LEFT_DIRECTION_LABEL, left);
    toReturn.put(RIGHT_DIRECTION_LABEL, right);

    return toReturn;
  }

  /*
  * Returns sensor readings that are normalized to current sensitivity
  * settings, but are not restricted to a particular range (i.e., readings above
  * 1.0 are perfectly legal, and are not affected by the current control policy
  * settings (i.e., DIFFERENCE, MAXIMUM, FIRST_OVER)
  */
  HashMap<String, Float> pollRaw() {
    return myoAPI.pollRaw();
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

  boolean registerActionManual(String label, int sensorID, int maxReading) {
    return false;
  }

  HashMap<String, Float> poll() {
    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    toReturn.put(LEFT_DIRECTION_LABEL, 0.0);
    toReturn.put(RIGHT_DIRECTION_LABEL, 0.0);
    toReturn.put(JUMP_DIRECTION_LABEL, 0.0);
    return toReturn;
  }

  HashMap<String, Float> pollIgnoringControlStrategy() {
    return this.pollRaw();
  }

  HashMap<String, Float> pollRaw() {
    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    toReturn.put(LEFT_DIRECTION_LABEL, 0.0);
    toReturn.put(RIGHT_DIRECTION_LABEL, 0.0);
    return toReturn;
  }

  boolean isCalibrated() {
    return false;
  }

  void updateRegisteredSensorValues(String directionLabel, float sliderValue) {} // no-op
}