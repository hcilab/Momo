//================================================================================================================
// Momo
// Author: David Hanna
//
// Top-level game loop of Momo.
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

import java.awt.event.WindowListener;
import java.awt.Frame;

// The main class needs to be available globally for some subsystems.
Momo mainObject;

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

// Poll EMG globally once per frame to ensure consistency across all visualizations
HashMap<String, Float> rawReadings;
HashMap<String, Float> processedReadings;

// Manages the save_data.xml file.
IOptions options;

// Top-level game variables.
final String LEFT_DIRECTION_LABEL = "LEFT";
final String RIGHT_DIRECTION_LABEL = "RIGHT";
final String JUMP_DIRECTION_LABEL = "JUMP";

// For performance reasons, we want to make sure that only a single MyoAPI is
// every instantiated. Since the constructor can abort half way through, this
// variable is intended to keep track of when an instance has been initalized
// successfully.
boolean MYO_API_SUCCESSFULLY_INITIALIZED = false;

int lastFrameTime;
int lastFrameWidth;
int lastFrameHeight;
int currentFrameWidth;
int currentFrameHeight;

boolean mouseHand;

PShape bg;
PShape opbg;
PShape wbg;
PShape bbg;
PShape obbg;
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

//Sensor Applet setup
SensorGraphApplet sa;

SoundManager soundManager;

//For still platform mode
int stillPlatformCounter = 0;
boolean isRising = false;
SoundObject buttonClickedSound;
SoundObject coinCollectedSound;
boolean fittsLawRecorded;
boolean bonusLevel;
boolean isBonusPractice;
SoundObject bonusMusic;
SoundObject bonusSplash;
SoundObject swingSound;

HashMap<String,PImage> allImages;
Table imageSources;
Zone zone;
Actions actions;

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

enum Actions{
  SWING,
  NORMAL,
}

enum CalibrationMode {
  AUTO,
  MANUAL,
}

void setup()
{
  size(500, 500);
  surface.setAlwaysOnTop(true);
  surface.setResizable(true);
  surface.setTitle("The Falling of Momo");
  surface.setSize(800,800);
  
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
  gameStateController.pushState(new GameState_ArmbandConnectMenu());

  emgManager = new NullEmgManager();

  // initialize with empty values incase armband is never calibrated
  rawReadings = emgManager.pollRaw();
  processedReadings = emgManager.poll();
  
  options = new Options();
  
  lastFrameTime = millis();

  currentFrameWidth = width;
  currentFrameHeight = height;
  
  mouseHand = false;
  fittsLawRecorded = false;
  bonusLevel = false;

  bg = loadShape("images/background/videoBackground.svg");
  opbg =  loadShape("images/background/opacityVideoBackground.svg");
  wbg = loadShape("images/background/whiteBG.svg");
  bbg = loadShape("images/background/underWater.svg");
  obbg = loadShape("images/background/opacityUnderWater.svg");
  
  soundManager = new SoundManager(this);

  buttonClickedSound = soundManager.loadSoundFile("sound_effects/click.mp3");
  buttonClickedSound.setPan(0.0);
  
  coinCollectedSound = soundManager.loadSoundFile("sound_effects/coin01.mp3");
  coinCollectedSound.setPan(0.0);
  
  bonusMusic = soundManager.loadSoundFile("music/bonusLevel.mp3");
  bonusMusic.setPan(0.0);
  
  bonusSplash = soundManager.loadSoundFile("sound_effects/splash2.mp3");
  bonusSplash.setPan(0.0);
  
  swingSound = soundManager.loadSoundFile("sound_effects/hammer.mp3");
  swingSound.setPan(0.0);
  
  allImages = new HashMap<String,PImage>();
  loadAllImages();
  actions = Actions.NORMAL;

  bonusInputCounter = 0;
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
  
  // poll emg-system exactly once per frame for consistency
  if (emgManager.isCalibrated()) {
    rawReadings = emgManager.pollRaw();
    processedReadings = emgManager.poll();
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
  else if (( key == 't' || key == 'T') &&
           (gameStateController.getCurrentState() instanceof GameState_InGame || gameStateController.getCurrentState() instanceof GameState_FittsBonusGame)) {
    // TODO the knowledge that this only occurs in certain games states should really
    // be pushed into the respective game states.
    event = new Event(EventType.TOGGLE_CALIBRATION_DISPLAY);
    eventManager.queueEvent(event);
  }
  
  else if (( key == 'g' || key == 'G') &&
           (gameStateController.getCurrentState() instanceof GameState_InGame || gameStateController.getCurrentState() instanceof GameState_FittsBonusGame)) {
    //add second window for Graph
    event = new Event(EventType.TOGGLE_GRAPH_DISPLAY);
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
