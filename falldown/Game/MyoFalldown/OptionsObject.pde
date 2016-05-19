class OptionsObject
{
  private StatsSettingsOption statsSettings;
  private IOSettingsOption ioSettings;
  
  public OptionsObject()
  {
    statsSettings = new StatsSettingsOption();
    ioSettings = new IOSettingsOption();
  }
  
  StatsSettingsOption getStatsSettings()
  {
    return statsSettings;
  }

  IOSettingsOption getIOSettings()
  {
    return ioSettings;
  }

  private class StatsSettingsOption
  {
    private int RENDER_COMPONENT_INDEX = 0;
    private int GAMES_PLAYED_INDEX = 2;
    private int COINS_COLLECTED_INDEX = 4;
    private int OBSTACLES_JUMPED_INDEX = 6;
    private int HIGH_SCORE_INDEX = 8;
    private String XML_FILE_DEST = "data/xml_data/stats_settings_message.xml";

    private XML xml;

    public StatsSettingsOption()
    {
      xml = loadXML("xml_data/stats_settings_message.xml");
    }

    int getHighScore()
    {
      return getXMLTextComponents(xml)[HIGH_SCORE_INDEX].getInt("string");
    }

    void incrementNumGamesPlayed()
    {
      int alreadyPlayed = getXMLTextComponents(xml)[GAMES_PLAYED_INDEX].getInt("string");
      getXMLTextComponents(xml)[GAMES_PLAYED_INDEX].setInt("string",alreadyPlayed+1);
      saveXML(xml, XML_FILE_DEST);
    }

    void incrementNumCoinsCollected(int collected)
    {
      int alreadyCollected = getXMLTextComponents(xml)[COINS_COLLECTED_INDEX].getInt("string");
      getXMLTextComponents(xml)[COINS_COLLECTED_INDEX].setInt("string",alreadyCollected+collected);
      saveXML(xml, XML_FILE_DEST);
    }

    void incrementNumObstaclesJumped(int jumped)
    {
    }

    XML[] getXMLTextComponents(XML file)
    {
      return file.getChildren("Render")[RENDER_COMPONENT_INDEX].getChildren("Text");
    }

    void setHighScore(int newHighScore)
    {
      getXMLTextComponents(xml)[HIGH_SCORE_INDEX].setInt("string", newHighScore);
      saveXML(xml, XML_FILE_DEST);
    }

    void clearStats()
    {
      setHighScore(0);
      getXMLTextComponents(xml)[GAMES_PLAYED_INDEX].setInt("string",0);
      getXMLTextComponents(xml)[COINS_COLLECTED_INDEX].setInt("string",0);
      getXMLTextComponents(xml)[OBSTACLES_JUMPED_INDEX].setInt("string",0);
      saveXML(xml, XML_FILE_DEST);
    }
  }

  private class IOSettingsOption
  {
    private float musicVol;
    private float seVol;
    private float leftSens;
    private float rightSens;

    private String XML_FILE_DEST = "data/xml_data/save_data.xml";

    private XML xml;

    public IOSettingsOption()
    {
      xml = loadXML("xml_data/save_data.xml");
      musicVol = xml.getChild("IO").getFloat("music");
      seVol = xml.getChild("IO").getFloat("sound_effects");
      leftSens = xml.getChild("IO").getFloat("left_sensitivity");
      rightSens = xml.getChild("IO").getFloat("right_sensitivity");
    }

    float getMusicVol()
    {
      return musicVol;
    }

    float getSEVol()
    {
      return seVol;
    }

    float getLeftSens()
    {
      return leftSens;
    }

    float getRightSens()
    {
      return rightSens;
    }

    void setMusicVol(float newVolume)
    {
      float newAmp = newVolume / 100.00;
      xml.getChild("IO").setFloat("music",newAmp);
      saveXML(xml, XML_FILE_DEST);
      musicVol = newAmp;
    }

    void setSEVol(float newVolume)
    {
      float newSE = newVolume / 100.00;
      xml.getChild("IO").setFloat("sound_effects", newSE);
      saveXML(xml, XML_FILE_DEST);
      seVol = newSE;
    }

    void setLeftSensitivity(float newSensitivity)
    {
      float newLeftSens = newSensitivity / 5.00;
      if (newLeftSens < 0.2)
      {
        newLeftSens = 0.2;
      }
      xml.getChild("IO").setFloat("left_sensitivity", newLeftSens);
      saveXML(xml, XML_FILE_DEST);
      leftSens = newLeftSens;
    }

    void setRightSensitivity(float newSensitivity)
    {
      float newRightSens = newSensitivity / 5.00;
      if (newRightSens < 0.2)
      {
        newRightSens = 0.2;
      }
      xml.getChild("IO").setFloat("right_sensitivity", newRightSens);
      saveXML(xml, XML_FILE_DEST);
      rightSens = newRightSens;
    }
  }
}