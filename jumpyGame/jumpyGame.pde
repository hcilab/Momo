import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

boolean jump = false;
boolean goDown = false;
boolean moveLeft = false;
boolean moveRight = false;
boolean writeOnce = false;
boolean restart = false;

int score = 0;
boolean gameOver = false;
PFont f;

import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import java.awt.event.KeyEvent;

Box2DProcessing box2d;
ArrayList boundaries;
ArrayList obstacles;
Particle player;

AudioPlayer song;
AudioSample sound;
Minim minim;

void setup() {
  size(640,360);
  smooth();
  
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  
  boundaries = new ArrayList();
  boundaries.add(new Boundary(width/2,height-5,width,10,0));
  boundaries.add(new Boundary(width/2,5,width,10,0));
  boundaries.add(new Boundary(width-5,height/2,10,height,0));
  boundaries.add(new Boundary(5,height/2,10,height,0));
  
  obstacles = new ArrayList();
  obstacles.add(new Obstacle(10,50, 40,100));
  
  player = new Particle(100,300,6);
 
  f = createFont("Arial",16,true); // Arial, 16 point, anti-aliasing on.
  
  minim = new Minim(this);
  song = minim.loadFile("EDM Detection Mode.mp3", 5048);
  sound = minim.loadSample("jump.wav", 5048);
}//End setup()

void draw() {
  //Restart Game.
  if (restart) {
    jump = false;
    goDown = false;
    gameOver = false;
    writeOnce = false;
    restart = false;
    obstacles.clear();
    obstacles.add(new Obstacle(10,50,40,100));
    player = new Particle(100,300,6);
    score = 0;
    song.rewind();
  }
  
  if (gameOver && !writeOnce) {
    textFont(f,36);
    text("Game Over",200,150);
    textFont(f,22);
    text("Press enter to restart.",190,200);
    writeOnce = true;
    song.pause();
  }
  
  //If the game has started.
  if (!gameOver) {
    song.play();
    background(255);
    
    box2d.step();
    
    for (int i = 0; i < boundaries.size(); i++) {
      Boundary wall = (Boundary) boundaries.get(i);
      wall.display();
    }
    
    for (int i = 0; i < obstacles.size(); i++) {
      Obstacle obs = (Obstacle)obstacles.get(i);
      obs.run();
    }
  
    player.display();
    
    fill(0);
    textFont(f,36);
    text(score,590,60);
    
    if (jump) {
      if (box2d.getBodyPixelCoord(player.body).y > 342 && box2d.getBodyPixelCoord(player.body).y < 344) {
        jump = false;
      }
    }
    
  }
  
}//End Draw()

void keyPressed() {
  if (!moveLeft && keyCode == LEFT) {
    player.body.setLinearVelocity(new Vec2(-6,player.body.getLinearVelocity().y));
    player.body.setAngularVelocity(5); 
  }
    
  if (!moveRight && keyCode == RIGHT) {
    player.body.setLinearVelocity(new Vec2(6,player.body.getLinearVelocity().y));
    player.body.setAngularVelocity(-5);
  }
  
  if (!jump && keyCode == KeyEvent.VK_SPACE) {
    player.body.applyLinearImpulse(new Vec2(0, 20f), new Vec2(player.body.getWorldCenter().x,player.body.getWorldCenter().y), true);
    jump = true;     
  }
  
}//End KeyPressed()

void keyReleased() {
  if (keyCode == LEFT) {
    player.body.setLinearVelocity(new Vec2(0,player.body.getLinearVelocity().y));
    player.body.setAngularVelocity(0);
  }
    
  if (keyCode == RIGHT) {
    player.body.setLinearVelocity(new Vec2(0,player.body.getLinearVelocity().y));
    player.body.setAngularVelocity(0);
  }
    
  if (gameOver && keyCode == ENTER) { restart = true; }
  
}//End keyReleased()