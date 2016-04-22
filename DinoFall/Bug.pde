class Bug {
  Animation bug;
  PImage img;
  int x, y;
  int rand;
  char letter;
  
  Bug() {
    x = (int)random(5,591);
    y = (int)random(620,1280);
    rand = (int)random(4);
    
    if (rand == 0) { letter = 'y'; }
    if (rand == 1) { letter = 'p'; }
    if (rand == 2) { letter = 'o'; }
    if (rand == 3) { letter = 'r'; }
    
    bug = new Animation(letter + "", 6);
    img = loadImage(letter + "1.png");
  }
  
  void display() {
    image(img,x,y);
  }
  
  void run() {
    bug.display(x,y);
    
    y--;
    
    Vec2 pos = box2d.getBodyPixelCoord(dino.body);
    if (x + img.width > pos.x+74 && x + img.width < pos.x+74 + dino.bd.width) {
      if (y + img.height > pos.y && y + img.width < pos.y + dino.bd.height) {
        gameOverSound.trigger();
        gameOver = true;
        failX = (int)pos.x;
        failY = (int)pos.y;
      }
    }
    
    if (x + img.width > pos.x && x + img.width < pos.x + dino.wings.width) {
      if (y + img.height > pos.y+34 && y + img.width < pos.y+34 + dino.wings.height) {
        gameOverSound.trigger();
        gameOver = true;
        failX = (int)pos.x;
        failY = (int)pos.y;
      }
    }
    
    if (y <= -100) {
      y = (int)random(620,1280);
      rand = int(random(0,4));
      if (rand == 0) { letter = 'y'; }
      if (rand == 1) { letter = 'p'; }
      if (rand == 2) { letter = 'o'; }
      if (rand == 3) { letter = 'r'; }
    
      bug = new Animation(letter + "", 6);
      
      x = int(random(5,591));
    }
  }
}