public class Bullet {
  float r = 15;
  float x = 683;
  float y = 790;
  ArrayList tail;
  int sparkTimer = 15;
  int taillength = 25;
  
  float tarX, tarY;
  float posX,posY;
  float easing = 0.05;
  
  Bullet(int targetX, int targetY) {
    
    tarX = targetX;
    tarY = targetY;
    tail = new ArrayList();
    
  }
  
  void run() {
 
    tail.add(new PVector(posX,posY,0));
    if(tail.size() > taillength) {
      tail.remove(0);
    }
    
    posX = (1-easing) * x + easing * tarX;
    posY = (1-easing) * y + easing * tarY;
    
    if (posX >= x-0.5 && posX <= x+0.5) {
      ellipse(x,y,r,r);
      explode(posX,posY);
      explosion.trigger();
      sparkTimer--;
      if (sparkTimer <= 0) { shoot = false; }
    }
  }
 
  void update() {
    
    for (int i = 0; i < tail.size(); i++) {
      PVector tempv = (PVector)tail.get(tail.size()-i-1);
      noStroke();
      fill(6*i + 50);
      r -= 0.2;
      ellipse(tempv.x,tempv.y,r,r);
    }
    
    r = 15;
    fill(0);
    ellipse(posX,posY,r,r);
 
    x = posX;
    y = posY;
    
  }
  
  float getPosX() { return posX; }
  float getPosY() { return posY; }
  
}