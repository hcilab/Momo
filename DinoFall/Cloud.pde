class Cloud {
  PImage cloudImage;
  int initY, x, y;
  int speed;
  
  Cloud(int xIn, int yIn, int speedIn) {
    initY = 720;
    x = xIn;
    y = yIn;
    speed = speedIn;
    
    int rand = int(random(1,4));
    
    cloudImage = loadImage("cloud" + rand + ".png");
  }
  
  void display() {
    image(cloudImage,x,y); 
  }

  void run() {
    image(cloudImage,x,y);
    y = y - speed;
    
    if (y <= -100) {
      y = initY;
      int rand = int(random(1,4));
      cloudImage = loadImage("cloud" + rand + ".png");
      x = int(random(0,350));
    }    
  }
}