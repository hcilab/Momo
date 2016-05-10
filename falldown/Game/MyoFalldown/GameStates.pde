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
    gameObjectManager.fromXML("main_menu.xml");
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
    gameObjectManager.fromXML("sample_level.xml");
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
  }
  
  @Override public void update(int deltaTime)
  {
  }
  
  @Override public void onExit()
  {
  }
}

public class GameStateController implements IGameStateController, IEventListener
{
  private IGameState gameState_MainMenu;
  private IGameState gameState_InGame;
  private IGameState gameState_OptionsMenu;
  
  private IGameState currentState;
  
  public GameStateController()
  {
    gameState_MainMenu = new GameState_MainMenu();
    gameState_InGame = new GameState_InGame();
    gameState_OptionsMenu = new GameState_OptionsMenu();
    
    goToState(gameState_MainMenu);
    
    eventManager.register(EventType.UP_BUTTON_RELEASED, this);
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
    if (event.getEventType() == EventType.UP_BUTTON_RELEASED && currentState == gameState_MainMenu)
    {
      goToState(gameState_InGame);
    }
  }
}