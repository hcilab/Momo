interface IEmgManager {
  boolean registerAction(String action);
  boolean registerAction(String action, int sensorID);

  boolean loadCalibration(String calibrationFile);
  void saveCalibration(String calibrationFile);

  void setSensitivity(String action, float value);
  void setMinimumActivationThreshold(String action, float value);

  int getSensor(String action);
  float getSensitivity(String action);
  float getMinimumActivationThreshold(String action);
  boolean isCalibrated();

  HashMap<String, Float> poll();
  HashMap<String, Float> pollIgnoringControlStrategy();
  HashMap<String, Float> pollRaw();

  // TODO Should I only capture EMG data during gameplay?
  void startEmgLogging();
  void stopEmgLogging();
}


class EmgManager implements IEmgManager {
  LibMyoProportional myoProportional;

  EmgManager() throws MyoNotDetectectedError {
    myoProportional = new LibMyoProportional(mainObject);
  }

  boolean registerAction(String action) {
    try {
      myoProportional.registerAction(string2Action(action));
    } catch (CalibrationFailedException e) {
      return false;
    }
    return true;
  }

  boolean registerAction(String label, int sensorID)
  {
    try {
      myoProportional.registerAction(string2Action(label), sensorID);
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
    EmgSamplingPolicy p = options.getIOOptions().getEmgSamplingPolicy();
    HashMap<Action, Float> results = myoProportional.pollAndTrim(emgSamplingPolicy2Policy(p));

    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    for (Action a : results.keySet()) {
      toReturn.put(action2String(a), results.get(a));
    }
    return toReturn;
  }

  /*
  * Returns sensor readings that are normalized to current sensitivity
  * settings, restricted to the range [0.0, 1.0], but are not affected by the
  * current control policy settings (i.e., DIFFERENCE, MAXIMUM, FIRST_OVER)
  */
  HashMap<String, Float> pollIgnoringControlStrategy() {
    HashMap<Action, Float> results = myoProportional.pollAndTrim(Policy.RAW);

    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    for (Action a : results.keySet()) {
      toReturn.put(action2String(a), results.get(a));
    }
    return toReturn;
  }

  /*
  * Returns sensor readings that are normalized to current sensitivity
  * settings, but are not restricted to a particular range (i.e., readings above
  * 1.0 are perfectly legal, and are not affected by the current control policy
  * settings (i.e., DIFFERENCE, MAXIMUM, FIRST_OVER)
  */
  HashMap<String, Float> pollRaw() {
    HashMap<Action, Float> results = myoProportional.poll(Policy.RAW);

    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    for (Action a : results.keySet()) {
      toReturn.put(action2String(a), results.get(a));
    }
    return toReturn;
  }
  
  boolean isCalibrated() {
    return myoProportional.isCalibrated();
  }

  boolean loadCalibration(String calibrationFile)  {
    if (!fileExists(calibrationFile))
      return false;

    try {
      myoProportional.loadCalibrationSettings(calibrationFile);
    } catch (CalibrationFailedException e) {
      return false;
    }
    return true;
  }

  void saveCalibration(String calibrationFile) {
    myoProportional.writeCalibrationSettings(calibrationFile);
  }

  void setSensitivity(String action, float value) {
    // should this be the inverse?
    myoProportional.setSensitivity(string2Action(action), value);
  }

  void setMinimumActivationThreshold(String action, float value) {
    myoProportional.setMinimumActivationThreshold(string2Action(action), value);
  }

  int getSensor(String action) {
    Map<Action, SensorConfig> sensorConfigs = myoProportional.getCalibrationSettings();
    return sensorConfigs.get(string2Action(action)).sensorID;
  }

  float getSensitivity(String action) {
    // should this be the inverse?
    Map<Action, SensorConfig> sensorConfigs = myoProportional.getCalibrationSettings();
    return sensorConfigs.get(string2Action(action)).maxReading;
  }

  float getMinimumActivationThreshold(String action) {
    Map<Action, SensorConfig> sensorConfigs = myoProportional.getCalibrationSettings();
    return sensorConfigs.get(string2Action(action)).minimumActivationThreshold;
  }

  void startEmgLogging() {
    myoProportional.enableEmgLogging("emg.csv");
  }

  void stopEmgLogging() {
    myoProportional.disableEmgLogging();
  }

  private Policy emgSamplingPolicy2Policy(EmgSamplingPolicy policy) {
    switch (policy) {
      case MAX: return Policy.MAXIMUM;
      case DIFFERENCE: return Policy.DIFFERENCE;
      case FIRST_OVER: return Policy.FIRST_OVER;
      default: return Policy.RAW;
    }
  }

  private Action string2Action(String s) {
    switch (s) {
      case LEFT_DIRECTION_LABEL: return Action.LEFT;
      case RIGHT_DIRECTION_LABEL: return Action.RIGHT;
      case JUMP_DIRECTION_LABEL: return Action.IMPULSE;

      // TODO
      default: return Action.LEFT;
    }
  }

  private String action2String(Action a) {
    switch (a) {
      case LEFT: return LEFT_DIRECTION_LABEL;
      case RIGHT: return RIGHT_DIRECTION_LABEL;
      case IMPULSE: return JUMP_DIRECTION_LABEL;

      // TODO
      default: return LEFT_DIRECTION_LABEL;
    }
  }

  private boolean fileExists(String filename) {
    File file = new File("data/" + filename);
    return file.exists();
  }
}


class NullEmgManager implements IEmgManager {

  boolean registerAction(String label) {
    return false;
  }

  boolean registerAction(String label, int sensorID) {
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
    return poll();
  }

  HashMap<String, Float> pollRaw() {
    return poll();
  }

  boolean isCalibrated() {
    return false;
  }

  boolean loadCalibration(String calibrationFile) {
    return false;
  }

  void saveCalibration(String calibrationFile) {} // no-op
  void setSensitivity(String action, float value) {} // no-op
  void setMinimumActivationThreshold(String action, float value) {} // no-op

  int getSensor(String action) {
    return 0;
  }

  float getSensitivity(String action) {
    return 0.0;
  }

  float getMinimumActivationThreshold(String action) {
    return 0.0;
  }

  void startEmgLogging() {} // no-op
  void stopEmgLogging() {} // no-op
}
