//Imports.
import java.awt.event.KeyEvent;
import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import KinectPV2.*;

//Initial Variables
Box2DProcessing box2d;
ArrayList clouds, bugs;
PFont f;
PlayerDino dino;
int numBugs, numClouds, flapCounter, treeY, failX, failY;
boolean gameOver, start, doFlap;
float score;
PImage tree, sit, fail;
AudioSample flapSound, gameOverSound;
Minim minim;
KinectPV2 kinect;

void setup() {
  size(600,600);
  
  gameOver = false;
  start = false;
  score = 0;
  
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  f = createFont("Arial",16,true);
  
  dino = new PlayerDino(200,100);
  doFlap = false;
  flapCounter = 50;
  treeY = 125;
  failX = 0;
  failY = 0;
  tree = loadImage("tree.png");
  sit = loadImage("archaeSit.png");
  fail = loadImage("archaeFail.png");
  
  clouds = new ArrayList();
  clouds.add(new Cloud(100,300,2));
  clouds.add(new Cloud(300,200,2));
  clouds.add(new Cloud(160,600,2));
  clouds.add(new Cloud(300,700,2));
  clouds.add(new Cloud(200,400,2));
  clouds.add(new Cloud(350,800,2));
  
  numBugs = 6;
  bugs = new ArrayList();
  for (int i = 0; i < numBugs; i++) {
      bugs.add(new Bug());
  }
   
  minim = new Minim(this);
  flapSound = minim.loadSample("flap1.mp3", 5048);
  gameOverSound = minim.loadSample("gameover.wav", 5048);
   
  kinect = new KinectPV2(this);
  kinect.enableDepthMaskImg(true);
  kinect.enableSkeletonDepthMap(true); 
  kinect.init();
  
}// End setup.

void draw() {
  background(146,214,235);
  
  if (gameOver || !start) {
    for (int i = 0; i < clouds.size(); i++) {
      Cloud clo = (Cloud)clouds.get(i);
      clo.display();
    }
  
    for (int i = 0; i < bugs.size(); i++) {
      Bug obs = (Bug)bugs.get(i);
      obs.display();
    }
  }
  
  if (gameOver) {
    textFont(f,18);
    text("Ft. fallen: " + score,455,25);
    if (failY > 620) {
      fill(0);
      text("Game Over.",220,250);
      text("Press enter to try again!",175,300);
      textFont(f,28);
      text((int)score + " Ft.",235,350);
      start = false;
    } 
    else {
      image(fail,failX,failY);
      failY+=4;
    }
  }
  
  if (!start && !gameOver) {
    fill(0);
    textFont(f,18);
    text("Survive for as long as possible!",175,250);
    text("Press enter to start.",220,300);
    text("WASD or Arrow keys to move left and right, space key to flap!",50,350);
    image(sit,275,65);
    image(tree,125,treeY);
  }
  
  if (start && !gameOver) {  
    box2d.step();
    score += 0.025;
    
    ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();
  
    for (int i = 0; i < skeletonArray.size(); i++) {
      KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
      KJoint[] joints = skeleton.getJoints();
      
      //Move Left.
      if (joints[KinectPV2.JointType_HandTipRight].getY() > joints[KinectPV2.JointType_HandTipLeft].getY()) {
        dino.body.setLinearVelocity(new Vec2(8,dino.body.getLinearVelocity().y));
        dino.body.setAngularVelocity(-5);
      }
      //Move Right.
      if (joints[KinectPV2.JointType_HandTipLeft].getY() > joints[KinectPV2.JointType_HandTipRight].getY()) {
        dino.body.setLinearVelocity(new Vec2(-8,dino.body.getLinearVelocity().y));
        dino.body.setAngularVelocity(5); 
      }
      //Stop moving.
      if (joints[KinectPV2.JointType_HandTipLeft].getY()-25 < joints[KinectPV2.JointType_HandTipRight].getY() && joints[KinectPV2.JointType_HandTipLeft].getY()+25 > joints[KinectPV2.JointType_HandTipRight].getY()) { 
        dino.body.setLinearVelocity(new Vec2(0,dino.body.getLinearVelocity().y));
        dino.body.setAngularVelocity(0);
      }
      //Stop moving.
      if (joints[KinectPV2.JointType_HandTipLeft].getY() > joints[KinectPV2.JointType_HandTipRight].getY()-25 && joints[KinectPV2.JointType_HandTipLeft].getY() < joints[KinectPV2.JointType_HandTipRight].getY()+25) { 
        dino.body.setLinearVelocity(new Vec2(0,dino.body.getLinearVelocity().y));
        dino.body.setAngularVelocity(0);
      }
      //Flap.
      if (joints[KinectPV2.JointType_HandTipLeft].getY() > 250 && joints[KinectPV2.JointType_HandTipRight].getY() > 250) {
        dino.body.setLinearVelocity(new Vec2(dino.body.getLinearVelocity().x,0));
        dino.body.applyLinearImpulse(new Vec2(0, 120f), new Vec2(dino.body.getWorldCenter().x,dino.body.getWorldCenter().y), true);
        flapSound.stop();
        doFlap = true;
        flapSound.trigger();
      }
    }
    
    if (doFlap) { 
      flapCounter--;
      if (flapCounter == 25 || flapCounter == 45) { flapSound.trigger(); }
      if (flapCounter <= 0) { 
        doFlap = false; 
        flapCounter = 50;
      } 
    }
  
    for (int i = 0; i < clouds.size(); i++) {
      Cloud clo = (Cloud)clouds.get(i);
      clo.run();
     }
   
     for (int i = 0; i < bugs.size(); i++) {
       Bug obs = (Bug)bugs.get(i);
       obs.run();
     }
     if (treeY > -75) { image(tree,125,treeY); treeY--; } 
     dino.display();
     textFont(f,18);
     text("Ft. fallen: " + score,455,25);
  }
  
}// End draw.

void keyPressed() {
  if (keyCode == LEFT || keyCode == KeyEvent.VK_A) {
    dino.body.setLinearVelocity(new Vec2(-8,dino.body.getLinearVelocity().y));
    dino.body.setAngularVelocity(5); 
  }
    
  if (keyCode == RIGHT || keyCode == KeyEvent.VK_D) {
    dino.body.setLinearVelocity(new Vec2(8,dino.body.getLinearVelocity().y));
    dino.body.setAngularVelocity(-5);
  }
  
  if (keyCode == KeyEvent.VK_SPACE) {
    dino.body.setLinearVelocity(new Vec2(dino.body.getLinearVelocity().x,0));
    dino.body.applyLinearImpulse(new Vec2(0, 120f), new Vec2(dino.body.getWorldCenter().x,dino.body.getWorldCenter().y), true);
    flapSound.stop();
    doFlap = true;
    flapSound.trigger();
  }
  
  if (!start && keyCode == KeyEvent.VK_ENTER) {
    start = true;
  }
  
  if (gameOver && keyCode == KeyEvent.VK_ENTER) {
    gameOver = false;
    start = true;
  
    box2d = new Box2DProcessing(this);
    box2d.createWorld();
  
    dino = new PlayerDino(200,100);
    score = 0;
    treeY = 125;
    flapCounter = 50;
    
    clouds = new ArrayList();
    clouds.add(new Cloud(100,300,2));
    clouds.add(new Cloud(300,200,2));
    clouds.add(new Cloud(160,600,2));
    clouds.add(new Cloud(300,700,2));
    clouds.add(new Cloud(200,400,2));
    clouds.add(new Cloud(350,800,2));
    
    bugs = new ArrayList();
    for (int i = 0; i < numBugs; i++) {
      bugs.add(new Bug());
     }
  }
  
}// End KeyPressed.

void keyReleased() {
  if (keyCode == LEFT || keyCode == KeyEvent.VK_A) {
    dino.body.setLinearVelocity(new Vec2(0,dino.body.getLinearVelocity().y));
    dino.body.setAngularVelocity(0);
  }
    
  if (keyCode == RIGHT || keyCode == KeyEvent.VK_D) {
    dino.body.setLinearVelocity(new Vec2(0,dino.body.getLinearVelocity().y));
    dino.body.setAngularVelocity(0);
  }
}// End KeyReleased.


//This stuff could be used to show the skeleton/location of the person playing the game.
//DRAW BODY
void drawBody(KJoint[] joints) {
  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  // Right Arm
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  // Left Leg
  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  drawJoint(joints, KinectPV2.JointType_HandTipRight);
  drawJoint(joints, KinectPV2.JointType_FootLeft);
  drawJoint(joints, KinectPV2.JointType_FootRight);

  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);

  drawJoint(joints, KinectPV2.JointType_Head);
}

//draw joint
void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
}

//draw bone
void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  pushMatrix();
  translate(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
  line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}

//draw hand state
void drawHandState(KJoint joint) {
  noStroke();
  handState(joint.getState());
  pushMatrix();
  translate(joint.getX(), joint.getY(), joint.getZ());
  ellipse(0, 0, 70, 70);
  popMatrix();
}

/*
Different hand state
 KinectPV2.HandState_Open
 KinectPV2.HandState_Closed
 KinectPV2.HandState_Lasso
 KinectPV2.HandState_NotTracked
 */
void handState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    fill(0, 255, 0);
    break;
  case KinectPV2.HandState_Closed:
    fill(255, 0, 0);
    break;
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255);
    break;
  case KinectPV2.HandState_NotTracked:
    fill(255, 255, 255);
    break;
  }
}