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
}

public interface IGameStateController
{
  public void update(int deltaTime);
  public void goToState(IGameState nextState);
}


//-------------------------------------------------------------------------------
// IMPLEMENTATION
//-------------------------------------------------------------------------------

public class GameState_MainMenu implements IGameState
{
  public GameState_MainMenu()
  {
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/main_menu.xml");
  }
  
  @Override public void update(int deltaTime)
  {
    gameObjectManager.update(deltaTime);
  }
  
  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
}

public class GameState_InGame implements IGameState
{
  public GameState_InGame()
  {
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/game.xml");
  }
  
  @Override public void update(int deltaTime)
  {
    gameObjectManager.update(deltaTime);
    physicsWorld.step(((float)deltaTime) / 1000.0f, velocityIterations, positionIterations);
  }
  
  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
}

public class GameState_OptionsMenu implements IGameState
{
  public GameState_OptionsMenu()
  {
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/options_menu.xml");
  }
  
  @Override public void update(int deltaTime)
  {
    gameObjectManager.update(deltaTime);
  }
  
  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
}

public class GameState_GameSettings implements IGameState
{
  public GameState_GameSettings()
  {
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/game_settings.xml");
  }

  @Override public void update(int deltaTime)
  {
    gameObjectManager.update(deltaTime);
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
}

public class GameState_IOSettings implements IGameState
{
  public GameState_IOSettings()
  {
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/io_settings.xml");
  }

  @Override public void update(int deltaTime)
  {
    gameObjectManager.update(deltaTime);
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
}

public class GameState_StatsSettings implements IGameState
{
  public GameState_StatsSettings()
  {
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/stats_settings.xml");
  }

  @Override public void update(int deltaTime)
  {
    gameObjectManager.update(deltaTime);
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
}

public class GameState_CustomizeSettings implements IGameState
{
  public GameState_CustomizeSettings()
  {
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/customize_settings.xml");
  }

  @Override public void update(int deltaTime)
  {
    gameObjectManager.update(deltaTime);
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
}

public class GameState_CalibrateMenu implements IGameState
{
  public GameState_CalibrateMenu()
  {
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/calibrate_menu.xml");

    try {
      emgManager = new EmgManager();
    } catch (MyoNotConnectedException e) {
      println("[WARNING] No Myo Armband detected. Aborting Calibration.");
      Event event = new Event(EventType.CALIBRATE_FAILURE);
      eventManager.queueEvent(event);
    }
  }
  
  @Override public void update(int deltaTime)
  {
    gameObjectManager.update(deltaTime);

    println("[INFO] Calibrating...");
    emgManager.calibrate();
  }
  
  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
}

public class GameState_CalibrateSuccess implements IGameState
{
  public GameState_CalibrateSuccess()
  {
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/calibrate_success.xml");
  }
  
  @Override public void update(int deltaTime)
  {
    gameObjectManager.update(deltaTime);
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
}

public class GameState_CalibrateFailure implements IGameState
{
  public GameState_CalibrateFailure()
  {
  }
  
  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/calibrate_failure.xml");
    emgManager = new NullEmgManager(); // calibration failed, fallback to stubbed-out readings
    println("[INFO] Falling back to Keyboard controls.");
  }
  
  @Override public void update(int deltaTime)
  {
    gameObjectManager.update(deltaTime);
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
}

public class GameStateController implements IGameStateController, IEventListener
{
  private IGameState gameState_MainMenu;
  private IGameState gameState_InGame;
  private IGameState gameState_OptionsMenu;
  private IGameState gameState_GameSettings;
  private IGameState gameState_IOSettings;
  private IGameState gameState_StatsSettings;
  private IGameState gameState_CustomizeSettings;
  private IGameState gameState_CalibrateMenu;
  private IGameState gameState_CalibrateSuccess;
  private IGameState gameState_CalibrateFailure;
  
  private IGameState currentState;
  
  public GameStateController()
  {
    gameState_MainMenu = new GameState_MainMenu();
    gameState_InGame = new GameState_InGame();
    gameState_OptionsMenu = new GameState_OptionsMenu();
    gameState_GameSettings = new GameState_GameSettings();
    gameState_IOSettings = new GameState_IOSettings();
    gameState_StatsSettings = new GameState_StatsSettings();
    gameState_CustomizeSettings = new GameState_CustomizeSettings();
    gameState_CalibrateMenu = new GameState_CalibrateMenu();
    gameState_CalibrateSuccess = new GameState_CalibrateSuccess();
    gameState_CalibrateFailure = new GameState_CalibrateFailure();
    
    goToState(gameState_MainMenu);
    
    eventManager.register(EventType.UP_BUTTON_RELEASED, this);
    eventManager.register(EventType.LEFT_BUTTON_RELEASED, this);
    eventManager.register(EventType.RIGHT_BUTTON_RELEASED, this);
    eventManager.register(EventType.MOUSE_CLICKED, this);
    eventManager.register(EventType.BUTTON_CLICKED, this);
    eventManager.register(EventType.GAME_OVER, this);
    eventManager.register(EventType.CALIBRATE_SUCCESS, this);
    eventManager.register(EventType.CALIBRATE_FAILURE, this);
    eventManager.register(EventType.CALIBRATE_DONE, this);
    eventManager.register(EventType.CALIBRATE_RETRY, this);
  }
  
  @Override public void update(int deltaTime)
  {
    currentState.update(deltaTime);
  }
  
  @Override public void goToState(IGameState nextState)
  {
    if (nextState == currentState)
    {
      return;
    }
    
    if (currentState != null)
    {
      currentState.onExit();
    }
    
    currentState = nextState;
    currentState.onEnter();
  }
  
  @Override public void handleEvent(IEvent event)
  {
    if (currentState == gameState_MainMenu)
    {
      if (event.getEventType() == EventType.LEFT_BUTTON_RELEASED)
      {
        goToState(gameState_InGame);
      }
      else if (event.getEventType() == EventType.RIGHT_BUTTON_RELEASED)
      {
        goToState(gameState_OptionsMenu);
      }
    }
    else if (currentState == gameState_InGame)
    {
      if (event.getEventType() == EventType.GAME_OVER)
      {
        goToState(gameState_MainMenu);
      }
    }
    else if (currentState == gameState_OptionsMenu)
    {
      if (event.getEventType() == EventType.UP_BUTTON_RELEASED)
      {
        goToState(gameState_MainMenu);
      }
      else if (event.getEventType() == EventType.BUTTON_CLICKED)
      {
        String tag = event.getRequiredStringParameter("tag");
        if (tag.equals("GameSettings"))
        {
          goToState(gameState_GameSettings);
        }
        else if (tag.equals("IOSettings"))
        {
          goToState(gameState_IOSettings);
        }
        else if (tag.equals("StatsSettings"))
        {
          goToState(gameState_StatsSettings);
        }
        else if (tag.equals("CustomizeSettings"))
        {
          goToState(gameState_CustomizeSettings);
        }
      }
    }
    else if (currentState == gameState_GameSettings)
    {
      if (event.getEventType() == EventType.UP_BUTTON_RELEASED)
      {
        goToState(gameState_OptionsMenu);
      }
    }
    else if (currentState == gameState_IOSettings)
    {
      if (event.getEventType() == EventType.UP_BUTTON_RELEASED)
      {
        goToState(gameState_OptionsMenu);
      }
    }
    else if (currentState == gameState_StatsSettings)
    {
      if (event.getEventType() == EventType.UP_BUTTON_RELEASED)
      {
        goToState(gameState_OptionsMenu);
      }
    }
    else if (currentState == gameState_CustomizeSettings)
    {
      if (event.getEventType() == EventType.UP_BUTTON_RELEASED)
      {
        goToState(gameState_OptionsMenu);
      }
    }
    else if (currentState == gameState_CalibrateMenu)
    {
      if (event.getEventType() == EventType.CALIBRATE_SUCCESS)
      {
        goToState(gameState_CalibrateSuccess);
      }
      else if (event.getEventType() == EventType.CALIBRATE_FAILURE)
      {
        goToState(gameState_CalibrateFailure);
      }
    }
    else if (currentState == gameState_CalibrateSuccess || currentState == gameState_CalibrateFailure)
    {
      if (event.getEventType() == EventType.BUTTON_CLICKED)
      {
        String tag = event.getRequiredStringParameter("tag");
        if (tag.equals("MainMenu"))
        {
          goToState(gameState_MainMenu);
        }
        else if (tag.equals("Calibrate"))
        {
          goToState(gameState_CalibrateMenu);
        }
      }
    }
  }
}