import java.util.Map;

enum Action {LEFT, RIGHT, IMPULSE};
enum Policy {RAW, MAXIMUM, DIFFERENCE, FIRST_OVER};


/* This is a performance hack. Since the MyoBuffer asychronocously maintains a
 * buffered window of EMG readings, each instance requires a significant amount
 * of computation power. There is no need to duplicate this effort.
 *
 * This should really be a static method of the MyoBuffer class, but Processing
 * makes that difficult to do.
*/
private LibMyoBuffer myoBufferSingleton;
private LibMyoBuffer getMyoBufferSingleton(PApplet mainObject) throws MyoNotDetectectedError {
  if (myoBufferSingleton == null)
    myoBufferSingleton = new LibMyoBuffer(mainObject);

  return myoBufferSingleton;
}


class LibMyoProportional {
  private final float IMPULSE_THRESHOLD = 0.8;
  private final float FIRST_OVER_THRESHOLD = 0.5;
  private final float DEFAULT_MAT = 0.10;

  private LibMyoBuffer myoBuffer;
  private Map<Action, SensorConfig> registeredSensors;

  private boolean loggingEnabled;
  private String logfile;
  private ArrayList<EmgReading> emgReadings;

  // In the first-over control policy, the first action to surpass a threshold
  // is used as input. As long the amplitude of this action stays above the
  // threshold, the opposing action is ignored. This variable is used to
  // "remember" which action is currently being used for input.
  Action currentFirstOver;


  public LibMyoProportional(PApplet mainObject) throws MyoNotDetectectedError {
    myoBuffer = getMyoBufferSingleton(mainObject);
    registeredSensors = new HashMap<Action, SensorConfig>();
    emgReadings = new ArrayList<EmgReading>();
    disableEmgLogging();
  }

  public void writeCalibrationSettings(String calibrationFilename) {
    assert(isCalibrated());

    Table calibrationTable;
    if (!fileExists(calibrationFilename))
      calibrationTable = initializeCalibrationTable();
    else
      calibrationTable = loadTable(calibrationFilename, "header");

    TableRow newSettings = calibrationTable.addRow();
    newSettings.setInt("timestamp", int(System.currentTimeMillis()));
    newSettings.setInt("left_sensor", registeredSensors.get(Action.LEFT).sensorID);
    newSettings.setFloat("left_reading", registeredSensors.get(Action.LEFT).maxReading);
    newSettings.setFloat("left_mat", registeredSensors.get(Action.LEFT).minimumActivationThreshold);
    newSettings.setInt("right_sensor", registeredSensors.get(Action.RIGHT).sensorID);
    newSettings.setFloat("right_reading", registeredSensors.get(Action.RIGHT).maxReading);
    newSettings.setFloat("right_mat", registeredSensors.get(Action.RIGHT).minimumActivationThreshold);

    saveTable(calibrationTable, "data/" + calibrationFilename);
  }

  public void loadCalibrationSettings(String calibrationFilename) throws CalibrationFailedException {
    // TODO gracefully handle FileNotFound exception
    Table calibrationTable = loadTable(calibrationFilename, "header");
    TableRow calibrationSettings = calibrationTable.getRow(calibrationTable.getRowCount()-1);

    int leftSensorID = calibrationSettings.getInt("left_sensor");
    int rightSensorID = calibrationSettings.getInt("right_sensor");
    float leftSensorMaxReading = calibrationSettings.getFloat("left_reading");
    float rightSensorMaxReading = calibrationSettings.getFloat("right_reading");

    registerAction(Action.LEFT, leftSensorID, leftSensorMaxReading);
    registerAction(Action.RIGHT, rightSensorID, rightSensorMaxReading);
  }

  public SensorConfig registerAction(Action action) throws CalibrationFailedException {
    float[] readings = myoBuffer.poll();

    int strongestID = -1;
    float strongestReading = 0;
    for (int i=0; i<myoBuffer.NUM_SENSORS; i++) {
      if (readings[i] > strongestReading) {
        strongestReading = readings[i];
        strongestID = i;
      }
    }

    return registerAction(action, strongestID, strongestReading);
  }

  public SensorConfig registerAction(Action action, int sensorID) throws CalibrationFailedException {
    float[] readings = myoBuffer.poll();
    float sensorReading = readings[sensorID];

    return registerAction(action, sensorID, sensorReading);
  }

  public SensorConfig registerAction(Action action, int sensorID, float sensorReading) throws CalibrationFailedException {
    if (!isValidCalibration(sensorID, sensorReading, DEFAULT_MAT))
      throw new CalibrationFailedException();

    SensorConfig s = new SensorConfig(sensorID, sensorReading, DEFAULT_MAT);
    registeredSensors.put(action, s);
    return s;
  }

  public boolean isCalibrated() {
    return registeredSensors.containsKey(Action.LEFT) && registeredSensors.containsKey(Action.RIGHT);
  }

  public HashMap<Action, Float> pollAndTrim(Policy policy) {
    HashMap<Action, Float> toReturn = poll(policy);
    for (Action a : toReturn.keySet())
      toReturn.put(a, min(toReturn.get(a), 1.0));

    return toReturn;
  }

  public HashMap<Action, Float> poll(Policy policy) {
    assert(isCalibrated());

    // Step 1. acquire "raw" readings, calculating impulse before any further processing
    float[] readings = myoBuffer.poll();
    float left = readings[registeredSensors.get(Action.LEFT).sensorID] / registeredSensors.get(Action.LEFT).maxReading;
    float right = readings[registeredSensors.get(Action.RIGHT).sensorID] / registeredSensors.get(Action.RIGHT).maxReading;
    float impulse = left > IMPULSE_THRESHOLD && right > IMPULSE_THRESHOLD ? 1.0 : 0.0;

    if (loggingEnabled)
      emgReadings.add(new EmgReading(System.currentTimeMillis(), left, right, impulse));

    // Step 2. scale readings according to minimum activation threshold settings
    if (policy != Policy.RAW) {
      left = scale(left, registeredSensors.get(Action.LEFT).minimumActivationThreshold);
      right = scale(right, registeredSensors.get(Action.RIGHT).minimumActivationThreshold);
    }

    // Step 3. transform according to specified control policy
    switch (policy) {
      case RAW:
        break;

      case MAXIMUM:
        if (left < right)
          left = 0;
        else
          right = 0;
        break;

      case DIFFERENCE:
        left -= min(left, right);
        right -= min(left, right);
        break;

      case FIRST_OVER:
        if (currentFirstOver == Action.LEFT && left > FIRST_OVER_THRESHOLD) {
          right = 0;
        } else if (currentFirstOver == Action.RIGHT && right > FIRST_OVER_THRESHOLD) {
          left = 0;
        } else if (left > right && left > FIRST_OVER_THRESHOLD) {
          currentFirstOver = Action.LEFT;
          right = 0;
        } else if (right > left && right > FIRST_OVER_THRESHOLD) {
          currentFirstOver = Action.RIGHT;
          left = 0;
        } else {
          currentFirstOver = null;
          left = 0;
          right = 0;
        }
        break;
    }

    HashMap<Action, Float> toReturn = new HashMap<Action, Float>();
    toReturn.put(Action.LEFT, left);
    toReturn.put(Action.RIGHT, right);
    toReturn.put(Action.IMPULSE, impulse);
    return toReturn;
  }

  public Map<Action, SensorConfig> getCalibrationSettings() {
    // TODO this is a shallow copy (i.e., shared reference)
    return registeredSensors;
  }

  public void setSensitivity(Action action, float value) {
    SensorConfig s = registeredSensors.get(action);
    s.maxReading = value;
    assert(isValidCalibration(s));
  }

  public void setMinimumActivationThreshold(Action action, float value) {
    SensorConfig s = registeredSensors.get(action);
    s.minimumActivationThreshold = value;
    assert(isValidCalibration(s));
  }

  // The LibMyoProportional object can be configured to log all EMG data (one
  // row per poll() call) using this method. Note that you must explicitly call
  // flushEmgLog() in order for the data to be persisted (see below).
  public void enableEmgLogging(String logfile) {
    loggingEnabled = true;
    this.logfile = logfile;
  }

  // This is a performance hack... Since poll() is intended to be called at a
  // high frequency, logging to disk after each call would introduce a big
  // performance hit. Instead, the EMG log is buffered, and persisted on demand
  // by calling this method.
  public void flushEmgLog() {
    Table emgTable;
    if (!fileExists(logfile))
      emgTable = initializeEmgTable();
    else
      emgTable = loadTable(logfile, "header");

    for (EmgReading emgReading : emgReadings) {
      TableRow row = emgTable.addRow();
      row.setLong("tod", emgReading.tod);
      row.setFloat("left", emgReading.left);
      row.setFloat("right", emgReading.right);
      row.setFloat("impulse", emgReading.impulse);
    }

    saveTable(emgTable, "data/" + logfile);
    emgReadings.clear();
  }

  public void disableEmgLogging() {
    loggingEnabled = false;
    logfile = "";
  }

  private boolean isValidCalibration(SensorConfig s) {
    return isValidCalibration(s.sensorID, s.maxReading, s.minimumActivationThreshold);
  }

  private boolean isValidCalibration(int sensorID, float sensorReading, float mat) {
    return sensorID >= 0 && sensorID < myoBuffer.NUM_SENSORS && sensorReading >= 0.0 && sensorReading <= 1.0 && mat >= 0.0 && mat <= 1.0;
  }

  private float scale(float reading, float minimumActivationThreshold) {
    // scale the reading so that the remaining range of input (i.e., above the activationThreshold) results in the full range of movement speeds
    float scaledReading = (reading-minimumActivationThreshold) * (1.0/(1.0-minimumActivationThreshold));
    return max(scaledReading, 0.0);
  }

  private Table initializeCalibrationTable() {
    Table calibrationTable = new Table();
    calibrationTable.addColumn("timestamp");
    calibrationTable.addColumn("left_sensor");
    calibrationTable.addColumn("left_reading");
    calibrationTable.addColumn("left_mat");
    calibrationTable.addColumn("right_sensor");
    calibrationTable.addColumn("right_reading");
    calibrationTable.addColumn("right_mat");
    return calibrationTable;
  }

  private Table initializeEmgTable() {
    Table emgTable = new Table();
    emgTable.addColumn("tod");
    emgTable.addColumn("left");
    emgTable.addColumn("right");
    emgTable.addColumn("impulse");
    return emgTable;
  }

  private boolean fileExists(String filename) {
    File file = new File("data/" + filename);
    return file.exists();
  }
}


class SensorConfig {
  public int sensorID;
  public float maxReading;
  public float minimumActivationThreshold;

  SensorConfig(int id, float maxReading, float minimumActivationThreshold) {
    this.sensorID = id;
    this.maxReading = maxReading;
    this.minimumActivationThreshold = minimumActivationThreshold;
  }
}


class EmgReading {
  public long tod;
  public float left;
  public float right;
  public float impulse;

  EmgReading(long tod, float left, float right, float impulse) {
    this.tod = tod;
    this.left = left;
    this.right = right;
    this.impulse = impulse;
  }
}


class CalibrationFailedException extends Exception {}
