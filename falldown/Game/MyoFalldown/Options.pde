//================================================================================================
// Author: Carly Smith
//
// Manages the save data xml file containing application options.
//================================================================================================

//------------------------------------------------------------------------------------------------
// INTERFACE
// The options object is a container for four inner objects which each handle
// different sections of the options XML file.
//------------------------------------------------------------------------------------------------

public interface IOptions
{
  public IGameOptions getGameOptions();
  public IIOOptions getIOOptions();
  public IStats getStats();
  public ICustomizeOptions getCustomizeOptions();
  public ICredits getCredits();
  public ICalibrate getCalibration();
}

public interface IGameOptions
{
  public int getStartingLevel();
  public boolean getLevelUpOverTime();
  public boolean getAutoDirect();
  public boolean getObstacles();
  public boolean getPlatformMods();
  public String getAutoDirectMode();
  
  public void setStartingLevel(int startingLevel);
  public void setLevelUpOverTime(boolean levelUpOverTime);
  public void setAutoDirect(boolean autoDirect);
  public void setObstacles(boolean obstacles);
  public void setPlatformMods(boolean platformMods);
  public void setAutoDirectMode(String mode);
}

enum IOInputMode
{
  DIFFERENCE,
  MAX,
}

public interface IIOOptions
{
  public float getMusicVolume();
  public float getSoundEffectsVolume();
  public float getLeftEMGSensitivity();
  public float getRightEMGSensitivity();
  public IOInputMode getIOInputMode();
  
  public void setMusicVolume(float volume);
  public void setSoundEffectsVolume(float volume);
  public void setLeftEMGSensitivity(float sensitivity);
  public void setRightEMGSensitivity(float sensitivity);
  public void setIOInputMode(IOInputMode mode);
}

public interface IStats
{
  public ArrayList<IGameRecord> getGameRecords();
  
  public IGameRecord createGameRecord();
  public void addGameRecord(IGameRecord record);
  public void clear();
}

public interface IGameRecord
{
  public Comparator<IGameRecord> createByLevelAchievedComparator();
  public Comparator<IGameRecord> createByScoreAchievedComparator();
  public Comparator<IGameRecord> createByTimePlayedComparator();
  public Comparator<IGameRecord> createByAverageSpeedComparator();
  public Comparator<IGameRecord> createByCoinsCollectedComparator();
  public Comparator<IGameRecord> createByDateComparator();

  public int getLevelAchieved();
  public int getScoreAchieved();
  public int getTimePlayed();
  public float getAverageSpeed();
  public int getCoinsCollected();
  public long getDate();
  
  public void setLevelAchieved(int levelAchieved);
  public void setScoreAchieved(int scoreAchieved);
  public void setTimePlayed(int timePlayed);
  public void setAverageSpeed(float averageSpeed);
  public void setCoinsCollected(int coinsCollected);
  public void setDate(long date);
}

public interface ICustomizeOptions
{
}

public interface IGameRecordViewHelper
{
  public String getLevelAchieved();
  public String getScoreAchieved();
  public String getTimePlayed();
  public String getAverageSpeed();
  public String getCoinsCollected();
  public String getDate();
}

public interface ICredits
{
  public boolean isAnonymous();
}

public interface ICalibrate
{
  public int getCalibrationTime();
  public void setCalibrationTime(int seconds);
}
//------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------------------------

public class Options implements IOptions
{
  private final String SAVE_DATA_FILE_NAME_IN = "xml_data/save_data.xml";
  private final String SAVE_DATA_FILE_NAME_OUT = "data/xml_data/save_data.xml"; 
  private XML xmlSaveData;
  
  private IGameOptions gameOptions;
  private IStats stats;
  private IIOOptions IOOptions;
  private ICustomizeOptions customizeOptions;
  private ICredits credits;
  private ICalibrate calibrateOptions;
  
  public Options()
  {
    xmlSaveData = loadXML(SAVE_DATA_FILE_NAME_IN);
    
    gameOptions = new GameOptions();
    stats = new Stats();
    IOOptions = new IOOptions();
    customizeOptions = new CustomizeOptions();
    credits = new Credits();
    calibrateOptions = new CalibrateOptions();
  }
  
  @Override public IGameOptions getGameOptions()
  {
    return gameOptions;
  }
  
  @Override public IStats getStats()
  {
    return stats;
  }

  @Override public IIOOptions getIOOptions()
  {
    return IOOptions;
  }
  
  @Override public ICustomizeOptions getCustomizeOptions()
  {
    return customizeOptions;
  }

  @Override public ICredits getCredits()
  {
    return credits;
  }
  
   @Override public ICalibrate getCalibration()
  {
    return calibrateOptions;
  }
  //--------------------------------------------
  // GAME OPTIONS
  //--------------------------------------------
  public class GameOptions implements IGameOptions
  {
    private final String XML_GAME = "Game";
    private final String STARTING_LEVEL = "starting_level";
    private final String LEVEL_UP_OVER_TIME = "level_up_over_time";
    private final String AUTO_DIRECT = "auto_direct";
    private final String OBSTACLES = "obstacles";
    private final String PLATFORM_MODS = "platform_mods";
    private final String AUTO_DIRECT_MODE = "auto_direct_mode";
    
    private XML xmlGame;
    
    private int startingLevel;
    private boolean levelUpOverTime;
    private boolean autoDirect;
    private boolean obstacles;
    private boolean platformMods;
    private String autoDirectMode;
    
    private GameOptions()
    {
      xmlGame = xmlSaveData.getChild(XML_GAME);
      
      startingLevel = xmlGame.getInt(STARTING_LEVEL);
      levelUpOverTime = xmlGame.getString(LEVEL_UP_OVER_TIME).equals("true") ? true : false;
      autoDirect = xmlGame.getString(AUTO_DIRECT).equals("true") ? true : false;
      obstacles = xmlGame.getString(OBSTACLES).equals("true") ? true : false;
      platformMods = xmlGame.getString(PLATFORM_MODS).equals("true") ? true : false;
      autoDirectMode = xmlGame.getString(AUTO_DIRECT_MODE);
    }
    
    @Override public int getStartingLevel()
    {
      return startingLevel;
    }
    
    @Override public boolean getLevelUpOverTime()
    {
      return levelUpOverTime;
    }
    
    @Override public boolean getAutoDirect()
    {
      return autoDirect;
    }
    
    @Override public boolean getObstacles()
    {
      return obstacles;
    }
    
    @Override public boolean getPlatformMods()
    {
      return platformMods;
    }
    
    @Override public String getAutoDirectMode()
    {
      return autoDirectMode;
    }
    
    @Override public void setStartingLevel(int _startingLevel)
    {
      startingLevel = _startingLevel;
      xmlGame.setInt(STARTING_LEVEL, startingLevel);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
    
    @Override public void setLevelUpOverTime(boolean _levelUpOverTime)
    {
      levelUpOverTime = _levelUpOverTime;
      xmlGame.setString(LEVEL_UP_OVER_TIME, levelUpOverTime ? "true" : "false");
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
    
    @Override public void setAutoDirect(boolean _autoDirect)
    {
      autoDirect = _autoDirect;
      xmlGame.setString(AUTO_DIRECT, autoDirect ? "true" : "false");
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
    
    @Override public void setObstacles(boolean _obstacles)
    {
      obstacles = _obstacles;
      xmlGame.setString(OBSTACLES, obstacles ? "true" : "false");
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
    
    @Override public void setPlatformMods(boolean _platformMods)
    {
      platformMods = _platformMods;
      xmlGame.setString(PLATFORM_MODS, platformMods ? "true" : "false");
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
    
    @Override public void setAutoDirectMode(String _autoDirectMode)
    {
      autoDirectMode = _autoDirectMode;
      xmlGame.setString(AUTO_DIRECT_MODE, autoDirectMode);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
  }

  //--------------------------------------------
  // IO OPTIONS
  //--------------------------------------------
  public class IOOptions implements IIOOptions
  {
    private final String XML_IO = "IO";
    private final String MUSIC_VOLUME = "music_volume";
    private final String SOUND_EFFECTS_VOLUME = "sound_effects_volume";
    private final String LEFT_EMG_SENSITIVITY = "left_emg_sensitivity";
    private final String RIGHT_EMG_SENSITIVITY = "right_emg_sensitivity";
    private final String IO_INPUT_MODE = "input_mode";
    private final String IO_INPUT_MODE_MAX = "max";
    private final String IO_INPUT_MODE_DIFFERENCE = "difference";
    
    private XML xmlIO;
    
    private float musicVolume;
    private float soundEffectsVolume;
    private float leftEMGSensitivity;
    private float rightEMGSensitivity;
    private IOInputMode inputMode;

    private IOOptions()
    {
      xmlIO = xmlSaveData.getChild(XML_IO);
      
      musicVolume = xmlIO.getFloat(MUSIC_VOLUME);
      soundEffectsVolume = xmlIO.getFloat(SOUND_EFFECTS_VOLUME);
      leftEMGSensitivity = xmlIO.getFloat(LEFT_EMG_SENSITIVITY);
      rightEMGSensitivity = xmlIO.getFloat(RIGHT_EMG_SENSITIVITY);
      String inputModeString = xmlIO.getString(IO_INPUT_MODE);
      if (inputModeString.equals("max"))
      {
        inputMode = IOInputMode.MAX;
      }
      else
      {
        inputMode = IOInputMode.DIFFERENCE;
      }
    }

    @Override public float getMusicVolume()
    {
      return musicVolume;
    }

    @Override public float getSoundEffectsVolume()
    {
      return soundEffectsVolume;
    }

    @Override public float getLeftEMGSensitivity()
    {
      return leftEMGSensitivity;
    }

    @Override public float getRightEMGSensitivity()
    {
      return rightEMGSensitivity;
    }
    
    @Override public IOInputMode getIOInputMode()
    {
      return inputMode;
    }

    @Override public void setMusicVolume(float volume)
    {
      musicVolume = volume / 100.0f;
      xmlIO.setFloat(MUSIC_VOLUME, musicVolume);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    @Override public void setSoundEffectsVolume(float volume)
    {
      soundEffectsVolume = volume / 100.0f;
      xmlIO.setFloat(SOUND_EFFECTS_VOLUME, soundEffectsVolume);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    @Override public void setLeftEMGSensitivity(float sensitivity)
    {
      leftEMGSensitivity = sensitivity;
      xmlIO.setFloat(LEFT_EMG_SENSITIVITY, leftEMGSensitivity);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    @Override public void setRightEMGSensitivity(float sensitivity)
    {
      rightEMGSensitivity = sensitivity;
      xmlIO.setFloat(RIGHT_EMG_SENSITIVITY, rightEMGSensitivity);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
    
    @Override public void setIOInputMode(IOInputMode mode)
    {
      inputMode = mode;
      if (inputMode == IOInputMode.MAX)
      {
        xmlIO.setString(IO_INPUT_MODE, IO_INPUT_MODE_MAX);
      }
      else if (inputMode == IOInputMode.DIFFERENCE)
      {
        xmlIO.setString(IO_INPUT_MODE, IO_INPUT_MODE_DIFFERENCE);
      }
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
  }
  
  //--------------------------------------------
  // STATS OPTIONS
  //--------------------------------------------
  public class Stats implements IStats
  {
    public class GameRecord implements IGameRecord
    {
      private int levelAchieved;
      private int scoreAchieved;
      private int timePlayed;
      private float averageSpeed;
      private int coinsCollected;
      private long date;
      
      public GameRecord()
      {
        levelAchieved = -1;
        scoreAchieved = -1;
        timePlayed = -1;
        averageSpeed = -1.0f;
        coinsCollected = -1;
        date = -1;
      }

      @Override public Comparator<IGameRecord> createByLevelAchievedComparator()
      {
        return new ByLevelAchievedComparator();
      }

      @Override public Comparator<IGameRecord> createByScoreAchievedComparator()
      {
        return new ByScoreAchievedComparator();
      }

      @Override public Comparator<IGameRecord> createByTimePlayedComparator()
      {
        return new ByTimePlayedComparator();
      }

      @Override public Comparator<IGameRecord> createByAverageSpeedComparator()
      {
        return new ByAverageSpeedComparator();
      }

      @Override public Comparator<IGameRecord> createByCoinsCollectedComparator()
      {
        return new ByCoinsCollectedComparator();
      }

      @Override public Comparator<IGameRecord> createByDateComparator()
      {
        return new ByDateComparator();
      }
      
      @Override public int getLevelAchieved()
      {
        return levelAchieved;
      }
      
      @Override public int getScoreAchieved()
      {
        return scoreAchieved;
      }
      
      @Override public int getTimePlayed()
      {
        return timePlayed;
      }
      
      @Override public float getAverageSpeed()
      {
        return averageSpeed;
      }
      
      @Override public int getCoinsCollected()
      {
        return coinsCollected;
      }
      
      @Override public long getDate()
      {
        return date;
      }
      
      @Override public void setLevelAchieved(int _levelAchieved)
      {
        levelAchieved = _levelAchieved;
      }
      
      @Override public void setScoreAchieved(int _scoreAchieved)
      {
        scoreAchieved = _scoreAchieved;
      }
      
      @Override public void setTimePlayed(int _timePlayed)
      {
        timePlayed = _timePlayed;
      }
      
      @Override public void setAverageSpeed(float _averageSpeed)
      {
        averageSpeed = _averageSpeed;
      }
      
      @Override public void setCoinsCollected(int _coinsCollected)
      {
        coinsCollected = _coinsCollected;
      }
      
      @Override public void setDate(long _date)
      {
        date = _date;
      }
    }
    
    private final String XML_STATS = "Stats";
    private final String XML_RECORD = "Record";
    private final String XML_LEVEL_ACHIEVED = "level";
    private final String XML_SCORE_ACHIEVED = "score";
    private final String XML_TIME_PLAYED = "time_played_millis";
    private final String XML_AVERAGE_SPEED = "avg_speed";
    private final String XML_COINS_COLLECTED = "coins_collected";
    private final String XML_DATE = "date";
    
    private XML xmlStats;
    private ArrayList<IGameRecord> gameRecords;
    
    private Stats()
    {
      xmlStats = xmlSaveData.getChild(XML_STATS);
      
      gameRecords = new ArrayList<IGameRecord>();
      
      for (XML xmlRecord : xmlStats.getChildren())
      {
        if (xmlRecord.getName().equals(XML_RECORD))
        {
          IGameRecord record = new GameRecord();
          record.setLevelAchieved(xmlRecord.getInt(XML_LEVEL_ACHIEVED));
          record.setScoreAchieved(xmlRecord.getInt(XML_SCORE_ACHIEVED));
          record.setTimePlayed(xmlRecord.getInt(XML_TIME_PLAYED));
          record.setAverageSpeed(xmlRecord.getFloat(XML_AVERAGE_SPEED));
          record.setCoinsCollected(xmlRecord.getInt(XML_COINS_COLLECTED));
          record.setDate(Long.parseLong(xmlRecord.getString(XML_DATE)));
          gameRecords.add(record);
        }
      }
    }
    
    @Override public ArrayList<IGameRecord> getGameRecords()
    {
      return gameRecords;
    }
    
    @Override public IGameRecord createGameRecord()
    {
      return new GameRecord();
    }
  
    @Override public void addGameRecord(IGameRecord record)
    {
      gameRecords.add(record);
      XML xmlRecord = xmlStats.addChild(XML_RECORD);
      xmlRecord.setInt(XML_LEVEL_ACHIEVED, record.getLevelAchieved());
      xmlRecord.setInt(XML_SCORE_ACHIEVED, record.getScoreAchieved());
      xmlRecord.setInt(XML_TIME_PLAYED, record.getTimePlayed());
      xmlRecord.setFloat(XML_AVERAGE_SPEED, record.getAverageSpeed());
      xmlRecord.setInt(XML_COINS_COLLECTED, record.getCoinsCollected());
      xmlRecord.setString(XML_DATE, Long.toString(record.getDate()));
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
    
    @Override public void clear()
    {
      gameRecords.clear();
      
      for (String childName : xmlStats.listChildren())
      {
        xmlStats.removeChild(xmlStats.getChild(childName));
      }
      
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    public class ByLevelAchievedComparator implements Comparator<IGameRecord>
    {
      @Override public int compare(IGameRecord g1, IGameRecord g2)
      {
        return Integer.compare(g1.getLevelAchieved(), g2.getLevelAchieved());
      }
    }

    public class ByScoreAchievedComparator implements Comparator<IGameRecord>
    {
      @Override public int compare(IGameRecord g1, IGameRecord g2)
      {
        return Integer.compare(g1.getScoreAchieved(), g2.getScoreAchieved());
      }
    }

    public class ByTimePlayedComparator implements Comparator<IGameRecord>
    {
      @Override public int compare(IGameRecord g1, IGameRecord g2)
      {
        return Integer.compare(g1.getTimePlayed(), g2.getTimePlayed());
      }
    }

    public class ByAverageSpeedComparator implements Comparator<IGameRecord>
    {
      @Override public int compare(IGameRecord g1, IGameRecord g2)
      {
        return Float.compare(g1.getAverageSpeed(), g2.getAverageSpeed());
      }
    }

    public class ByCoinsCollectedComparator implements Comparator<IGameRecord>
    {
      @Override public int compare(IGameRecord g1, IGameRecord g2)
      {
        return Integer.compare(g1.getCoinsCollected(), g2.getCoinsCollected());
      }
    }

    public class ByDateComparator implements Comparator<IGameRecord>
    {
      @Override public int compare(IGameRecord g1, IGameRecord g2)
      {
        return Long.compare(g1.getDate(), g2.getDate());
      }
    }

  }
  
  //--------------------------------------------
  // CUSTOMIZE OPTIONS
  //--------------------------------------------
  public class CustomizeOptions implements ICustomizeOptions
  {
    private CustomizeOptions()
    {
    }
  }

  //--------------------------------------------
  // CREDITS SETTINGS
  //--------------------------------------------
  public class Credits implements ICredits
  {
    private final String XML_CREDITS = "Credits";
    private final String ANONYMOUS = "anonymous";

    private XML xmlStats;
    private boolean anonymous;

    private Credits()
    {
      xmlStats = xmlSaveData.getChild(XML_CREDITS);

      anonymous = Boolean.parseBoolean(xmlStats.getString(ANONYMOUS));
    }

    @Override public boolean isAnonymous()
    {
      return anonymous;
    }
  }
  //--------------------------------------------
  // CUSTOMIZE OPTIONS
  //--------------------------------------------
  public class CalibrateOptions implements ICalibrate
  {
    private final String XML_CAL = "Calibrate";
    private final String XML_SEC = "seconds";
    
    private XML xmlCal;
    private int seconds;
    
    private CalibrateOptions()
    {
       xmlCal = xmlSaveData.getChild(XML_CAL);
       seconds = xmlCal.getInt(XML_SEC);
    }
    
    @Override public int getCalibrationTime()
    {
      return seconds;
    }
    @Override public void setCalibrationTime(int setSecs)
    {
      seconds = setSecs;
      xmlCal.setInt(XML_SEC, setSecs);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
  }
}

public class GameRecordViewHelper implements IGameRecordViewHelper
{
  private final String EMPTY_VALUE = "---";
  private IGameRecord gameRecord;

  public GameRecordViewHelper(IGameRecord _gameRecord)
  {
    gameRecord = _gameRecord;
  }

  @Override public String getLevelAchieved()
  {
    if (gameRecord == null)
      return EMPTY_VALUE;
    else
      return Integer.toString(gameRecord.getLevelAchieved());
  }

  @Override public String getScoreAchieved()
  {
    if (gameRecord == null)
      return EMPTY_VALUE;
    else
      return Integer.toString(gameRecord.getScoreAchieved());
  }

  @Override public String getTimePlayed()
  {
    if (gameRecord == null)
      return EMPTY_VALUE;

    int milliseconds = gameRecord.getTimePlayed();
    int seconds = (milliseconds/1000) % 60;
    int minutes = milliseconds/60000;
    return String.format("%3d:%02d", minutes, seconds);
  }

  @Override public String getAverageSpeed()
  {
    if (gameRecord == null)
      return EMPTY_VALUE;
    else
      return String.format("%.1f", gameRecord.getAverageSpeed());
  }

  @Override public String getCoinsCollected()
  {
    if (gameRecord == null)
      return EMPTY_VALUE;
    else
      return Integer.toString(gameRecord.getCoinsCollected());
  } 

  @Override public String getDate()
  {
    if (gameRecord == null)
      return EMPTY_VALUE;

    SimpleDateFormat dateFormatter = new SimpleDateFormat("MMM dd, ''yy");
    return dateFormatter.format(new Date(gameRecord.getDate()));
  }
}
