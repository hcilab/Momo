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
import java.util.Date;
import java.util.Comparator;
import java.util.Collections;

import java.text.SimpleDateFormat;
 
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.Contact;
import org.jbox2d.collision.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.callbacks.ContactListener;
import org.jbox2d.callbacks.ContactImpulse;

import sprites.utils.*;
import sprites.maths.*;
import sprites.*;

import de.voidplus.myo.*;

import processing.sound.SoundFile;

// The main class needs to be available globally for some subsystems.
MyoFalldown mainObject;

// The Event system.
IEventManager eventManager;

// Physics
Vec2 gravity;
World physicsWorld;
FalldownContactListener contactListener;
int velocityIterations;    // Fewer iterations increases performance but accuracy suffers.
int positionIterations;    // More iterations decreases performance but improves accuracy.
                           // Box2D recommends 8 for velocity and 3 for position.
World bonusPhysicsWorld; 

// The controller for the current game state (i.e. main menu, in-game, etc)
IGameStateController gameStateController;

// Handles EMG input
IEmgManager emgManager;

// Manages the save_data.xml file.
IOptions options;

// Top-level game variables.
final String LEFT_DIRECTION_LABEL = "LEFT";
final String RIGHT_DIRECTION_LABEL = "RIGHT";
final String JUMP_DIRECTION_LABEL = "JUMP";

int lastFrameTime;
int lastFrameWidth;
int lastFrameHeight;
int currentFrameWidth;
int currentFrameHeight;

boolean mouseHand;

PShape bg;
PShape opbg;
PShape wbg;
Table tableFittsStats;
Table tableInput;
Table tableRawData;
Table tableBonusInput;
int bonusInputCounter;
int totalRowCountInput;
ArrayList<ArrayList<Integer>> platformLevels;
//This is used to keep track of the gap position and width for Fitts Law Mode 
ArrayList<PVector> platformGapPosition;

PlatformManagerControllerComponent pc;
FittsStatsComponent fsc;
BonusPlatformManager bpc;
BonusScoreComponent bsc;

//For still platform mode
int stillPlatformCounter = 0;
boolean isRising = false;
SoundFile buttonClickedSound;
SoundFile coinCollectedSound;
boolean fittsLawRecorded;

HashMap<String,PImage> allImages;
Table imageSources;
Zone zone;

// used for manual calibration
CalibrationMode calibrationMode;
int leftSensor = -1;
int rightSensor = -1;

enum Forearm {
  LEFT,
  RIGHT,
}

enum Zone { 
  DANGER,
  NEUTRAL,
  HAPPY,
}

enum CalibrationMode {
  AUTO,
  MANUAL,
}

void setup()
{
  size(500, 500);
  surface.setResizable(true);
  surface.setTitle("The Falling of Momo");
  surface.setSize(650,650);
  
  rectMode(CENTER);
  ellipseMode(CENTER);
  imageMode(CENTER);
  shapeMode(CENTER);
  
  mainObject = this;
  
  eventManager = new EventManager();
  
  gravity = new Vec2(0.0, 10.0);
  physicsWorld = new World(gravity); // gravity
  bonusPhysicsWorld = new World(gravity);
  contactListener = new FalldownContactListener();
  physicsWorld.setContactListener(contactListener);
  bonusPhysicsWorld.setContactListener(contactListener);
  velocityIterations = 3;  // Our simple games probably don't need as much iteration.
  positionIterations = 1;
  
  gameStateController = new GameStateController();
  gameStateController.pushState(new GameState_UserLogin());

  emgManager = new NullEmgManager();
  
  options = new Options();
  
  lastFrameTime = millis();

  currentFrameWidth = width;
  currentFrameHeight = height;
  
  mouseHand = false;
  fittsLawRecorded = false;

  bg = loadShape("images/background/rockMountain.svg");
  opbg =  loadShape("images/background/opacityLandscape.svg");
  wbg = loadShape("images/background/whiteBG.svg");
  
  buttonClickedSound = new SoundFile(mainObject, "sound_effects/click.wav");
  buttonClickedSound.rate(1.0);
  try { buttonClickedSound.pan(0.0); } catch (UnsupportedOperationException e) {}
  buttonClickedSound.add(0.0);
  
   coinCollectedSound = new SoundFile(mainObject, "sound_effects/Coin01.aif");
   coinCollectedSound.rate(1.0);
   try {coinCollectedSound.pan(0.0); } catch (UnsupportedOperationException e) {}
   coinCollectedSound.add(0.0);
  
  allImages = new HashMap<String,PImage>();
  loadAllImages();
} 

void draw()
{
  bg = loadShape(options.getCustomizeOptions().getBackground());
  opbg =  loadShape(options.getCustomizeOptions().getOpacityBackground());
  int currentFrameTime = millis();
  int deltaTime = currentFrameTime - lastFrameTime;
  lastFrameTime = currentFrameTime;
  
  lastFrameWidth = currentFrameWidth;
  lastFrameHeight = currentFrameHeight;
  currentFrameWidth = width;
  currentFrameHeight = height;
  
  if (width < 250)
  {
    surface.setSize(250, height);
  }
  if (height < 250)
  {
    surface.setSize(width, 250);
  }
  
  if (currentFrameWidth != lastFrameWidth || currentFrameHeight != lastFrameHeight)
  {
    return;
  }
  
  scale(width / 500.0, height / 500.0);

  if (deltaTime > 100)
  {
    deltaTime = 16;
  }
  
  eventManager.update();
  gameStateController.update(deltaTime);
  
  if (mouseHand)
  {
    cursor(HAND);
  }
  else
  {
    cursor(ARROW);
  }
  
  mouseHand = false;
}

void keyPressed()
{
  Event event;
  
  if (key == ESC)
  {
    event = new Event(EventType.ESCAPE_PRESSED);
    eventManager.queueEvent(event);
    key = 0; // override so that signal is not propogated on to kill window
    return;
  }
  else if (key == CODED)
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
      case DOWN:
        event = new Event(EventType.DOWN_BUTTON_PRESSED);
        eventManager.queueEvent(event);
        return;
    }
  }
  else if (key == ' ')
  {
    event = new Event(EventType.SPACEBAR_PRESSED);
    eventManager.queueEvent(event);
    return;
  }
  else if (gameStateController.getCurrentState() instanceof GameState_InGame && ( key == 't' || key == 'T')) {
    event = new Event(EventType.TOGGLE_CALIBRATION_DISPLAY);
    eventManager.queueEvent(event);
  }
}

void keyReleased()
{
  Event event;
  
  if (key == ESC)
  {
    key = 0; // override so that signal is not propogated on to kill window
    return;
  }
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

void mousePressed()
{
  Event event = new Event(EventType.MOUSE_PRESSED);
  event.addIntParameter("mouseX", mouseX);
  event.addIntParameter("mouseY", mouseY);
  eventManager.queueEvent(event);
}

void mouseClicked()
{
  Event event = new Event(EventType.MOUSE_CLICKED);
  event.addIntParameter("mouseX", mouseX);
  event.addIntParameter("mouseY", mouseY);
  eventManager.queueEvent(event);
}

void mouseDragged()
{
  Event event = new Event(EventType.MOUSE_DRAGGED);
  event.addIntParameter("mouseX", mouseX);
  event.addIntParameter("mouseY", mouseY);
  eventManager.queueEvent(event);
}

void mouseReleased()
{
  Event event = new Event(EventType.MOUSE_RELEASED);
  event.addIntParameter("mouseX", mouseX);
  event.addIntParameter("mouseY", mouseY);
  eventManager.queueEvent(event);
}

void mouseMoved()
{
  Event event = new Event(EventType.MOUSE_MOVED);
  event.addIntParameter("mouseX", mouseX);
  event.addIntParameter("mouseY", mouseY);
  eventManager.queueEvent(event);
  return;
}

void myoOnEmg(Myo myo, long nowMilliseconds, int[] sensorData) {
  emgManager.onEmg(nowMilliseconds, sensorData);
}

class FalldownContactListener implements ContactListener
{
  @Override public void beginContact(Contact contact)
  {
    IGameObject objectA = (IGameObject)contact.getFixtureA().getUserData();
    IGameObject objectB = (IGameObject)contact.getFixtureB().getUserData();
    
    RigidBodyComponent rigidBodyA = (RigidBodyComponent)objectA.getComponent(ComponentType.RIGID_BODY);
    RigidBodyComponent rigidBodyB = (RigidBodyComponent)objectB.getComponent(ComponentType.RIGID_BODY);
    
    rigidBodyA.onCollisionEnter(objectB);
    rigidBodyB.onCollisionEnter(objectA);
  }
  
  @Override public void endContact(Contact contact)
  {
    IGameObject objectA = (IGameObject)contact.getFixtureA().getUserData();
    IGameObject objectB = (IGameObject)contact.getFixtureB().getUserData();

    RigidBodyComponent rigidBodyA = (RigidBodyComponent)objectA.getComponent(ComponentType.RIGID_BODY);
    RigidBodyComponent rigidBodyB = (RigidBodyComponent)objectB.getComponent(ComponentType.RIGID_BODY);

    rigidBodyA.onExitEvent(objectB);
    rigidBodyB.onExitEvent(objectA);
  }
  
  @Override public void preSolve(Contact contact, Manifold oldManifold)
  {
  }
  
  @Override public void postSolve(Contact contact, ContactImpulse impulse)
  {
  }
}

void loadAllImages(){
  imageSources = loadTable("images/imagesSource.csv");
  for(int i = 1; i<imageSources.getRowCount();i++){
    TableRow row = imageSources.getRow(i); 
    allImages.put(row.getString(0), loadImage(row.getString(0)));
  }  
}