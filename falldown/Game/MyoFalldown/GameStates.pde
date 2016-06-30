 //========================================================================================
// Author: David Hanna
//
// The abstraction of a game state.
//========================================================================================

//-------------------------------------------------------------------------------
// INTERFACE
//-------------------------------------------------------------------------------

public interface IGameState
{
  public void onEnter();
  public void update(int deltaTime);
  public void onExit();
  public IGameObjectManager getGameObjectManager();
}

public abstract class GameState implements IGameState
{
  protected IGameObjectManager gameObjectManager;
  
  public GameState()
  {
    gameObjectManager = new GameObjectManager();
  }
  
  @Override abstract public void onEnter();
  @Override abstract public void update(int deltaTime);
  @Override abstract public void onExit();
  
  @Override public IGameObjectManager getGameObjectManager()
  {
    return gameObjectManager;
  }
}

public interface IGameStateController
{
  public void update(int deltaTime);
  public void pushState(GameState nextState);
  public void popState();
  public IGameState getCurrentState();
  public IGameState getPreviousState();
  public IGameObjectManager getGameObjectManager();
}


//-------------------------------------------------------------------------------
// IMPLEMENTATION
//-------------------------------------------------------------------------------

public class GameState_MainMenu extends GameState
{
  public GameState_MainMenu()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/main_menu.xml");
  }
  
  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }
  
  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      
      if (tag.equals("start_game"))
      {
        
        if (emgManager.isCalibrated())
        {
          gameStateController.pushState(new GameState_InGame());
        }
        else
        {
          gameStateController.pushState(new GameState_MyoNotConnected());
        }
      }
      else if (tag.equals("options_menu")) 
      {
        gameStateController.pushState(new GameState_OptionsMenu());
      }
      else if (tag.equals("calibrate"))
      {
        if (emgManager.isCalibrated())
        {
          gameStateController.pushState(new GameState_CalibrateSuccess());
        }
        else
        {
          gameStateController.pushState(new GameState_CalibrateFailure());
        }
      }
      else if (tag.equals("help"))
      {
        gameStateController.pushState(new GameState_Help());
      }
      else if (tag.equals("credits"))
      {
        gameStateController.pushState(new GameState_Credits());
      }
      else if (tag.equals("exit"))
      {
        gameStateController.pushState(new GameState_Confirm_Quit());
      }
    }
  }
}

public class GameState_Confirm_Quit extends GameState
{
  public GameState_Confirm_Quit()
  {
    super();
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/confirm_quit.xml");
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }

  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      switch(tag)
      {
        case "yes":
          gameStateController.popState();
          gameStateController.popState();
          break;
        case "no":
          gameStateController.popState();
          break;
      }
    }
  }
}

public class GameState_UserLogin extends GameState
{
  public GameState_UserLogin()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/user_login.xml");
  }
  
  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }
  
  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      if (tag.equals("login"))
      {
        CounterIDComponent counterIDComponent = (CounterIDComponent) gameObjectManager.getGameObjectsByTag("counter-1").get(0).getComponent(ComponentType.ID_COUNTER);
        String userID = counterIDComponent.getUserIDNumber();
        boolean newUser = options.getUserInformation().setSaveDataFile(userID);
        options.getCustomizeOptions().reset();
        options.getCustomizeOptions().loadSavedSettings();
        if (newUser)
        {
          gameStateController.pushState(new GameState_NewUser());
        }
        else
        {
          gameStateController.pushState(new GameState_MainMenu());
        }
      }
      else if(tag.equals("play_as_guest")){
        options.getCustomizeOptions().reset();
        gameStateController.pushState(new GameState_MomoStory());
      }
      else if(tag.equals("exit")){
        gameStateController.popState();
      }
    }
  }
}

public class GameState_MomoStory extends GameState
{
  public GameState_MomoStory()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/momo_story.xml");
  }
  
  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }
  
  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
       
      if (tag.equals("skip"))
      {
        gameStateController.popState();
        gameStateController.pushState(new GameState_MainMenu());
      }
    }
  }
}

public class GameState_InGame extends GameState
{
  public GameState_InGame()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/game.xml");
    tableInput = loadTable(options.getFittsLawOptions().getInputFile(), "header");
    totalRowCountInput = tableInput.getRowCount(); 
    createNewTable();
    logRawData = true;
  }
  
  @Override public void update(int deltaTime)
  {
    shape(bg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    physicsWorld.step(((float)deltaTime) / 1000.0f, velocityIterations, positionIterations);
    handleEvents();
  }
  
  @Override public void onExit()
  {
    logRawData = false;
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.SPACEBAR_PRESSED))
    {
      gameStateController.pushState(new GameState_IOSettings());
    }
    for (IEvent event : eventManager.getEvents(EventType.ESCAPE_PRESSED))
    {
      gameStateController.pushState(new GameState_IOSettings());
    }
    for (IEvent event : eventManager.getEvents(EventType.GAME_OVER))
    {
      String ID = options.getUserInformation().getUserID();
      if(ID == null)
      {
        ID = "guest";
      }
      Date d = new Date();
      
      if(logFittsLaw)
      {
        saveTable(tableFittsStats, "data/xml_data/fitts_law_data/fittsTable_" + ID + "_"+ d.getTime() + ".csv"); 
      }
      
      if(options.getGameOptions().getLogRawData())
      {
         saveTable(tableRawData, "data/raw_data/rawDataTable_" + ID + "_"+ d.getTime() + ".csv");  
      }
      gameStateController.popState();
      gameStateController.pushState(new GameState_PostGame());
    }
  }
  
  private void createNewTable()
  {
    tableFittsStats = new Table();
    tableFittsStats.addColumn("id");
    tableFittsStats.addColumn("trial");
    tableFittsStats.addColumn("level");
    tableFittsStats.addColumn("condition");
    tableFittsStats.addColumn("start point x");
    tableFittsStats.addColumn("end point x");
    tableFittsStats.addColumn("start time");
    tableFittsStats.addColumn("end time");
    tableFittsStats.addColumn("total time");
    tableFittsStats.addColumn("errors");
    tableFittsStats.addColumn("undershoots");
    tableFittsStats.addColumn("overshoots");
    tableFittsStats.addColumn("direction changes");
    
    tableRawData = new Table();
    tableRawData.addColumn("userID");
    tableRawData.addColumn("timestamp");
    tableRawData.addColumn("Playing With");
    tableRawData.addColumn("level");
    tableRawData.addColumn("SensorLeft");
    tableRawData.addColumn("SensorRight");
    tableRawData.addColumn("SensorJump");
    tableRawData.addColumn("InputType");
    tableRawData.addColumn("Mode");
    tableRawData.addColumn("MovingLeft");
    tableRawData.addColumn("MovingRight");
    tableRawData.addColumn("Jumping");
  }
}

public class GameState_PostGame extends GameState
{
  private boolean textLoaded;
  private boolean smartSuggestion;
  private IGameOptions gameOps;

  public GameState_PostGame()
  {
    super();

    textLoaded = false;
    smartSuggestion = false;
    gameOps = options.getGameOptions();
  }
  
  @Override public void onEnter()
  {
    gameOverSoundEffect.amp(1.0 * options.getIOOptions().getSoundEffectsVolume());
    gameOverSoundEffect.play();
    gameOver.amp(1.0 * options.getIOOptions().getMusicVolume());
    gameOver.play();
    gameObjectManager.fromXML("xml_data/post_game.xml");
  }
  
  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();

    if (!textLoaded && gameObjectManager.getGameObjectsByTag("message").size() > 0)
    {
      loadChanges();
    }
  }
  
  @Override public void onExit()
  {
    gameOver.stop();
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      
      if (tag.equals("back"))
      {
        gameStateController.popState();
        if (smartSuggestion)
          gameStateController.pushState(new GameState_SmartSuggestion());
      }
      else if (tag.equals("play_again"))
      {
        gameStateController.popState();
        gameStateController.pushState(new GameState_InGame());
        if (smartSuggestion)
          gameStateController.pushState(new GameState_SmartSuggestion());
      }
      else if (tag.equals("gameplay_record"))
      {
        gameStateController.popState();
        gameStateController.pushState(new GameState_OptionsMenu());
        gameStateController.pushState(new GameState_StatsSettings());
        if (smartSuggestion)
          gameStateController.pushState(new GameState_SmartSuggestion());
      }
      else if (tag.equals("buy"))
      {
        gameStateController.popState();
        gameStateController.pushState(new GameState_OptionsMenu());
        gameStateController.pushState(new GameState_CustomizeSettings());
        if (smartSuggestion)
          gameStateController.pushState(new GameState_SmartSuggestion());
      }
    }
  }

  public void loadChanges()
  {
    RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponent(ComponentType.RENDER);

    if (options.getCustomizeOptions().hasEnoughCoinsToBuySomething())
    {
      renderComponent.getTexts().get(7).translation.x = 375;
      renderComponent.getImages().get(0).translation.x = 375;

      IGameObject gameObj = gameObjectManager.getGameObjectsByTag("buy").get(0);
      gameObj.setTranslation(new PVector(375.0, 255.0));
    }

    ArrayList<IGameRecord> records = options.getStats().getGameRecords();
    IGameRecord lastGameRecord = records.get(records.size() - 1);

    if (lastGameRecord.getAverageSpeed() < gameOps.getLowAvgSpeedThreshold())
    {
      smartSuggestion = true;
    }
    else if (lastGameRecord.getAverageSpeed() > gameOps.getHighAvgSpeedThreshold())
    {
      smartSuggestion = true;
    }

    if (lastGameRecord.getScoreAchieved() > options.getStats().getHighScore())
    {
      options.getStats().setHighScore(lastGameRecord.getScoreAchieved());
      renderComponent.getTexts().get(1).translation.x = 250;
    }

    if (lastGameRecord.getScoreAchieved() < 5)
    {
      renderComponent.getTexts().get(0).string = "Good Try!";
    }
    else if (lastGameRecord.getScoreAchieved() < 10)
    {
      renderComponent.getTexts().get(0).string = "Nice Job!";
    }
    else if (lastGameRecord.getScoreAchieved() < 20)
    {
      renderComponent.getTexts().get(0).string = "Bravo!";
    }
    else if (lastGameRecord.getScoreAchieved() < 30)
    {
      renderComponent.getTexts().get(0).string = "Sweet!";
    }
    else if (lastGameRecord.getScoreAchieved() < 40)
    {
      renderComponent.getTexts().get(0).string = "Stellar!";
    }
    else if (lastGameRecord.getScoreAchieved() < 50)
    {
      renderComponent.getTexts().get(0).string = "Awesome!";
    }
    else if (lastGameRecord.getScoreAchieved() >= 100)
    {
      renderComponent.getTexts().get(0).string = "Momo Master!";
    }

    textLoaded = true;
  }
}

public class GameState_OptionsMenu extends GameState
{
  public GameState_OptionsMenu()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/options_menu.xml");
  }
  
  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }
  
  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      if (tag.equals("GameSettings"))
      {
        gameStateController.pushState(new GameState_GameSettings());
      }
      else if (tag.equals("IOSettings"))
      {
        gameStateController.pushState(new GameState_IOSettings());
      }
      else if (tag.equals("StatsSettings"))
      {
        gameStateController.pushState(new GameState_StatsSettings());
      }
      else if (tag.equals("CustomizeSettings"))
      {
        gameStateController.pushState(new GameState_CustomizeSettings());
      }
      else if (tag.equals("back"))
      {
        gameStateController.popState();
      }
    }
  }
}

public class GameState_GameSettings extends GameState
{
  public GameState_GameSettings()
  {
    super();
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/game_settings.xml");
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    handleEvents();
    gameObjectManager.update(deltaTime);
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      if (event.getRequiredStringParameter("tag").equals("back"))
      {
        gameStateController.popState();
      }
    }
    
    for (IEvent event : eventManager.getEvents(EventType.SLIDER_DRAGGED))
    {
      if (event.getRequiredStringParameter("tag").equals("starting_level"))
      {
        float sliderValue = event.getRequiredFloatParameter("sliderValue");
        int startingLevel = (int)(((98.0f * (sliderValue / 100.0f)) + 1.0f));
        options.getGameOptions().setStartingLevel(startingLevel);
      }
    }

    for (IEvent event : eventManager.getEvents(EventType.MODAL_HOVER))
    {
      String tag = event.getRequiredStringParameter("tag");
      if (gameObjectManager.getGameObjectsByTag("message") != null && gameObjectManager.getGameObjectsByTag("message").size() > 0 && gameObjectManager.getGameObjectsByTag("message").get(0).getComponents(ComponentType.RENDER).size() > 1)
      {
        RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponents(ComponentType.RENDER).get(1);
        ArrayList<RenderComponent.Text> texts = renderComponent.getTexts();
        ArrayList<RenderComponent.OffsetPShape> shapes = renderComponent.getShapes();
        if (tag.equals("auto_direct_modal"))
        {
          shapes.get(0).translation.x = 250;
          for (int i = 0; i <= 5; i++)
          {
            texts.get(i).translation.x = 250;
          }
        }
        else if (tag.equals("single_muscle_modal"))
        {
          shapes.get(1).translation.x = 250;
          for (int i = 6; i <= 13; i++)
          {
            texts.get(i).translation.x = 250;
          }
        }
      }
    }

    for (IEvent event : eventManager.getEvents(EventType.MODAL_OFF))
    {
      String tag = event.getRequiredStringParameter("tag");
      if (gameObjectManager.getGameObjectsByTag("message") != null && gameObjectManager.getGameObjectsByTag("message").size() > 0 && gameObjectManager.getGameObjectsByTag("message").get(0).getComponents(ComponentType.RENDER).size() > 1)
      {
        RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponents(ComponentType.RENDER).get(1);
        ArrayList<RenderComponent.Text> texts = renderComponent.getTexts();
        ArrayList<RenderComponent.OffsetPShape> shapes = renderComponent.getShapes();
        if (tag.equals("auto_direct_modal"))
        {
          shapes.get(0).translation.x = 1000;
          for (int i = 0; i <= 5; i++)
          {
            texts.get(i).translation.x = 1000;
          }
        }
        else if (tag.equals("single_muscle_modal"))
        {
          shapes.get(1).translation.x = 1000;
          for (int i = 6; i <= 13; i++)
          {
            texts.get(i).translation.x = 1000;
          }
        }
      }
    }
  }
}

public class GameState_IOSettings extends GameState
{
  public boolean isPauseScreen;
  public boolean saveDataLoaded;
  public boolean tweakedForPauseOrSettings;

  SoundFile buttonClickedSoundTest;
  float amplitude;

  XML buttonXML;
  XML buttomXMLComponent;

  public GameState_IOSettings()
  {
    super();

    isPauseScreen = false;
    saveDataLoaded = false;
    tweakedForPauseOrSettings = false;

    buttonXML = loadXML("xml_data/button.xml");
    buttomXMLComponent = buttonXML.getChild("Button");
    buttonClickedSoundTest = new SoundFile(mainObject, buttomXMLComponent.getString("buttonClickedSound"));
    buttonClickedSoundTest.rate(buttomXMLComponent.getFloat("rate"));
    try { buttonClickedSoundTest.pan(buttomXMLComponent.getFloat("pan")); } catch (UnsupportedOperationException e) {}
    amplitude = buttomXMLComponent.getFloat("amp");
    buttonClickedSoundTest.add(buttomXMLComponent.getFloat("add"));
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/io_settings.xml");
    isPauseScreen = gameStateController.getPreviousState() instanceof GameState_InGame;
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();

    if (!saveDataLoaded && gameObjectManager.getGameObjectsByTag("message").size() > 0)
    {
      loadFromSaveData();
    }

    if (!tweakedForPauseOrSettings)
    {
      tweakPauseOrSettings();
      tweakedForPauseOrSettings = true;
    }
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      
      if (tag.equals("back"))
      {
        gameStateController.popState();
      }
      else if (tag.equals("difference"))
      {
        options.getIOOptions().setEmgSamplingPolicy(EmgSamplingPolicy.DIFFERENCE);
        RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponent(ComponentType.RENDER);
        renderComponent.getShapes().get(4).translation.y = renderComponent.getShapes().get(1).translation.y;
      }
      else if (tag.equals("max"))
      {
        options.getIOOptions().setEmgSamplingPolicy(EmgSamplingPolicy.MAX);
        RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponent(ComponentType.RENDER);
        renderComponent.getShapes().get(4).translation.y = renderComponent.getShapes().get(2).translation.y;
      }
      else if (tag.equals("first_over"))
      {
        options.getIOOptions().setEmgSamplingPolicy(EmgSamplingPolicy.FIRST_OVER);
        RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponent(ComponentType.RENDER);
        renderComponent.getShapes().get(4).translation.y = renderComponent.getShapes().get(3).translation.y;
      }
      else if (tag.equals("define_input"))
      {
        gameStateController.pushState(new GameState_DefineInput());
      }
      else if (tag.equals("calibrate"))
      {
        if (emgManager.isCalibrated())
        {
          gameStateController.pushState(new GameState_CalibrateSuccess());
        }
        else
        {
          gameStateController.pushState(new GameState_CalibrateFailure());
        }
      }
      else if (tag.equals("quit"))
      {
        gameStateController.popState();
        eventManager.queueEvent(new Event(EventType.GAME_OVER));
      }
    }
    
    for (IEvent event : eventManager.getEvents(EventType.SLIDER_DRAGGED))
    {
      String tag = event.getRequiredStringParameter("tag");
      float sliderValue = event.getRequiredFloatParameter("sliderValue");
      
      if (tag.equals("music"))
      {
        options.getIOOptions().setMusicVolume(sliderValue);
        
        IGameState previousState = gameStateController.getPreviousState();
        if (previousState != null)
        {
          ArrayList<IGameObject> musicPlayerList = previousState.getGameObjectManager().getGameObjectsByTag("music_player");
          if (musicPlayerList.size() > 0)
          {
            IGameObject musicPlayer = musicPlayerList.get(0);
            IComponent component = musicPlayer.getComponent(ComponentType.MUSIC_PLAYER);
            if (component != null)
            {
              MusicPlayerComponent musicPlayerComponent = (MusicPlayerComponent)component;
              musicPlayerComponent.setMusicVolume(options.getIOOptions().getMusicVolume());
            }
          }
        }
      }
      else if (tag.equals("sound_effects"))
      {
        options.getIOOptions().setSoundEffectsVolume(sliderValue);
      }
      else if (tag.equals("left_sensitivity"))
      {
        float sensitivityValue = (4.8f * (sliderValue / 100.0f)) + 0.2f;
        options.getIOOptions().setLeftEMGSensitivity(sensitivityValue);
      }
      else if (tag.equals("right_sensitivity"))
      {
        float sensitivityValue = (4.8f * (sliderValue / 100.0f)) + 0.2f;
        options.getIOOptions().setRightEMGSensitivity(sensitivityValue);
      }
      else if (tag.equals("threshold"))
      {
        options.getIOOptions().setMinInputThreshold(sliderValue);
        IGameState previousState = gameStateController.getPreviousState();
        if (previousState.getGameObjectManager().getGameObjectsByTag("player").size() > 0)
        {
          PlayerControllerComponent playerControllerComponent = (PlayerControllerComponent) previousState.getGameObjectManager().getGameObjectsByTag("player").get(0).getComponent(ComponentType.PLAYER_CONTROLLER);
          playerControllerComponent.setMinInputThreshold(sliderValue);
        }
      }
    }

    for (IEvent event : eventManager.getEvents(EventType.MODAL_HOVER))
    {
      String tag = event.getRequiredStringParameter("tag");
      if (gameObjectManager.getGameObjectsByTag("message") != null && gameObjectManager.getGameObjectsByTag("message").size() > 0 && gameObjectManager.getGameObjectsByTag("message").get(0).getComponents(ComponentType.RENDER).size() > 1)
      {
        RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponents(ComponentType.RENDER).get(1);
        ArrayList<RenderComponent.Text> texts = renderComponent.getTexts();
        ArrayList<RenderComponent.OffsetPShape> shapes = renderComponent.getShapes();
        if (tag.equals("input"))
        {
          shapes.get(0).translation.x = 250;
          for (int i = 0; i <= 3; i++)
          {
            texts.get(i).translation.x = 250;
          }
        }
        else if (tag.equals("difference"))
        {
          shapes.get(1).translation.x = 250;
          for (int i = 4; i <= 9; i++)
          {
            texts.get(i).translation.x = 250;
          }
        }
        else if (tag.equals("max"))
        {
          shapes.get(2).translation.x = 250;
          for (int i = 10; i <= 13; i++)
          {
            texts.get(i).translation.x = 250;
          }
        }
        else if (tag.equals("first_over"))
        {
          shapes.get(3).translation.x = 250;
          for (int i = 14; i <= 19; i++)
          {
            texts.get(i).translation.x = 250;
          }
        }
        else if (tag.equals("threshold_modal"))
        {
          shapes.get(4).translation.x = 250;
          for (int i = 20; i <= 26; i++)
          {
            texts.get(i).translation.x = 250;
          }
        }
      }
    }

    for (IEvent event : eventManager.getEvents(EventType.MODAL_OFF))
    {
      String tag = event.getRequiredStringParameter("tag");
      if (gameObjectManager.getGameObjectsByTag("message") != null && gameObjectManager.getGameObjectsByTag("message").size() > 0 && gameObjectManager.getGameObjectsByTag("message").get(0).getComponents(ComponentType.RENDER).size() > 1)
      {
        RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponents(ComponentType.RENDER).get(1);
        ArrayList<RenderComponent.Text> texts = renderComponent.getTexts();
        ArrayList<RenderComponent.OffsetPShape> shapes = renderComponent.getShapes();
        if (tag.equals("input"))
        {
          shapes.get(0).translation.x = 1000;
          for (int i = 0; i <= 3; i++)
          {
            texts.get(i).translation.x = 1000;
          }
        }
        else if (tag.equals("difference"))
        {
          shapes.get(1).translation.x = 1000;
          for (int i = 4; i <= 9; i++)
          {
            texts.get(i).translation.x = 1000;
          }
        }
        else if (tag.equals("max"))
        {
          shapes.get(2).translation.x = 1000;
          for (int i = 10; i <= 13; i++)
          {
            texts.get(i).translation.x = 1000;
          }
        }
        else if (tag.equals("first_over"))
        {
          shapes.get(3).translation.x = 1000;
          for (int i = 14; i <= 19; i++)
          {
            texts.get(i).translation.x = 1000;
          }
        }
        else if (tag.equals("threshold_modal"))
        {
          shapes.get(4).translation.x = 1000;
          for (int i = 20; i <= 26; i++)
          {
            texts.get(i).translation.x = 1000;
          }
        }
      }
    }

    for (IEvent event : eventManager.getEvents(EventType.SLIDER_RELEASED))
    {
      String tag = event.getRequiredStringParameter("tag");
      if (tag.equals("music"))
      {
        buttonClickedSoundTest.amp(amplitude * options.getIOOptions().getMusicVolume());
        buttonClickedSoundTest.play();
      }
      else if (tag.equals("sound_effects"))
      {
        buttonClickedSoundTest.amp(amplitude * options.getIOOptions().getSoundEffectsVolume());
        buttonClickedSoundTest.play();
      }
    }

    if (isPauseScreen)
    {
      for(IEvent event : eventManager.getEvents(EventType.SPACEBAR_PRESSED))
      {
        gameStateController.popState();
        return;
      }
      for(IEvent event : eventManager.getEvents(EventType.ESCAPE_PRESSED))
      {
        gameStateController.popState();
        return;
      }
    }
  }

  private void loadFromSaveData()
  {
    EmgSamplingPolicy policy = options.getIOOptions().getEmgSamplingPolicy();
    RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponent(ComponentType.RENDER);
    if (renderComponent.getShapes().get(4).translation.y == 0)
    {
      if (policy == EmgSamplingPolicy.DIFFERENCE)
      {
        renderComponent.getShapes().get(4).translation.y = renderComponent.getShapes().get(1).translation.y;
      }
      else if (policy == EmgSamplingPolicy.MAX)
      {
        renderComponent.getShapes().get(4).translation.y = renderComponent.getShapes().get(2).translation.y;
      }
      else if (policy == EmgSamplingPolicy.FIRST_OVER)
      {
        renderComponent.getShapes().get(4).translation.y = renderComponent.getShapes().get(3).translation.y;
      }
    }
    saveDataLoaded = true;
  }

  private void tweakPauseOrSettings()
  {
    ArrayList<IGameObject> messageObjects = gameObjectManager.getGameObjectsByTag("message");
    if (messageObjects.size() > 0)
    {
      IGameObject messageObject = messageObjects.get(0);
      IComponent component = messageObject.getComponent(ComponentType.RENDER);
      if (component != null)
      {
        RenderComponent renderComponent = (RenderComponent) component;
        ArrayList<RenderComponent.Text> texts = renderComponent.getTexts();
        ArrayList<RenderComponent.OffsetPImage> sprites = renderComponent.getImages();

        if (isPauseScreen) // change title to "Paused"
        {
          for (RenderComponent.Text t : texts)
          {
            if (t.string.equals("System Settings"))
            {
              t.string = "Paused";
            }
          }
        }
        else // remove "Quit Game" button
        {
          // text (assuming it is the fourth occurance of text in XML)
          texts.get(3).string = "";

          // sprite (assuming it is the first occuring sprite in XML)
          sprites.get(0).translation.x = 5000;
          sprites.get(0).translation.y = 5000;

          // button
          ArrayList<IGameObject> quitButtons = gameObjectManager.getGameObjectsByTag("quit");
          if (quitButtons.size() > 0)
          {
            IGameObject quitButton = quitButtons.get(0);
            gameObjectManager.removeGameObject(quitButton.getUID());
          }
        }
      }
    }
  }
}

public class GameState_DefineInput extends GameState
{

  public GameState_DefineInput()
  {
    super();
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/define_input.xml");
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }

  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");

      if (tag.equals("back"))
      {
        gameStateController.popState();
      }
    }
  }
}

public class GameState_StatsSettings extends GameState
{

  final int NUM_RECORDS_VISIBLE = 9;
  ArrayList<IGameRecord> records;
  int topRow;

  public GameState_StatsSettings()
  {
    super();
    records = new ArrayList<IGameRecord>();
    topRow = 0;
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/stats_settings.xml");
    records = options.getStats().getGameRecords();
    topRow = 0;
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();
    refreshVisibleRecords();
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      IGameRecord record = options.getStats().createGameRecord();
      RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("stats_message").get(0).getComponent(ComponentType.RENDER);
      RenderComponent.OffsetPImage sorter = renderComponent.getImages().get(6);
      String tag = event.getRequiredStringParameter("tag");
      switch (tag)
      {
        case "back":
          gameStateController.popState();
          break;
        case "clear_stats":
          gameStateController.pushState(new GameState_ClearStats_Confirm());
          break;
        case "level_achieved":
          Collections.sort(records, Collections.reverseOrder(record.createByLevelAchievedComparator()));
          sorter.translation.x = 50;
          break;
        case "score_achieved":
          Collections.sort(records, Collections.reverseOrder(record.createByScoreAchievedComparator()));
          sorter.translation.x = 130;
          break;
        case "coins_collected":
          Collections.sort(records, Collections.reverseOrder(record.createByCoinsCollectedComparator()));
          sorter.translation.x = 210;
          break;
        case "average_speed":
          Collections.sort(records, Collections.reverseOrder(record.createByAverageSpeedComparator()));
          sorter.translation.x = 290;
          break;
        case "time_played":
          Collections.sort(records, Collections.reverseOrder(record.createByTimePlayedComparator()));
          sorter.translation.x = 370;
          break;
        case "date":
          Collections.sort(records, Collections.reverseOrder(record.createByDateComparator()));
          sorter.translation.x = 450;
          break;
      }
    }

    for (IEvent event : eventManager.getEvents(EventType.UP_BUTTON_PRESSED))
    {
      if (topRow > 0)
        topRow--;
    }

    for (IEvent event : eventManager.getEvents(EventType.DOWN_BUTTON_PRESSED))
    {
      if (topRow+NUM_RECORDS_VISIBLE-1 < options.getStats().getGameRecords().size())
        topRow++;
    }
  }

  private void refreshVisibleRecords()
  {
    ArrayList<IGameObject> tableRows = new ArrayList<IGameObject>();
    for (int i=0; i<NUM_RECORDS_VISIBLE; i++)
    {
      tableRows = gameStateController.getGameObjectManager().getGameObjectsByTag(String.format("stats_row_%d", i));

      if (tableRows.size() == 1)
      {
        IComponent component = tableRows.get(0).getComponent(ComponentType.RENDER);
        if (component != null)
        {
          RenderComponent renderComponent = (RenderComponent) component;
          ArrayList<RenderComponent.Text> texts = renderComponent.getTexts();

          IGameRecordViewHelper viewHelper;
          if (topRow+i >= 0 && topRow+i < records.size())
            viewHelper = new GameRecordViewHelper(records.get(topRow+i));
          else
            viewHelper = new GameRecordViewHelper(null);

          texts.get(0).string = viewHelper.getLevelAchieved();
          texts.get(1).string = viewHelper.getScoreAchieved();
          texts.get(2).string = viewHelper.getCoinsCollected();
          texts.get(3).string = viewHelper.getAverageSpeed();
          texts.get(4).string = viewHelper.getTimePlayed();
          texts.get(5).string = viewHelper.getDate();
        }
      }
    }
  }
}

public class GameState_ClearStats_Confirm extends GameState
{
  public GameState_ClearStats_Confirm()
  {
    super();
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/clear_stats.xml");
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }

  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      switch(tag)
      {
        case "yes":
          options.getStats().clear();
          gameStateController.popState();
          break;
        case "no":
          gameStateController.popState();
          break;
      }
    }
  }
}

public class GameState_CustomizeSettings extends GameState
{
  private boolean saveDataLoaded;
  private String prefixCoinsCollected = "Coins Collected: ";
  private int coinsCollected;
  private XML custXML;

  public GameState_CustomizeSettings()
  {
    super();
    coinsCollected = options.getCustomizeOptions().getCoinsCollected();
    saveDataLoaded = false;
    custXML = loadXML("xml_data/customize_settings_message.xml");
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/customize_settings.xml");
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();

    if (!saveDataLoaded && gameObjectManager.getGameObjectsByTag("cust_table").size() > 0)
    {
      loadFromSaveData();
    }
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      if (event.getRequiredStringParameter("tag").equals("back"))
      {
        gameStateController.popState();
      }
      else if ((event.getRequiredStringParameter("tag").contains("player")
      || event.getRequiredStringParameter("tag").contains("platform")
      || event.getRequiredStringParameter("tag").contains("coin")
      || event.getRequiredStringParameter("tag").contains("obstacle")
      || event.getRequiredStringParameter("tag").contains("background")
      || event.getRequiredStringParameter("tag").contains("music")))
      {
        String tag = event.getRequiredStringParameter("tag");
        int index = -1;
        if (tag.contains("player"))
          index = 0;
        else if (tag.contains("platform"))
          index = 1;
        else if (tag.contains("coin"))
          index = 2;
        else if (tag.contains("obstacle"))
          index = 3;
        else if (tag.contains("background"))
          index = 4;
        else if (tag.contains("music"))
          index = 5;

        int id = Integer.parseInt(tag.substring(tag.length()-1));
        int custSpriteIndex = index * 4 + id;

        RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponent(ComponentType.RENDER);
        int cost = renderComponent.getCustomSprites().get(custSpriteIndex).cost;
        boolean unlocked = renderComponent.getCustomSprites().get(custSpriteIndex).unlocked;
        String name = renderComponent.getCustomSprites().get(custSpriteIndex).name;

        options.getCustomizeOptions().preparePurchaseScreen(custSpriteIndex, renderComponent);

        if (unlocked) {
          if (index == 0)
          {
            options.getCustomizeOptions().setPlayer(custSpriteIndex);
          }
          else if (index == 1)
          {
            options.getCustomizeOptions().setPlatform(custSpriteIndex, id);
          }
          else if (index == 2)
          {
            options.getCustomizeOptions().setCoin(custSpriteIndex, id);
          }
          else if (index == 3)
          {
            options.getCustomizeOptions().setObstacle(custSpriteIndex, id);
          }
          else if (index == 4)
          {
            options.getCustomizeOptions().setBackground(custSpriteIndex, id);
          }
          else if (index == 5)
          {
            options.getCustomizeOptions().setMusic(custSpriteIndex, id);
          }

          renderComponent.getShapes().get(index+1).translation.x = renderComponent.getCustomSprites().get(custSpriteIndex).sprite.translation.x;
        }
        else
        {
          gameStateController.popState();
          gameStateController.pushState(new GameState_CustomizePurchase(cost, custSpriteIndex, index, id, name));
        }
      }
    }
  }

  private void loadFromSaveData()
  {
    coinsCollected = options.getCustomizeOptions().getCoinsCollected();
    RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("cust_table").get(0).getComponent(ComponentType.RENDER);
    renderComponent.getTexts().get(0).string = prefixCoinsCollected + Integer.toString(coinsCollected);
    saveDataLoaded = true;

    // to set the yellow highlight behind the active items -- find a better way to do this
    XML[] activeItems = new XML[6];
    XML[] customSprites = custXML.getChildren("Render")[0].getChildren("CustomSprite");
    for(int i = 0, j = 0; i < customSprites.length; i++)
    {
      if (customSprites[i].getString("active").equals("true"))
      {
        activeItems[j] = customSprites[i];
        j++;
      }
    }
    RenderComponent renderComponent2 = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponent(ComponentType.RENDER);
    renderComponent2.getShapes();
    for(int i = 0; i < activeItems.length; i++)
    {
      renderComponent2.getShapes().get(i+1).translation.x = activeItems[i].getChildren("SpriteSheet")[0].getFloat("x");
    }
  }
}

public class GameState_CustomizePurchase extends GameState
{
  private boolean saveDataLoaded;
  private int cost;
  private int totalCoins;
  private int custSpriteIndex;
  private int index;
  private int id;
  private String name;

  private SoundFile music;
  private float amplitude;
  private XML musicXML;
  private XML musicXMLComponent;

  public GameState_CustomizePurchase(int _cost, int _custSpriteIndex, int _index, int _id, String _name)
  {
    super();
    saveDataLoaded = false;
    cost = _cost;
    custSpriteIndex = _custSpriteIndex;
    index = _index;
    id = _id;
    name = _name;

    if (index == 5)
    {
      musicXML = loadXML("xml_data/music_player.xml");
      musicXMLComponent = musicXML.getChild("MusicPlayer");
      music = new SoundFile(mainObject, options.getCustomizeOptions().getMusicOptions()[id]);
      music.rate(musicXMLComponent.getFloat("rate"));
      // pan is not supported in stereo. that's fine, just continue.
      try { music.pan(musicXMLComponent.getFloat("pan")); } catch (UnsupportedOperationException e) {}
      amplitude = musicXMLComponent.getFloat("amp");
      music.amp(amplitude * options.getIOOptions().getMusicVolume());
      music.add(musicXMLComponent.getFloat("add"));
      music.loop();
    }
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/customize_purchase.xml");
    totalCoins = options.getCustomizeOptions().getCoinsCollected();
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();

    if (!saveDataLoaded && gameObjectManager.getGameObjectsByTag("message").size() > 0)
    {
      loadFromSaveData();
    }
  }

  @Override public void onExit()
  {
    if (music != null)
      music.stop();
    gameObjectManager.clearGameObjects();
  }

  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      if (event.getRequiredStringParameter("tag").equals("back"))
      {
        gameStateController.popState();
        gameStateController.pushState(new GameState_CustomizeSettings());
      }
      else if (event.getRequiredStringParameter("tag").equals("buy") && totalCoins >= cost)
      {
        options.getCustomizeOptions().setCoinsAfterPurchase(cost);
        options.getCustomizeOptions().purchase(custSpriteIndex);
        totalCoins = options.getCustomizeOptions().getCoinsCollected();
        gameStateController.popState();
        gameStateController.pushState(new GameState_CustomizeSettings());
      }
    }
  }

  private void loadFromSaveData()
  {
    RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponent(ComponentType.RENDER);
    renderComponent.getTexts().get(1).string = "Total Coins: " + Integer.toString(totalCoins);
    renderComponent.getTexts().get(2).string = "This new items costs: " + cost;
    renderComponent.getTexts().get(3).string = name;
    if (totalCoins < cost) {
      renderComponent.getTexts().get(6).string = "You cannot afford this!";
    }
    else
    {
      renderComponent.getTexts().get(6).string = "";
    }
    saveDataLoaded = true;
  }
}

public class GameState_Credits extends GameState
{
  public GameState_Credits()
  {
    super();
  }

  @Override public void onEnter()
  {
    if (options.getCredits().isAnonymous())
    {
      gameObjectManager.fromXML("xml_data/credits_anonymous.xml");
    }
    else
    {
      gameObjectManager.fromXML("xml_data/credits.xml");
    }
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      if (event.getRequiredStringParameter("tag").equals("back"))
      {
        gameStateController.popState();
      }
    }
  }
}

public class GameState_Help extends GameState
{
  public GameState_Help()
  {
    super();
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/help.xml");
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      if (event.getRequiredStringParameter("tag").equals("back"))
      {
        gameStateController.popState();
      }
    }
  }
}

public class GameState_CalibrateMenu extends GameState
{
  public GameState_CalibrateMenu()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/calibrate_menu.xml");

    try {
      emgManager = new EmgManager();
    } catch (MyoNotConnectedException e) {
      println("[WARNING] No Myo Armband detected. Aborting Calibration (Menu)");
      Event event = new Event(EventType.CALIBRATE_FAILURE);
      eventManager.queueEvent(event);
    }
  }
  
  @Override public void update(int deltaTime)
  {
    shape(wbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }
  
  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.CALIBRATE_SUCCESS))
    {
      gameStateController.popState();
      gameStateController.pushState(new GameState_CalibrateSuccess());
    }
    for (IEvent event : eventManager.getEvents(EventType.CALIBRATE_FAILURE))
    {
      gameStateController.popState();
      gameStateController.pushState(new GameState_CalibrateFailureConfirm());
    }
  }
}

public class GameState_CalibrateSuccess extends GameState
{
  private boolean textLoaded;

  public GameState_CalibrateSuccess()
  {
    super();

    textLoaded = false;
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/calibrate_success.xml");
  }
  
  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();

    if (!textLoaded && gameObjectManager.getGameObjectsByTag("message").size() > 0)
    {
      loadText();
    }
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      if (tag.equals("back"))
      {
        gameStateController.popState();
      }
      else if (tag.equals("Calibrate"))
      {
        gameStateController.popState();
        gameStateController.pushState(new GameState_SelectForearm());
      }
    }
  }

  private void loadText()
  {
    RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponent(ComponentType.RENDER);
    renderComponent.getTexts().get(3).string = "Left EMG reading: " + options.getCalibrationData().getCalibrationData().get("LEFT")[1];
    renderComponent.getTexts().get(4).string = "(Using sensor " + (int) options.getCalibrationData().getCalibrationData().get("LEFT")[0] + ")";
    renderComponent.getTexts().get(5).string = "Right EMG reading: " + options.getCalibrationData().getCalibrationData().get("RIGHT")[1];
    renderComponent.getTexts().get(6).string = "(Using sensor " + (int) options.getCalibrationData().getCalibrationData().get("RIGHT")[0] + ")";

    textLoaded = true;
  }
}

public class GameState_CalibrateFailure extends GameState
{
  public GameState_CalibrateFailure()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/calibrate_failure.xml");
    emgManager = new NullEmgManager(); // calibration failed, fallback to stubbed-out readings
    println("[INFO] Falling back to Keyboard controls.");
  }
  
  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      if (tag.equals("back"))
      {
        gameStateController.popState();
      }
      else if (tag.equals("Calibrate"))
      {
        gameStateController.popState();
        gameStateController.pushState(new GameState_SelectForearm());
      }
     
    }
  }
}

public class GameState_CalibrateFailureConfirm extends GameState
{
  public GameState_CalibrateFailureConfirm()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/calibrate_failure_confirm.xml");
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      if (tag.equals("ok"))
      {
        gameStateController.popState();
        gameStateController.pushState(new GameState_CalibrateFailure());
      }
    }
  }
}

public class GameState_SelectForearm extends GameState
{
  public GameState_SelectForearm()
  {
    super();
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/select_forearm.xml");
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,500);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }

  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      if (tag.equals("left"))
      {
        options.getIOOptions().setForearm(Forearm.LEFT);
        gameStateController.popState();
        gameStateController.pushState(new GameState_CalibrateMenu());
      }
      else if (tag.equals("right"))
      {
        options.getIOOptions().setForearm(Forearm.RIGHT);
        gameStateController.popState();
        gameStateController.pushState(new GameState_CalibrateMenu());
      }
      else if (tag.equals("back"))
      {
        gameStateController.popState();
      }
      else
      {
        println("[ERROR] Unrecognized button clicked in GameStates_SelectForearm");
      }
    }
  }
}

public class GameState_MyoNotConnected extends GameState
{
  public GameState_MyoNotConnected()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/confirm_myonotconnected.xml");
  }
  
  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,505);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      if (tag.equals("Play"))
      {
        gameStateController.popState();
        gameStateController.pushState(new GameState_InGame());
      }
      else if (tag.equals("Calibrate"))
      {
        gameStateController.popState();
        gameStateController.pushState(new GameState_CalibrateFailure());
      }
      else if (tag.equals("back"))
      {
        gameStateController.popState();
      }
    }
  }
}

public class GameState_NewUser extends GameState
{
  public GameState_NewUser()
  {
    super();
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/new_user.xml");
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,500);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }

  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      if (tag.equals("ok"))
      {
        gameStateController.pushState(new GameState_MainMenu());
      }
    }
  }
}

public class GameState_SmartSuggestion extends GameState
{
  public GameState_SmartSuggestion()
  {
    super();
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/smart_suggestion.xml");
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,500);
    gameObjectManager.update(deltaTime);
    handleEvents();
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }

  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      if (tag.equals("back"))
      {
        gameStateController.popState();
      }
    }
  }
}

public class GameStateController implements IGameStateController
{
  private LinkedList<GameState> stateStack;
  
  public GameStateController()
  {
    stateStack = new LinkedList<GameState>();
  }
  
  @Override public void update(int deltaTime)
  {
    if (!stateStack.isEmpty())
    {
      stateStack.peekLast().update(deltaTime);
    }
  }
  
  @Override public void pushState(GameState nextState)
  {
    stateStack.addLast(nextState);
    nextState.onEnter();
  }
  
  @Override public void popState()
  {
    IGameState poppedState = stateStack.peekLast();
    poppedState.onExit();
    stateStack.removeLast();
    if (stateStack.isEmpty())
    {
      exit();
    }
  }
  
  @Override public IGameState getCurrentState()
  {
    return stateStack.peekLast();
  }
  
  @Override public IGameState getPreviousState()
  {
    if (stateStack.size() < 2)
    {
      return null;
    }
    return stateStack.get(stateStack.size() - 2);
  }
  
  @Override public IGameObjectManager getGameObjectManager()
  {
    return stateStack.peekLast().getGameObjectManager();
  }
}