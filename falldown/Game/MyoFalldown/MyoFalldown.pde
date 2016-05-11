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
import de.voidplus.myo.*;

// The GameObject system.
IGameObjectManager gameObjectManager;

// The Event system.
IEventManager eventManager;

// Physics
Vec2 gravity;
World physicsWorld;
FalldownContactListener contactListener;
int velocityIterations;    // Fewer iterations increases performance but accuracy suffers.
int positionIterations;    // More iterations decreases performance but improves accuracy.
                           // Box2D recommends 8 for velocity and 3 for position.

// The controller for the current game state (i.e. main menu, in-game, etc)
IGameStateController gameStateController;

// Handles EMG input
IEmgManager emgManager;

// Top-level game loop variables.
int lastFrameTime;

void setup()
{
  size(500, 500);
  //fullScreen();
  
  rectMode(CENTER);
  ellipseMode(CENTER);
  imageMode(CENTER);
  shapeMode(CENTER);
  
  gameObjectManager = new GameObjectManager();
  
  eventManager = new EventManager();
  
  gravity = new Vec2(0.0, 10.0);
  physicsWorld = new World(gravity); // gravity
  contactListener = new FalldownContactListener();
  physicsWorld.setContactListener(contactListener);
  velocityIterations = 6;  // Our simple games probably don't need as much iteration.
  positionIterations = 2;
  
  gameStateController = new GameStateController();

  emgManager = createEmgManager(this);
  emgManager.calibrate();
  
  lastFrameTime = millis();
} 

void draw()
{
  int currentFrameTime = millis();
  int deltaTime = currentFrameTime - lastFrameTime;
  lastFrameTime = currentFrameTime;
  
  background(255, 255, 255);
  
  // Solves debugger time distortion, or if something goes wrong and the game freezes for a moment before continuing.
  if (deltaTime > 20)
  {
    deltaTime = 16;
  }
  
  eventManager.sendEvents();
  gameStateController.update(deltaTime);
}

void myoOnEmg(Myo myo, long nowMilliseconds, int[] sensorData) {
  emgManager.onEmg(nowMilliseconds, sensorData);
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

class FalldownContactListener implements ContactListener
{
  @Override public void beginContact(Contact contact)
  {
    IGameObject objectA = (IGameObject)contact.getFixtureA().getUserData();
    IGameObject objectB = (IGameObject)contact.getFixtureB().getUserData();
    
    RigidBodyComponent rigidBodyA = (RigidBodyComponent)objectA.getComponent(ComponentType.RIGID_BODY);
    RigidBodyComponent rigidBodyB = (RigidBodyComponent)objectB.getComponent(ComponentType.RIGID_BODY);
    
    rigidBodyA.onCollisionEnter(contact, objectB);
    rigidBodyB.onCollisionEnter(contact, objectA);
  }
  
  @Override public void endContact(Contact contact)
  {
  }
  
  @Override public void preSolve(Contact contact, Manifold oldManifold)
  {
  }
  
  @Override public void postSolve(Contact contact, ContactImpulse impulse)
  {
  }
}