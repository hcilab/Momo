class Particle {
  float r = 2;
  PVector pos,speed,grav;
  ArrayList tail;
  float splash = 5;
  int margin = 2;
  int taillength = 25;
 
  Particle(float tempx, float tempy) {
    float startx = tempx + random(-splash,splash);
    float starty = tempy + random(-splash,splash);
    startx = constrain(startx,0,width);
    starty = constrain(starty,0,height);
    float xspeed = random(-3,3);
    float yspeed = random(-3,3);
 
    pos = new PVector(startx,starty);
    speed = new PVector(xspeed,yspeed);
    grav = new PVector(0,0.1);
     
    tail = new ArrayList();
  }
 
  void run() {
    pos.add(speed);
 
    tail.add(new PVector(pos.x,pos.y,0));
    if(tail.size() > taillength) {
      tail.remove(0);
    }
  }
 
  void gravity() {
    speed.add(grav);
  }
 
  void update() {
    for (int i = 0; i < tail.size(); i++) {
      PVector tempv = (PVector)tail.get(tail.size()-1-i);
      noStroke();
      fill(6*i + 50);
      ellipse(tempv.x,tempv.y,r,r);
    }
  }
}