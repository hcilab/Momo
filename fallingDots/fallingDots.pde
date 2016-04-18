import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import java.awt.event.KeyEvent;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import java.awt.Robot;
import java.awt.event.KeyEvent;
import java.io.IOException;
import eyetracking.*;
EyeTrackingDevice device;

int score = 0;
int lives = 3;
int timer = 0;

Box2DProcessing box2d;

int mouseX2;
int mouseY2;
boolean cool;
int cooldown = 100;
Bullet bull;
int MAX = 8;
int numOfDots = 15;
int i = 0;

boolean start = false;
boolean shoot = false;
PImage spikey;
PFont f;
ArrayList plist = new ArrayList();
ArrayList dlist = new ArrayList();

AudioSample shot;
AudioSample explosion;
Minim minim;

void setup() {
  size(1366,800);
  smooth();
  
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  
  dlist = new ArrayList();
  for (int i = 0; i < numOfDots; i++) {
    dlist.add(new Dot(false));
  }
  dlist.add(new Dot(true));
  dlist.add(new Dot(true));
  dlist.add(new Dot(true));
  
  minim = new Minim(this);
  shot = minim.loadSample("146730__fins__shoot.wav", 5048);
  explosion = minim.loadSample("84521__destro-94__explosion-flangered.wav", 5048);
  
  fill(0);
  spikey = loadImage("spikey.png");
  f = createFont("Arial",16,true);
}

void draw() {
  background(255);
  fill(0);
  textFont(f,28);
  text("Score: " + score,1230,50);
  text("Lives: " + lives,20,50);
  textFont(f,14);
  text(mouseX,20,70);
  text(mouseY,20,90);
  text(mouseX2,20,110);
  text(mouseY2,20,130);
  
  if ( lives == 0) {
    fill(0);
    textFont(f,36);
    text("Game Over",600,250);
    textFont(f,22);
    text("Press enter to restart.",590,300);
  }
  
  else if (start == false) {
    fill(0);
    textFont(f,28);
    text("Shoot ",600,250);
    ellipse(710,240,20,20);
    text("Avoid ",600,290);
    image(spikey,685,270);
    text("Press enter to start.",535,340);
  }
  
  else {
    
    fill(0);
    ellipse(683,790,20,20);
    
    if (cool) { cooldown--; }
    
    if (shoot) {
      bull.run();
      bull.update();
    }
  
    if (cooldown <= 0 ) { 
      cool = false;
      cooldown = 100;
      shoot = false;
    }
  
    for (int i = 0; i < dlist.size(); i++) {
      Dot dot = (Dot)dlist.get(i);
      dot.run();
    } //<>//
    
    for(int i = 0; i < plist.size(); i++) {
      Particle p = (Particle) plist.get(i);
      p.run();
      p.update();
      p.gravity();
    }
    
    if (i < plist.size()) {
      plist.remove(i);
      i++;
    }
  }
}

void explode(float x, float y) {
  for (int i = 0; i < MAX; i ++) {
    plist.add(new Particle(x,y)); // fill ArrayList with particles
 
  if(plist.size() > 5*MAX) {
      plist.remove(0);
    }
  }
}

void keyReleased() {
  if (lives == 0 && keyCode == ENTER) { 
    lives = 3;
    score = 0;
  }
  if (start == false && keyCode == ENTER) { start = true; }
}

void keyPressed() { 
  if (keyCode ==  KeyEvent.VK_SPACE) {
    if (!cool) {
      shot.trigger();
      bull = new Bullet(mouseX,mouseY);
      mouseX2 = mouseX;
      mouseY2 = mouseY;
      shoot = true;
      cool = true;
    }
  }
}

Bullet getBullet() { return bull; }