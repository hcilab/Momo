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

public class GameState_InGame extends GameState
{
  public GameState_InGame()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/game.xml");
  }
  
  @Override public void update(int deltaTime)
  {
    shape(bg,250,250,500,500);
    gameObjectManager.update(deltaTime);
    physicsWorld.step(((float)deltaTime) / 1000.0f, velocityIterations, positionIterations);
    handleEvents();
  }
  
  @Override public void onExit()
  {
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
      gameStateController.popState();
      gameStateController.pushState(new GameState_PostGame());
    }
  }
}

public class GameState_PostGame extends GameState
{
  public GameState_PostGame()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/post_game.xml");
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
      else if (tag.equals("play_again"))
      {
        gameStateController.popState();
        gameStateController.pushState(new GameState_InGame());
      }
      else if (tag.equals("gameplay_record"))
      {
        gameStateController.popState();
        gameStateController.pushState(new GameState_OptionsMenu());
        gameStateController.pushState(new GameState_StatsSettings());
      }
    }
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
    shape(opbg,250,250,500,500);
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
  }
}

public class GameState_IOSettings extends GameState
{
  public boolean isPauseScreen;
  public boolean saveDataLoaded;
  public boolean tweakedForPauseOrSettings;

  public GameState_IOSettings()
  {
    super();

    isPauseScreen = false;
    saveDataLoaded = false;
    tweakedForPauseOrSettings = false;
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/io_settings.xml");
    isPauseScreen = gameStateController.getPreviousState() instanceof GameState_InGame;
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,500);
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
          // text (assuming it is the third occurance of text in XML)
          texts.get(2).string = "";

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
    shape(opbg,250,250,500,500);
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
          break;
        case "score_achieved":
          Collections.sort(records, Collections.reverseOrder(record.createByScoreAchievedComparator()));
          break;
        case "time_played":
          Collections.sort(records, Collections.reverseOrder(record.createByTimePlayedComparator()));
          break;
        case "average_speed":
          Collections.sort(records, Collections.reverseOrder(record.createByAverageSpeedComparator()));
          break;
        case "coins_collected":
          Collections.sort(records, Collections.reverseOrder(record.createByCoinsCollectedComparator()));
          break;
        case "date":
          Collections.sort(records, Collections.reverseOrder(record.createByDateComparator()));
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
  private boolean saveDataLoaded = false;
  private String prefixCoinsCollected = "Coins Collected: ";
  private int coinsCollected;
  private XML custXML;

  public GameState_CustomizeSettings()
  {
    super();
    coinsCollected = 0;
    custXML = loadXML("xml_data/customize_settings_message.xml");
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/customize_settings.xml");
    coinsCollected = options.getCustomizeOptions().getCoinsCollected();
  }

  @Override public void update(int deltaTime)
  {
    shape(opbg,250,250,500,500);
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
      if (event.getRequiredStringParameter("tag").contains("player"))
      {
        int num = Integer.parseInt(event.getRequiredStringParameter("tag").substring(6));
        XML player = custXML.getChildren("Render")[0].getChildren("Sprite")[0].getChildren("SpriteSheet")[num];
        options.getCustomizeOptions().setPlayer(player);
      }
    }
  }

  private void loadFromSaveData()
  {
    RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("cust_table").get(0).getComponent(ComponentType.RENDER);
    renderComponent.getTexts().get(0).string = prefixCoinsCollected + Integer.toString(coinsCollected);
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
    shape(wbg,250,250,500,500);
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
  public GameState_CalibrateSuccess()
  {
    super();
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/calibrate_success.xml");
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
      else if (tag.equals("Calibrate"))
      {
        gameStateController.popState();
        gameStateController.pushState(new GameState_CalibrateMenu());
      }
    }
      
    for (IEvent event : eventManager.getEvents(EventType.SLIDER_DRAGGED))
    {
       String tag = event.getRequiredStringParameter("tag");
       float sliderValue = event.getRequiredFloatParameter("sliderValue");
       if (tag.equals("cal_slider"))
       {
        float sensitivityValue = (sliderValue/20)+1;
        options.getCalibration().setCalibrationTime((int)sensitivityValue);
       }
    }
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
      else if (tag.equals("Calibrate"))
      {
        gameStateController.popState();
        gameStateController.pushState(new GameState_CalibrateMenu());
      }
     
    }
    
    for (IEvent event : eventManager.getEvents(EventType.SLIDER_DRAGGED))
    {
       String tag = event.getRequiredStringParameter("tag");
       float sliderValue = event.getRequiredFloatParameter("sliderValue");
       if (tag.equals("cal_slider"))
       {
        float sensitivityValue = (sliderValue/20)+1;
        options.getCalibration().setCalibrationTime((int)sensitivityValue);
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
        gameStateController.popState();
        gameStateController.pushState(new GameState_CalibrateFailure());
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