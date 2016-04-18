class Dot {
 
  int x = (int)random(25,1330);
  int y = (int)random(-2200,-10);
  int dotWidth = 20;
  int dotHeight = 20;
  PImage spikey;
  boolean isSpikey;
  
  Dot (boolean spikeyIn) {
  
    isSpikey = spikeyIn;
    spikey = loadImage("spikey.png");
    
  }
  
  public void run() {
    if (getBullet() != null) {
      if (getBullet().getPosX() > x - 25 && getBullet().getPosX() < x + 25) {
        if (getBullet().getPosY() > y - 25 && getBullet().getPosY() < y + 25) { 
          if (!isSpikey) { score++; } else { lives--; } 
          y = (int)random(2200,-10); 
          x = (int)random(25,1330); 
        }
      }
    }
    if (!isSpikey) { ellipse(x,y,dotWidth,dotHeight); } else { image(spikey,x,y); }
    if (y > 800) { y = (int)random(-200, -10); x = (int)random(25,1330); }
    y++;
  }
}