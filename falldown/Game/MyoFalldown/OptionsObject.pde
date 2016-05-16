class OptionsObject
{
  private StatsSettingsOption statsSettings;
  
  public OptionsObject()
  {
    statsSettings = new StatsSettingsOption();
  }
  
  StatsSettingsOption getStatsSettings()
  {
    return statsSettings;
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
}