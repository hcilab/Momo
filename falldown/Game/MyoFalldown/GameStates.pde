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
  GCustomSlider musicVolSlider;
  GCustomSlider effectsVolSlider;
  GCustomSlider leftEMGSlider;
  GCustomSlider rightEMGSlider;

  public GameState_IOSettings()
  {
    super();
  }

  @Override public void onEnter()
  {
    gameObjectManager.fromXML("xml_data/io_settings.xml");
    musicVolSlider = new GCustomSlider(mainObject,275,140,200,50,"images/blue_arrow_and_slider");
    musicVolSlider.setShowDecor(false,true,true,true);
    musicVolSlider.setNbrTicks(5);
    int musicVal = (int)(optionsMenu.getIOSettings().getMusicVol() * 100.0);
    musicVolSlider.setLimits(musicVal, 0, 100);

    effectsVolSlider = new GCustomSlider(mainObject,275,195,200,50,"images/blue_arrow_and_slider");
    effectsVolSlider.setShowDecor(false,true,true,true);
    effectsVolSlider.setNbrTicks(5);
    int seVal = (int)(optionsMenu.getIOSettings().getSEVol() * 100.0);
    effectsVolSlider.setLimits(seVal, 0, 100);

    leftEMGSlider = new GCustomSlider(mainObject,275,290,200,50,"images/blue_arrow_and_slider");
    leftEMGSlider.setShowDecor(false,true,false,false);
    leftEMGSlider.setNbrTicks(5);
    int leftVal = (int)(optionsMenu.getIOSettings().getLeftSens() * 5.0);
    leftEMGSlider.setLimits(leftVal, 0.2, 5.0);

    rightEMGSlider = new GCustomSlider(mainObject,275,345,200,50,"images/blue_arrow_and_slider");
    rightEMGSlider.setShowDecor(false,true,false,false);
    rightEMGSlider.setNbrTicks(5);
    int rightVal = (int)(optionsMenu.getIOSettings().getRightSens() * 5.0);
    rightEMGSlider.setLimits(rightVal, 0.2, 5.0);
  }

  @Override public void update(int deltaTime)
  {
    gameObjectManager.update(deltaTime);
    handleEvents();
  }

  @Override public void onExit()
  {
    gameObjectManager.clearGameObjects();
    musicVolSlider.dispose();
    effectsVolSlider.dispose();
    leftEMGSlider.dispose();
    rightEMGSlider.dispose();
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