class PlayerDino {
  Animation flap;
  PImage still;
  PImage bd;
  PImage wings;
  int x, y;
  Body body;
  
  PlayerDino(int xIN, int yIN) {
    x = xIN;
    y = yIN;
    makeBody(x,y,20);
    still = loadImage("archae.png");
    bd = loadImage("archaeBD1.png");
    wings = loadImage("archaeWG1.png");
    flap = new Animation("archae", 20);
    
  }
  
  void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    pushMatrix();
    translate(pos.x,pos.y);
    if (!doFlap) { image(bd,74,0); image(wings,0,34); }
    popMatrix();
    
    if (doFlap) {
      flap.display(pos.x,pos.y);
    }
    
    if (pos.y > 600) {
      gameOver = true;
    }
  }
  
  void makeBody(float x, float y, float r) {
    BodyDef bd = new BodyDef();
    bd.position = box2d.coordPixelsToWorld(x,y);
    bd.type = BodyType.DYNAMIC;
    body = box2d.world.createBody(bd);

    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.density = 1;
    fd.friction = 0.01;
    fd.restitution = 0.3;
    
    body.createFixture(fd);
    body.setGravityScale(0.4);
  }
}