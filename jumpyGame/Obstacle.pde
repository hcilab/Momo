class Obstacle {
 
  int rectWidth;
  int rectHeight;
  int rectX;
  int rectY;
  int w1, w2, h1, h2;
  boolean scoreCounted;
  
  Obstacle(int one, int two, int three, int four) {
    w1 = one;
    w2 = two;
    h1 = three;
    h2 = four;
    rectWidth = (int)random(w1,w2);
    rectHeight = (int)random(h1,h2);
    rectX = (640 + rectWidth);
    rectY = (350 - rectHeight);
    scoreCounted = false;
  }
  
  void run() {
    if (!gameOver) {
      rectMode(CORNER);
      rect(rectX,rectY,rectWidth,rectHeight);
      rectX--;
    }
    
    //Player jumps obstacle.
    if (!scoreCounted && (int)box2d.getBodyPixelCoord(player.body).x >= (int)rectX+(rectWidth/2)) {
      sound.trigger();
      score++;
      scoreCounted = true;
      if (score > 0 && score < 2) {
        obstacles.add(new Obstacle(10,50,50,100));
      } 
      if (score > 2 && score < 6) {
        obstacles.add(new Obstacle(10,50,100,200));
      } 
      if (score > 6 && score < 8) {
        obstacles.add(new Obstacle(10,50,200,250));
      }
    }
    
    //Player hits obstacle.
    if (box2d.getBodyPixelCoord(player.body).x > rectX && box2d.getBodyPixelCoord(player.body).x < (rectX+rectWidth)) {
      if (box2d.getBodyPixelCoord(player.body).y > rectY && box2d.getBodyPixelCoord(player.body).y < (rectY+rectHeight)) {
        gameOver = true;
      }
    }
    
    //Obstacle is offscreen.
    if (rectX <= -50) {
      rectWidth = (int)random(w1,w2);
      rectHeight = (int)random(h1,h2);
      rectX = (640 + rectWidth);
      rectY = (350 - rectHeight);
      scoreCounted = false;
    }
  }
  
  int getRectX() { return rectX; }
  int getRectY() { return rectY; }
  int getRectWidth() { return rectWidth; }
  int getRectHeight() { return rectHeight; }
  
  String toString() {
    String desc = "";
    
    desc += " w="+rectWidth+" h="+rectHeight+" x="+rectX+" y="+rectY;
    
    return desc;
  }
}