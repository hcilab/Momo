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

public abstract class GameState implements IGameState, IEventListener
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
  
  @Override abstract public void handleEvent(IEvent event);
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
    gameObjectManager.update(deltaTime);
  }
  
  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.BUTTON_CLICKED)
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
          gameStateController.pushState(new GameState_CalibrateMenu());
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
    gameObjectManager.update(deltaTime);
    physicsWorld.step(((float)deltaTime) / 1000.0f, velocityIterations, positionIterations);
  }
  
  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.GAME_OVER)
    {
      gameStateController.popState();
      //gameStateController.pushState(new GameState_PostGame());
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
    gameObjectManager.update(deltaTime);
  }
  
  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.UP_BUTTON_RELEASED)
    {
      gameStateController.popState();
    }
    else if (event.getEventType() == EventType.BUTTON_CLICKED)
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
    gameObjectManager.update(deltaTime);
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.UP_BUTTON_RELEASED)
    {
      gameStateController.popState();
    }
  }
}

public class GameState_IOSettings extends GameState
{
  public GameState_IOSettings()
  {
    super();
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
  
  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.UP_BUTTON_RELEASED)
    {
      gameStateController.popState();
    }
  }
}

public class GameState_StatsSettings extends GameState
{
  public GameState_StatsSettings()
  {
    super();
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
  
  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.UP_BUTTON_RELEASED)
    {
      gameStateController.popState();
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
    gameObjectManager.update(deltaTime);
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.UP_BUTTON_RELEASED)
    {
      gameStateController.popState();
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
    gameObjectManager.update(deltaTime);
  }
  
  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.CALIBRATE_SUCCESS)
    {
      gameStateController.popState();
      gameStateController.pushState(new GameState_CalibrateSuccess());
    }
    else if (event.getEventType() == EventType.CALIBRATE_FAILURE)
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
    gameObjectManager.update(deltaTime);
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.BUTTON_CLICKED)
    {
      String tag = event.getRequiredStringParameter("tag");
      if (tag.equals("MainMenu"))
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
    gameObjectManager.update(deltaTime);
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
  }
  
  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.BUTTON_CLICKED)
    {
      String tag = event.getRequiredStringParameter("tag");
      if (tag.equals("MainMenu"))
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

public class GameStateController implements IGameStateController, IEventListener
{
  private LinkedList<GameState> stateStack;
  
  public GameStateController()
  {
    stateStack = new LinkedList<GameState>();
    
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
    
    pushState(new GameState_MainMenu());
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
  
  @Override public void handleEvent(IEvent event)
  {
    stateStack.peekLast().handleEvent(event);
  }
}