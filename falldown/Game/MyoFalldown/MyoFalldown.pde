//================================================================================================================
// MyoFalldown
// Author: David Hanna
//
// Top-level game loop of Myo Falldown.
//================================================================================================================

// Includes are available project-wide, so they are collected here.
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Map;

import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.Contact;
import org.jbox2d.collision.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.callbacks.ContactListener;
import org.jbox2d.callbacks.ContactImpulse;

// The GameObject system.
IGameObjectManager gameObjectManager;

// The Event system.
IEventManager eventManager;

// Physics
Vec2 gravity;
World physicsWorld;
int velocityIterations;    // Fewer iterations increases performance but accuracy suffers.
int positionIterations;    // More iterations decreases performance but improves accuracy.
                           // Box2D recommends 8 for velocity and 3 for position.

// The current game state (main menu, in-game, options, etc).
GameState gameState;

// Top-level game loop variables.
int lastFrameTime;

void setup()
{
  size(500, 500);
  //fullScreen();
  
  rectMode(CENTER);
  ellipseMode(CENTER);
  imageMode(CENTER);
  
  gameObjectManager = new GameObjectManager();
  
  eventManager = new EventManager();
  
  gravity = new Vec2(0.0, 10.0);
  physicsWorld = new World(gravity); // gravity
  velocityIterations = 6;  // Our simple games probably don't need as much iteration.
  positionIterations = 2;
  
  // TO DO: create a state machine to handle this such that states can determine their own next state.
  gameState = new GameState_InGame();
  
  lastFrameTime = millis();
}

void draw()
{
  int currentFrameTime = millis();
  int deltaTime = currentFrameTime - lastFrameTime;
  lastFrameTime = currentFrameTime;
  
  background(255, 255, 255);
  scale(10.0);
  
  // Solves debugger time distortion, or if something goes wrong and the game freezes for a moment before continuing.
  if (deltaTime > 20)
  {
    deltaTime = 16;
  }
  
  gameObjectManager.update(deltaTime);
  eventManager.sendEvents();
  physicsWorld.step(((float)deltaTime) / 1000.0f, velocityIterations, positionIterations);
  gameState.update(deltaTime);
}

void keyPressed()
{
  Event event;
  
  if (key == CODED)
  {
    switch (keyCode)
    {
      case UP:
        event = new Event(EventType.UP_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
        
      case LEFT:
        event = new Event(EventType.LEFT_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
        
      case RIGHT:
        event = new Event(EventType.RIGHT_BUTTON_PRESSED);
        eventManager.queueEvent(event); 
        return;
    }
  }
}

void keyReleased()
{
  Event event;
  
  if (key == CODED)
  {
    switch (keyCode)
    {
      case UP:
        event = new Event(EventType.UP_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
        
      case LEFT:
        event = new Event(EventType.LEFT_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
        
      case RIGHT:
        event = new Event(EventType.RIGHT_BUTTON_RELEASED);
        eventManager.queueEvent(event);
        return;
    }
  }
}