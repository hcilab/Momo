//========================================================================================
// Author: David Hanna
//
// The abstraction of a game state.
//========================================================================================

abstract public class GameState
{
  // Returns true if the state is done and should be popped.
  abstract public void update(int deltaTime);
}

public class GameState_InGame extends GameState
{
  public GameState_InGame()
  {
    gameObjectManager.fromXML("sample_level.xml");
  }
  
  @Override public void update(int deltaTime)
  {
  }
}