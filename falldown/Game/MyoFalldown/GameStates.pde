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
        gameStateController.pushState(new GameState_InGame());
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
        gameStateController.popState();
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

public class GameState_IOSettings extends GameState
{
  public boolean saveDataLoaded;

  public GameState_IOSettings()
  {
    super();

    saveDataLoaded = false;
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/io_settings.xml");
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
        if (options.getIOOptions().getIOInputMode() == IOInputMode.MAX)
        {
          options.getIOOptions().setIOInputMode(IOInputMode.DIFFERENCE);
          RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponent(ComponentType.RENDER);
          renderComponent.getShapes().get(4).translation.y = renderComponent.getShapes().get(4).translation.y - 45;
        }
      }
      else if (tag.equals("max"))
      {
        if (options.getIOOptions().getIOInputMode() == IOInputMode.DIFFERENCE)
        {
          options.getIOOptions().setIOInputMode(IOInputMode.MAX);
          RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponent(ComponentType.RENDER);
          renderComponent.getShapes().get(4).translation.y = renderComponent.getShapes().get(4).translation.y + 45;
        }
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
    }
  }

  private void loadFromSaveData()
  {
    IOInputMode mode = options.getIOOptions().getIOInputMode();
    RenderComponent renderComponent = (RenderComponent) gameObjectManager.getGameObjectsByTag("message").get(0).getComponent(ComponentType.RENDER);
    if (renderComponent.getShapes().get(4).translation.y == 0)
    {
      if (mode == IOInputMode.DIFFERENCE)
      {
        renderComponent.getShapes().get(4).translation.y = renderComponent.getShapes().get(4).translation.y + 375;
      }
      else if (mode == IOInputMode.MAX)
      {
        renderComponent.getShapes().get(4).translation.y = renderComponent.getShapes().get(4).translation.y + 420;
      }
    }
    saveDataLoaded = true;
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
    ArrayList<IGameObject> tableRows = gameStateController.getGameObjectManager().getGameObjectsByTag("stats_row");

    for (int i=0; i<tableRows.size(); i++)
    {
      IComponent component = tableRows.get(i).getComponent(ComponentType.RENDER);
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

public class GameState_CustomizeSettings extends GameState
{
  public GameState_CustomizeSettings()
  {
    super();
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/customize_settings.xml");
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

public class GameState_Credits extends GameState
{
  public GameState_Credits()
  {
    super();
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/credits.xml");
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
    for (IEvent event : eventManager.getEvents(EventType.CALIBRATE_SUCCESS))
    {
      gameStateController.popState();
      gameStateController.pushState(new GameState_CalibrateSuccess());
    }
    for (IEvent event : eventManager.getEvents(EventType.CALIBRATE_FAILURE))
    {
      gameStateController.popState();
      gameStateController.pushState(new GameState_CalibrateFailure());
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
    nextState.onEnter();
    stateStack.addLast(nextState);
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
  
  @Override public IGameObjectManager getGameObjectManager()
  {
    return stateStack.peekLast().getGameObjectManager();
  }
}