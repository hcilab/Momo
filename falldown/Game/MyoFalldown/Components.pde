//======================================================================================================
// Author: David Hanna
//
// Components are attached to Game Objects to provide their data and behaviour.
//======================================================================================================

//-------------------------------------------------------------------
// INTERFACE
//-------------------------------------------------------------------

enum ComponentType
{
  RENDER,
  RIGID_BODY,
  PLAYER_CONTROLLER,
  PLATFORM_MANAGER_CONTROLLER,
  COIN_EVENT_HANDLER,
  COIN_SPAWNER_CONTROLLER,
  SCORE_TRACKER,
  CALIBRATE_WIZARD,
  COUNTDOWN,
  BUTTON,
  LEVEL_DISPLAY,
  LEVEL_PARAMETERS,
  MUSIC_PLAYER,
}

interface IComponent
{
  public void            destroy();
  public void            fromXML(XML xmlComponent);
  public ComponentType   getComponentType();
  public IGameObject     getGameObject();
  public void            update(int deltaTime);
}

// Can't declare here without implementing, so just a comment made to let you know it's here.
// Constructs and returns new component from XML data.
//
// IComponent componentFactory(XML xmlComponent);

//-----------------------------------------------------------------
// IMPLEMENTATION
//-----------------------------------------------------------------

abstract class Component implements IComponent
{
  protected IGameObject gameObject;
  
  public Component(IGameObject _gameObject)
  {
    gameObject = _gameObject;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
  }
  
  // There is no need to change this in subclasses.
  @Override final public IGameObject getGameObject()
  {
    return gameObject;
  }
  
  // This is the only one enforced on all subclasses.
  @Override abstract public ComponentType getComponentType();
  
  @Override public void update(int deltaTime)
  {
  }
}

class RenderComponent extends Component
{
  public class OffsetPShape
  {
    public PShape pshape;
    public PVector translation;
    public PVector scale;
    
    public OffsetPShape(PShape _pshape, PVector _translation, PVector _scale)
    {
      pshape = _pshape;
      translation = _translation;
      scale = _scale;
    } 
  }
  

  public class OffsetPImage
  {
    public PImage pimage;
    public PVector translation;
    public PVector scale;
    
    public OffsetPImage(PImage _pimage, PVector _translation, PVector _scale)
    {
      pimage = _pimage;
      translation = _translation;
      scale = _scale;
    }
  } 
  

 

  public class OffsetSheetSprite
  {
    public Sprite sheetSprite;
    public PVector translation;
    public PVector scale;
    
    public OffsetSheetSprite(Sprite _sheetSprite, PVector _translation, PVector _scale)
    {
      sheetSprite = _sheetSprite;
      translation = _translation;
      scale = _scale;
    }
  }
  
  public class Text
  {
    public String string;
    public PFont font;
    public int alignX;
    public int alignY;
    public PVector translation;
    public color fillColor;
    public color strokeColor;
    
    public Text(String _string, PFont _font, int _alignX, int _alignY, PVector _translation, color _fillColor, color _strokeColor)
    {
      string = _string;
      font = _font;
      alignX = _alignX;
      alignY = _alignY;
      translation = _translation;
      fillColor = _fillColor;
      strokeColor = _strokeColor;
    }
  }
  
  private ArrayList<OffsetPShape> offsetShapes;
  private ArrayList<Text> texts;
  private ArrayList<OffsetSheetSprite> offsetSheetSprites;
  private ArrayList<OffsetPImage> offsetPImages;
  private StopWatch sw;

  public RenderComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    offsetShapes = new ArrayList<OffsetPShape>();
    texts = new ArrayList<Text>();
    offsetSheetSprites = new ArrayList<OffsetSheetSprite>();
    offsetPImages = new  ArrayList<OffsetPImage>();
    sw = new StopWatch();
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    for (XML xmlRenderable : xmlComponent.getChildren())
    {
      if (xmlRenderable.getName().equals("Point"))
      {
        OffsetPShape offsetShape = new OffsetPShape(
          createShape(POINT, 0.0, 0.0), 
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("width"), xmlRenderable.getFloat("height"))
        );
        parseShapeComponents(xmlRenderable, offsetShape);
        offsetShapes.add(offsetShape);
      }
      else if (xmlRenderable.getName().equals("Line"))
      {
        OffsetPShape offsetShape = new OffsetPShape(
          createShape(
            LINE,
            xmlRenderable.getFloat("x1"), xmlRenderable.getFloat("y1"),
            xmlRenderable.getFloat("x2"), xmlRenderable.getFloat("y2")
          ), 
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("width"), xmlRenderable.getFloat("height"))
        );
        parseShapeComponents(xmlRenderable, offsetShape);
        offsetShapes.add(offsetShape);
      }
      else if (xmlRenderable.getName().equals("Triangle"))
      {
        OffsetPShape offsetShape = new OffsetPShape(
          createShape(
            TRIANGLE,
            xmlRenderable.getFloat("x1"), xmlRenderable.getFloat("y1"),
            xmlRenderable.getFloat("x2"), xmlRenderable.getFloat("y2"),
            xmlRenderable.getFloat("x3"), xmlRenderable.getFloat("y3")
          ),
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("width"), xmlRenderable.getFloat("height"))
        );
        parseShapeComponents(xmlRenderable, offsetShape);
        offsetShapes.add(offsetShape);
      }
      else if (xmlRenderable.getName().equals("Quad"))
      {
        OffsetPShape offsetShape = new OffsetPShape(
          createShape(
            QUAD,
            xmlRenderable.getFloat("x1"), xmlRenderable.getFloat("y1"),
            xmlRenderable.getFloat("x2"), xmlRenderable.getFloat("y2"),
            xmlRenderable.getFloat("x3"), xmlRenderable.getFloat("y3"),
            xmlRenderable.getFloat("x4"), xmlRenderable.getFloat("y4")
          ),
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("width"), xmlRenderable.getFloat("height"))
        );
        parseShapeComponents(xmlRenderable, offsetShape);
        offsetShapes.add(offsetShape);
      }
      else if (xmlRenderable.getName().equals("Rect"))
      {
        OffsetPShape offsetShape = new OffsetPShape( 
          createShape(RECT, 0.0, 0.0, 1.0, 1.0),
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("halfWidth"), xmlRenderable.getFloat("halfHeight"))
        );
        parseShapeComponents(xmlRenderable, offsetShape);
        offsetShapes.add(offsetShape);
      }
      else if (xmlRenderable.getName().equals("Ellipse"))
      {
        OffsetPShape offsetShape = new OffsetPShape(
          createShape(ELLIPSE, 0.0, 0.0, 1.0, 1.0),
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("halfWidth"), xmlRenderable.getFloat("halfHeight"))
        );
        parseShapeComponents(xmlRenderable, offsetShape);
        offsetShapes.add(offsetShape);
      }
      else if (xmlRenderable.getName().equals("Arc"))
      {
        OffsetPShape offsetShape = new OffsetPShape(
          createShape(
            ARC,
            0.0, 0.0,
            1.0, 1.0,
            xmlRenderable.getFloat("startAngle"), xmlRenderable.getFloat("stopAngle")
          ),
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("halfWidth"), xmlRenderable.getFloat("halfHeight"))
        );
        parseShapeComponents(xmlRenderable, offsetShape);
        offsetShapes.add(offsetShape);
      }
      else if (xmlRenderable.getName().equals("Sprite")){
       //println("Sprite Detected");
       for (XML xmlSpriteComponent : xmlRenderable.getChildren()){
         if(xmlSpriteComponent.getName().equals("SpriteSheet")){
           OffsetSheetSprite offsetSheetSprite = new OffsetSheetSprite(
               new Sprite(MyoFalldown.this, xmlSpriteComponent.getString("src"), xmlSpriteComponent.getString("alphaImage"),xmlSpriteComponent.getInt("horzCount"), xmlSpriteComponent.getInt("vertCount"), xmlSpriteComponent.getInt("zOrder")),
               new PVector(xmlSpriteComponent.getFloat("x"), xmlSpriteComponent.getFloat("y")),
               new PVector(1, (xmlSpriteComponent.getFloat("scaleHeight")/xmlSpriteComponent.getFloat("height")))
            );
            offsetSheetSprite.sheetSprite.setFrameSequence(0, xmlSpriteComponent.getInt("horzCount")*xmlSpriteComponent.getInt("vertCount"), xmlSpriteComponent.getFloat("farmeFreq"));  
            offsetSheetSprite.sheetSprite.setDomain(-100,-100,width+100,height+100,Sprite.HALT);
            offsetSheetSprite.sheetSprite.setScale(xmlSpriteComponent.getFloat("scaleHeight")/xmlSpriteComponent.getFloat("height"));
            offsetSheetSprites.add(offsetSheetSprite);
         }
          else if(xmlSpriteComponent.getName().equals("Image")){
            PImage bgsize =  loadImage(xmlSpriteComponent.getString("src"));
            bgsize.resize(500,500);
            OffsetPImage offsetsprite = new OffsetPImage(
              bgsize,
              new PVector(xmlSpriteComponent.getFloat("x"), xmlSpriteComponent.getFloat("y")),
              new PVector(xmlSpriteComponent.getFloat("width"), xmlSpriteComponent.getFloat("height"))
            );
            background(offsetsprite.pimage);
            offsetPImages.add(offsetsprite);
         }
       }
     }
      else if (xmlRenderable.getName().equals("Text"))
      {
        int alignX = CENTER;
        int alignY = BASELINE;
        String stringAlignX = xmlRenderable.getString("alignX");
        String stringAlignY = xmlRenderable.getString("alignY");
        
        if (stringAlignX.equals("left"))
        {
          alignX = LEFT;
        }
        else if (stringAlignX.equals("center"))
        {
          alignX = CENTER;
        }
        else if (stringAlignX.equals("right"))
        {
          alignX = RIGHT;
        }
        
        if (stringAlignY.equals("baseline"))
        {
          alignY = BASELINE;
        }
        else if (stringAlignY.equals("top"))
        {
          alignY = TOP;
        }
        else if (stringAlignY.equals("center"))
        {
          alignY = CENTER;
        }
        else if (stringAlignY.equals("bottom"))
        {
          alignY = BOTTOM;
        }
        
        color[] fillAndStrokeColor = parseColorComponents(xmlRenderable);
        
        texts.add(new Text(
          xmlRenderable.getString("string"),
          createFont(xmlRenderable.getString("fontName"), xmlRenderable.getInt("size"), xmlRenderable.getString("antialiasing").equals("true") ? true : false),
          alignX,
          alignY,
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          fillAndStrokeColor[0],
          fillAndStrokeColor[1]
        ));
      }
    }
  }
  
  private void parseShapeComponents(XML xmlShape, OffsetPShape offsetShape)
  {
    color[] fillAndStrokeColor = parseColorComponents(xmlShape);
    offsetShape.pshape.setFill(fillAndStrokeColor[0]);
    offsetShape.pshape.setStroke(fillAndStrokeColor[1]);
  }
  
  // returns fill color in position 0 and stroke color in position 1
  private color[] parseColorComponents(XML xmlParent)
  {
    color[] fillAndStrokeColor = new color[2];
    
    for (XML xmlShapeComponent : xmlParent.getChildren())
    {
      if (xmlShapeComponent.getName().equals("FillColor"))
      {
        fillAndStrokeColor[0] = parseColor(xmlShapeComponent);
      }
      else if (xmlShapeComponent.getName().equals("StrokeColor"))
      {
        fillAndStrokeColor[1] = parseColor(xmlShapeComponent);
      }
    }
    
    return fillAndStrokeColor;
  }
  
  private color parseColor(XML xmlColor)
  {
    return color(xmlColor.getInt("r"), xmlColor.getInt("g"), xmlColor.getInt("b"), xmlColor.getInt("a"));
  }
  
  private void tilePlatformSprite(OffsetSheetSprite sprite)
  {
   sprite.sheetSprite.setXY(gameObject.getTranslation().x + sprite.translation.x, gameObject.getTranslation().y + sprite.translation.y);
   sprite.sheetSprite.draw();
   int width = (int)sprite.sheetSprite.getWidth();
   int tilelength = (int)((((gameObject.getScale().x-width)/width)/2)); 
   for(int i =1; i < tilelength+1; i++){
      sprite.sheetSprite.setXY(floor(gameObject.getTranslation().x + sprite.translation.x + (i*width)), gameObject.getTranslation().y + sprite.translation.y);
      sprite.sheetSprite.draw();
      sprite.sheetSprite.setXY(ceil(gameObject.getTranslation().x + sprite.translation.x - (i*width)), gameObject.getTranslation().y + sprite.translation.y);
      sprite.sheetSprite.draw();
   }
   sprite.sheetSprite.setXY(floor(gameObject.getTranslation().x + sprite.translation.x +  (gameObject.getScale().x -(2*tilelength*width+width))/2 + ((tilelength) * width)), gameObject.getTranslation().y + sprite.translation.y);
   sprite.sheetSprite.draw();
   sprite.sheetSprite.setXY(ceil(gameObject.getTranslation().x + sprite.translation.x - (gameObject.getScale().x -(2*tilelength*width+width))/2 - ((tilelength) * width)), gameObject.getTranslation().y + sprite.translation.y);
   sprite.sheetSprite.draw();
  }
  
  private void tileImagePlatform(OffsetPImage img)
  {
   image(img.pimage, gameObject.getTranslation().x + img.translation.x, gameObject.getTranslation().y + img.translation.y, img.scale.x,img.scale.y);
   int width =  15;
   int tilelength = (int)((((gameObject.getScale().x-width)/width)/2)); 
   for(int i =1; i < tilelength+1; i++){
     image(img.pimage, gameObject.getTranslation().x + img.translation.x + (i*width), gameObject.getTranslation().y + img.translation.y, img.scale.x,img.scale.y);
     image(img.pimage, gameObject.getTranslation().x + img.translation.x - (i*width), gameObject.getTranslation().y + img.translation.y, img.scale.x,img.scale.y);
   }
   //println(212/(gameObject.getScale().x -(2*tilelength*width+width))/2 + ((tilelength) * width));
   //PImage cropImg = img.pimage.get(0,0,(int)(gameObject.getScale().x -(2*tilelength*width+width))/2 + ((tilelength) * width),212);
   //image(cropImg,gameObject.getTranslation().x + img.translation.x +(tilelength+2)*width,gameObject.getTranslation().y + img.translation.y, img.scale.x,img.scale.y);
   //image(img.pimage, floor(gameObject.getTranslation().x + img.translation.x +  (gameObject.getScale().x -(2*tilelength*width+width))/2 + ((tilelength) * width)), gameObject.getTranslation().y + img.translation.y, img.scale.x,img.scale.y);
   //image(img.pimage,ceil(gameObject.getTranslation().x + img.translation.x - (gameObject.getScale().x -(2*tilelength*width+width))/2 - ((tilelength) * width)), gameObject.getTranslation().y + img.translation.y, img.scale.x,img.scale.y);
  }
  
  private void tileWallSprite(OffsetSheetSprite sprite){  
   //wall height is 500 with width of 10
   //tile length will be 50 starting from top
   int height = (int)sprite.sheetSprite.getHeight();
   int tilelength = 500/height;
   for(int i =0; i < tilelength+1; i++){
      sprite.sheetSprite.setXY(gameObject.getTranslation().x + sprite.translation.x, (i*height));
      sprite.sheetSprite.draw();
   } 
  }
  
  private void tileDeathCeiling(OffsetSheetSprite sprite){
   int width = (int)sprite.sheetSprite.getWidth();
   int tilelength = 480/width;
   for(int i =0; i < tilelength-1; i++){
     // println(i*width);
     sprite.sheetSprite.setXY((30+i*width), gameObject.getTranslation().y + sprite.translation.y);
     sprite.sheetSprite.draw();
   } 
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.RENDER;
  }
  
  @Override public void update(int deltaTime)
  {  
    for (OffsetPShape offsetShape : offsetShapes)
    {
      offsetShape.pshape.resetMatrix();
      offsetShape.pshape.translate(gameObject.getTranslation().x + offsetShape.translation.x, gameObject.getTranslation().y + offsetShape.translation.y);
      offsetShape.pshape.scale(gameObject.getScale().x * offsetShape.scale.x, gameObject.getScale().y * offsetShape.scale.y);
      shape(offsetShape.pshape); // draw
    }
   
    
    for (OffsetSheetSprite offsetSprite: offsetSheetSprites){
     offsetSprite.sheetSprite.setXY(gameObject.getTranslation().x + offsetSprite.translation.x, gameObject.getTranslation().y + offsetSprite.translation.y);
     if(gameObject.getTag().equals("platform")){
       tilePlatformSprite(offsetSprite);
       
     }
     if(gameObject.getTag().equals("death_ceiling")){
       tileDeathCeiling(offsetSprite);
     }
   
     if(gameObject.getTag().equals("wall")){
       tileWallSprite(offsetSprite);
     } 
     offsetSprite.sheetSprite.setScale(gameObject.getScale().y * offsetSprite.scale.y);
     float elapsedTime = (float) sw.getElapsedTime();
     S4P.updateSprites(elapsedTime);
     offsetSprite.sheetSprite.draw();
     
    }
   for (OffsetPImage offsetImage : offsetPImages)
    {
       background(offsetImage.pimage);
      //if(gameObject.getScale().x>1)
      //  tileImagePlatform(offsetImage);
      //else
      //image(offsetImage.pimage, gameObject.getTranslation().x + offsetImage.translation.x, gameObject.getTranslation().y + offsetImage.translation.y,gameObject.getScale().x * offsetImage.scale.x, gameObject.getScale().y * offsetImage.scale.y);
    }
    
    for (Text text : texts)
    { 
      textFont(text.font);
      textAlign(text.alignX, text.alignY);
      fill(text.fillColor);
      stroke(text.strokeColor);
      text(text.string, text.translation.x + gameObject.getTranslation().x, text.translation.y + gameObject.getTranslation().y);
    }
  }
  
  public ArrayList<OffsetPShape> getShapes()
  {
    return offsetShapes;
  }
  
   public ArrayList<OffsetPImage> getImages()
  {
    return offsetPImages;
  }
  
   public ArrayList<OffsetSheetSprite> getSheetSprite()
  {
    return offsetSheetSprites;
  }
  
  
  public ArrayList<Text> getTexts()
  {
    return texts;
  }
}

class RigidBodyComponent extends Component
{
  private class OnCollideEvent
  {
    public String collidedWith;
    public EventType eventType;
    public HashMap<String, String> eventParameters;
  }
  
  private Body body;
  private ArrayList<OnCollideEvent> onCollideEvents;
  
  public RigidBodyComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    onCollideEvents = new ArrayList<OnCollideEvent>();
  }
  
  @Override public void destroy()
  {
    physicsWorld.destroyBody(body);
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    BodyDef bodyDefinition = new BodyDef();
    
    String bodyType = xmlComponent.getString("type");
    if (bodyType.equals("static")) //<>//
    {
      bodyDefinition.type = BodyType.STATIC;
    }
    else if (bodyType.equals("kinematic"))
    { //<>//
      bodyDefinition.type = BodyType.KINEMATIC;
    } //<>//
    else if (bodyType.equals("dynamic"))
    {
      bodyDefinition.type = BodyType.DYNAMIC;
    }
    else //<>//
    {
      print("Unknown rigid body type: " + bodyType);
      assert(false);
    }
     
    bodyDefinition.position.set(pixelsToMeters(gameObject.getTranslation().x), pixelsToMeters(gameObject.getTranslation().y));
    bodyDefinition.angle = 0.0f;
    bodyDefinition.linearDamping = xmlComponent.getFloat("linearDamping");
    bodyDefinition.angularDamping = xmlComponent.getFloat("angularDamping");
    bodyDefinition.gravityScale = xmlComponent.getFloat("gravityScale");
    bodyDefinition.allowSleep = xmlComponent.getString("allowSleep").equals("true") ? true : false;
    bodyDefinition.awake = xmlComponent.getString("awake").equals("true") ? true : false;
    bodyDefinition.fixedRotation = xmlComponent.getString("fixedRotation").equals("true") ? true : false;
    bodyDefinition.bullet = xmlComponent.getString("bullet").equals("true") ? true : false;
    bodyDefinition.active = xmlComponent.getString("active").equals("true") ? true : false;
    bodyDefinition.userData = gameObject;
    
    body = physicsWorld.createBody(bodyDefinition);
    
    for (XML rigidBodyComponent : xmlComponent.getChildren())
    {
      if (rigidBodyComponent.getName().equals("Fixture"))
      {
        FixtureDef fixtureDef = new FixtureDef();
        fixtureDef.density = rigidBodyComponent.getFloat("density");
        fixtureDef.friction = rigidBodyComponent.getFloat("friction");
        fixtureDef.restitution = rigidBodyComponent.getFloat("restitution");
        fixtureDef.isSensor = rigidBodyComponent.getString("isSensor").equals("true") ? true : false;
        fixtureDef.userData = gameObject;
         //<>//
        for (XML xmlShape : rigidBodyComponent.getChildren())
        {
          if (xmlShape.getName().equals("Shape"))
          {
            String shapeType = xmlShape.getString("type");
            
            if (shapeType.equals("circle"))
            {
              CircleShape circleShape = new CircleShape();
              circleShape.m_p.set(pixelsToMeters(xmlShape.getFloat("x")), pixelsToMeters(xmlShape.getFloat("y")));
              circleShape.m_radius = pixelsToMeters(xmlShape.getFloat("radius")) * gameObject.getScale().x;
              
              fixtureDef.shape = circleShape;
            }
            else if (shapeType.equals("box"))
            {
              PolygonShape boxShape = new PolygonShape();
              boxShape.m_centroid.set(new Vec2(pixelsToMeters(xmlShape.getFloat("x")), pixelsToMeters(xmlShape.getFloat("y"))));
              boxShape.setAsBox(
                pixelsToMeters(xmlShape.getFloat("halfWidth")) * gameObject.getScale().x, 
                pixelsToMeters(xmlShape.getFloat("halfHeight")) * gameObject.getScale().y
              );
              
              fixtureDef.shape = boxShape;
            }
            else
            {
              print("Unknown fixture shape type: " + shapeType);
              assert(false);
            }
          } //<>//
        }
        
        body.createFixture(fixtureDef);
      }
      else if (rigidBodyComponent.getName().equals("OnCollideEvents"))
      {
        for (XML xmlOnCollideEvent : rigidBodyComponent.getChildren())
        {
          if (xmlOnCollideEvent.getName().equals("Event"))
          {
            OnCollideEvent onCollideEvent = new OnCollideEvent();
            onCollideEvent.collidedWith = xmlOnCollideEvent.getString("collidedWith");
            
            String stringEventType = xmlOnCollideEvent.getString("eventType");
            if (stringEventType.equals("COIN_COLLECTED"))
            {
              onCollideEvent.eventType = EventType.COIN_COLLECTED;
              onCollideEvent.eventParameters = new HashMap<String, String>();
              onCollideEvent.eventParameters.put("coinParameterName", xmlOnCollideEvent.getString("coinParameterName"));
            }
            else if (stringEventType.equals("GAME_OVER"))
            {
              onCollideEvent.eventType = EventType.GAME_OVER;
            }
            else if (stringEventType.equals("DESTROY_COIN"))
            {
              onCollideEvent.eventType = EventType.DESTROY_COIN;
              onCollideEvent.eventParameters = new HashMap<String, String>();
              onCollideEvent.eventParameters.put("coinParameterName", xmlOnCollideEvent.getString("coinParameterName"));
            }
            
            onCollideEvents.add(onCollideEvent);
          }
        }
      }
    }
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.RIGID_BODY;
  }
  
  @Override public void update(int deltaTime)
  {
    // Reverse sync the physically simulated position to the Game Object position.
    gameObject.setTranslation(new PVector(metersToPixels(body.getPosition().x), metersToPixels(body.getPosition().y)));
  }
  
  public void onCollisionEnter(IGameObject collider)
  {
    for (OnCollideEvent onCollideEvent : onCollideEvents)
    {
      if (onCollideEvent.collidedWith.equals(collider.getTag()))
      {
        if (onCollideEvent.eventType == EventType.COIN_COLLECTED)
        {
          Event event = new Event(EventType.COIN_COLLECTED);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("coinParameterName"), collider);
          eventManager.queueEvent(event);
        }
        else if (onCollideEvent.eventType == EventType.GAME_OVER) //<>//
        { //<>//
          eventManager.queueEvent(new Event(EventType.GAME_OVER));
        }
        else if (onCollideEvent.eventType == EventType.DESTROY_COIN)
        {
          Event event = new Event(EventType.DESTROY_COIN);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("coinParameterName"), collider);
          eventManager.queueEvent(event);
        }
      } //<>//
    }
  }
  
  public PVector getLinearVelocity()
  { //<>//
    return new PVector(metersToPixels(body.getLinearVelocity().x), metersToPixels(body.getLinearVelocity().y));
  }  //<>//
  
  public void setLinearVelocity(PVector linearVelocity)
  {
    body.setLinearVelocity(new Vec2(pixelsToMeters(linearVelocity.x), pixelsToMeters(linearVelocity.y)));
  } //<>//
  
  public void applyForce(PVector force, PVector position)
  {
    body.applyForce(new Vec2(pixelsToMeters(force.x), pixelsToMeters(force.y)), new Vec2(pixelsToMeters(position.x), pixelsToMeters(position.y)));
  }
  
  public void applyLinearImpulse(PVector impulse, PVector position, boolean wakeUp)
  {
    body.applyLinearImpulse(
      new Vec2(pixelsToMeters(impulse.x), pixelsToMeters(impulse.y)),
      new Vec2(pixelsToMeters(position.x), pixelsToMeters(position.y)),
      wakeUp
    );
  }
  
  private float pixelsToMeters(float pixels)
  {
    return pixels / 50.0f;
  }
  
  private float metersToPixels(float meters)
  {
    return meters * 50.0f;
  }
}

class PlayerControllerComponent extends Component implements IEventListener
{
  private float acceleration;
  private float maxSpeed; //<>//
  private float jumpForce;
  
  private String currentRiseSpeedParameterName;
  private float riseSpeed;
  
  private boolean upButtonDown;
  private boolean leftButtonDown;
  private boolean rightButtonDown;
  
  private SoundFile jumpSound;
  
  public PlayerControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    upButtonDown = false;
    leftButtonDown = false;
    rightButtonDown = false;
    
    eventManager.register(EventType.UP_BUTTON_PRESSED, this);
    eventManager.register(EventType.LEFT_BUTTON_PRESSED, this);
    eventManager.register(EventType.RIGHT_BUTTON_PRESSED, this);
    
    eventManager.register(EventType.UP_BUTTON_RELEASED, this);
    eventManager.register(EventType.LEFT_BUTTON_RELEASED, this);
    eventManager.register(EventType.RIGHT_BUTTON_RELEASED, this);
    
    eventManager.register(EventType.LEVEL_UP, this);
  }
  
  @Override public void destroy()
  {
    eventManager.deregister(EventType.UP_BUTTON_PRESSED, this);
    eventManager.deregister(EventType.LEFT_BUTTON_PRESSED, this);
    eventManager.deregister(EventType.RIGHT_BUTTON_PRESSED, this);
    
    eventManager.deregister(EventType.UP_BUTTON_RELEASED, this);
    eventManager.deregister(EventType.LEFT_BUTTON_RELEASED, this); //<>//
    eventManager.deregister(EventType.RIGHT_BUTTON_RELEASED, this);
    
    eventManager.deregister(EventType.LEVEL_UP, this);
  }
   //<>//
  @Override public void fromXML(XML xmlComponent)
  { //<>//
    acceleration = xmlComponent.getFloat("acceleration");
    maxSpeed = xmlComponent.getFloat("maxSpeed");
    jumpForce = xmlComponent.getFloat("jumpForce");
    currentRiseSpeedParameterName = xmlComponent.getString("currentRiseSpeedParameterName");
    riseSpeed = 0.0f;
    jumpSound = new SoundFile(mainObject, xmlComponent.getString("jumpSoundFile"));
    jumpSound.rate(xmlComponent.getFloat("rate"));
    try { jumpSound.pan(xmlComponent.getFloat("pan")); } catch (UnsupportedOperationException e) {}
    jumpSound.amp(xmlComponent.getFloat("amp"));
    jumpSound.add(xmlComponent.getFloat("add"));
  }
   //<>//
  @Override public ComponentType getComponentType()
  {
    return ComponentType.PLAYER_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    PVector moveVector = new PVector();
    
    moveVector.add(getKeyboardInput());
    moveVector.add(getEmgInput());

    moveVector.normalize(); //<>//
    
    IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
    if (component != null)
    {
      RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
      PVector linearVelocity = rigidBodyComponent.getLinearVelocity();
      if (  (moveVector.x > 0 && linearVelocity.x < maxSpeed)
         || (moveVector.x < 0 && linearVelocity.x > -maxSpeed))
      {
        rigidBodyComponent.applyForce(new PVector(moveVector.x * acceleration * deltaTime, 0.0f), gameObject.getTranslation());
      }
      
      ArrayList<IGameObject> platformManagerList = gameObjectManager.getGameObjectsByTag("platform_manager");
      if (!platformManagerList.isEmpty())
      {
        IComponent tcomponent = platformManagerList.get(0).getComponent(ComponentType.PLATFORM_MANAGER_CONTROLLER);
        if (tcomponent != null) //<>//
        {
          if (moveVector.y < 0.0f
              && ((linearVelocity.y < 0.01f - riseSpeed && linearVelocity.y > -0.01f - riseSpeed) || linearVelocity.y == 0.0f))
          {
            rigidBodyComponent.applyLinearImpulse(new PVector(0.0f, moveVector.y * jumpForce * deltaTime), gameObject.getTranslation(), true);
            jumpSound.play(); //<>//
          } //<>//
        }
      }
    }
    else 
    {
      gameObject.translate(moveVector);
    }
  }
  
  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.UP_BUTTON_PRESSED)
    {
      upButtonDown = true;
    }
    else if (event.getEventType() == EventType.LEFT_BUTTON_PRESSED)
    {
      leftButtonDown = true;
    }
    else if (event.getEventType() == EventType.RIGHT_BUTTON_PRESSED)
    {
      rightButtonDown = true;
    }
    else if (event.getEventType() == EventType.UP_BUTTON_RELEASED)
    {
      upButtonDown = false;
    }
    else if (event.getEventType() == EventType.LEFT_BUTTON_RELEASED)
    {
      leftButtonDown = false; 
    }
    else if (event.getEventType() == EventType.RIGHT_BUTTON_RELEASED)
    {
      rightButtonDown = false;
    }
    else if (event.getEventType() == EventType.LEVEL_UP)
    {
      riseSpeed = event.getRequiredFloatParameter(currentRiseSpeedParameterName);
    }
  }

  private PVector getKeyboardInput() {
    PVector p = new PVector();
    if (upButtonDown)
    {
      p.y -= 1.0f;
    }
    if (leftButtonDown)
    {
      p.x -= 1.0f;
    }
    if (rightButtonDown)
    {
      p.x += 1.0f;
    }
    return p;
  }
 //<>//
  private PVector getEmgInput() {
    HashMap<String, Float> readings = emgManager.poll();
    return new PVector(
      readings.get("RIGHT")-readings.get("LEFT"),
      -readings.get("JUMP"));
  }
}

class PlatformManagerControllerComponent extends Component implements IEventListener
{
  private LinkedList<IGameObject> platforms;
  
  private String platformFile;
  private String tag;
  
  private int maxPlatformLevels;
  
  private float leftSide;
  private float rightSide;
  
  private float platformHeight;
  
  private float disappearHeight;
  private float spawnHeight;
   //<>//
  private int minGapsPerLevel; //<>//
  private int maxGapsPerLevel;
  
  private float minGapSize;
  private float maxGapSize;
  private float minDistanceBetweenGaps;
  
  private String obstacleFile;
  private String obstacleTag;
  private float obstacleChance;
  private float obstacleMinWidth;
  private float obstacleMaxWidth;
  private float obstacleMinHeight;
  private float obstacleMaxHeight;
  private float obstacleMinHorizontalOffset;
  private float obstacleMaxHorizontalOffset;
  
  private float minHeightBetweenPlatformLevels;
  private float maxHeightBetweenPlatformLevels;
  private float nextHeightBetweenPlatformLevels;
  
  private String currentRiseSpeedParameterName;
  private float riseSpeed;
  
  public PlatformManagerControllerComponent(IGameObject _gameObject)
  {
    super (_gameObject);
    
    platforms = new LinkedList<IGameObject>();
    
    eventManager.register(EventType.LEVEL_UP, this);
  }
  
  @Override public void destroy()
  {
    eventManager.deregister(EventType.LEVEL_UP, this);
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    platformFile = xmlComponent.getString("platformFile");
    tag = xmlComponent.getString("tag");
    maxPlatformLevels = xmlComponent.getInt("maxPlatformLevels");
    leftSide = xmlComponent.getFloat("leftSide");
    rightSide = xmlComponent.getFloat("rightSide");
    platformHeight = xmlComponent.getFloat("platformHeight");
    disappearHeight = xmlComponent.getFloat("disappearHeight");
    spawnHeight = xmlComponent.getFloat("spawnHeight");
    minGapsPerLevel = xmlComponent.getInt("minGapsPerLevel");
    maxGapsPerLevel = xmlComponent.getInt("maxGapsPerLevel");
    minGapSize = xmlComponent.getFloat("minGapSize");
    maxGapSize = xmlComponent.getFloat("maxGapSize");
    minDistanceBetweenGaps = xmlComponent.getFloat("minDistanceBetweenGaps");
    obstacleFile = xmlComponent.getString("obstacleFile");
    obstacleTag = xmlComponent.getString("obstacleTag");
    obstacleChance = xmlComponent.getFloat("obstacleChance");
    obstacleMinWidth = xmlComponent.getFloat("obstacleMinWidth");
    obstacleMaxWidth = xmlComponent.getFloat("obstacleMaxWidth");
    obstacleMinHeight = xmlComponent.getFloat("obstacleMinHeight");
    obstacleMaxHeight = xmlComponent.getFloat("obstacleMaxHeight");
    obstacleMinHorizontalOffset = xmlComponent.getFloat("obstacleMinHorizontalOffset");
    obstacleMaxHorizontalOffset = xmlComponent.getFloat("obstacleMaxHorizontalOffset");
    minHeightBetweenPlatformLevels = xmlComponent.getFloat("minHeightBetweenPlatformLevels");
    maxHeightBetweenPlatformLevels = xmlComponent.getFloat("maxHeightBetweenPlatformLevels");
    nextHeightBetweenPlatformLevels = random(minHeightBetweenPlatformLevels, maxHeightBetweenPlatformLevels);
    currentRiseSpeedParameterName = xmlComponent.getString("currentRiseSpeedParameterName");
    riseSpeed = 0.0f;
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.PLATFORM_MANAGER_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    while (!platforms.isEmpty() && platforms.getFirst().getTranslation().y < disappearHeight)
    {
      IGameObject platform = platforms.removeFirst();
      gameObjectManager.removeGameObject(platform.getUID());
    }
    
    if (platforms.isEmpty()
      || (platforms.size() < maxPlatformLevels && ((spawnHeight - platforms.getLast().getTranslation().y) > nextHeightBetweenPlatformLevels)))
    {
      if (riseSpeed > 0.0f)
      {
        spawnPlatformLevel();
        nextHeightBetweenPlatformLevels = random(minHeightBetweenPlatformLevels, maxHeightBetweenPlatformLevels);
      }
    }
  }
  
  private void spawnPlatformLevel()
  {
    ArrayList<PVector> platformRanges = new ArrayList<PVector>();
    platformRanges.add(new PVector(leftSide, rightSide));
    
    int gapsInLevel = int(random(minGapsPerLevel, maxGapsPerLevel + 1)); 
    
    for (int i = 0; i < gapsInLevel; ++i)
    {
      int rangeSelector = int(random(0, platformRanges.size() - 1));
      PVector range = platformRanges.get(rangeSelector);
      float rangeWidth = range.y - range.x;
      float rangeWidthMinusDistanceBetweenGaps = rangeWidth - minDistanceBetweenGaps;
      if (rangeWidthMinusDistanceBetweenGaps < minGapSize)
      {
        continue;
      }
      float halfGapWidth = random(minGapSize, min(maxGapSize, rangeWidthMinusDistanceBetweenGaps)) / 2.0;
      float gapPosition = random(range.x + minDistanceBetweenGaps + halfGapWidth, range.y - minDistanceBetweenGaps - halfGapWidth);
      
      platformRanges.add(rangeSelector + 1, new PVector(gapPosition + halfGapWidth, range.y));
      range.y = gapPosition - halfGapWidth;
    }
    
    for (PVector platformRange : platformRanges)
    {
      float platformPosition = (platformRange.x + platformRange.y) / 2.0f;
      float platformWidth = platformRange.y - platformRange.x;
      
      IGameObject platform = gameObjectManager.addGameObject(platformFile, new PVector(platformPosition, spawnHeight), new PVector(platformWidth, platformHeight));
      platform.setTag(tag);
      setPlatformRiseSpeed(platform);
      platforms.add(platform);
      
      float generateObstacle = random(0.0, 1.0);
      if (generateObstacle < obstacleChance)
      {
        float obstacleWidth = random(obstacleMinWidth, obstacleMaxWidth);
        float obstacleHeight = random(obstacleMinHeight, obstacleMaxHeight);
        float obstacleOffset = random(obstacleMinHorizontalOffset, obstacleMaxHorizontalOffset);
        
        IGameObject obstacle = gameObjectManager.addGameObject(
          obstacleFile, 
          new PVector(platformPosition + obstacleOffset, spawnHeight - (platformHeight / 2.0f) - (obstacleHeight / 2.0f)),
          new PVector(obstacleWidth, obstacleHeight)
        );
        obstacle.setTag(obstacleTag);
        setPlatformRiseSpeed(obstacle);
        platforms.add(obstacle);
      }
    }
  }
  
  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.LEVEL_UP)
    {
      riseSpeed = event.getRequiredFloatParameter(currentRiseSpeedParameterName);
      
      for (IGameObject platform : platforms)
      {
        setPlatformRiseSpeed(platform);
      }
    }
  }
  
  private void setPlatformRiseSpeed(IGameObject platform)
  {
    IComponent component = platform.getComponent(ComponentType.RIGID_BODY);
    if (component != null)
    {
      RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
      rigidBodyComponent.setLinearVelocity(new PVector(0.0, -riseSpeed));
    }
  }
}

class CoinEventHandlerComponent extends Component implements IEventListener
{
  private int scoreValue;
  private String coinCollectedCoinParameterName;
  private String scoreValueParameterName;
  private SoundFile coinCollectedSound;
  
  private String destroyCoinCoinParameterName;
  
  private String currentRiseSpeedParameterName;
  
  public CoinEventHandlerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    eventManager.register(EventType.COIN_COLLECTED, this);
    eventManager.register(EventType.DESTROY_COIN, this);
    eventManager.register(EventType.LEVEL_UP, this);
  }
  
  @Override public void destroy()
  {
    eventManager.deregister(EventType.COIN_COLLECTED, this);
    eventManager.deregister(EventType.DESTROY_COIN, this);
    eventManager.deregister(EventType.LEVEL_UP, this);
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    for (XML xmlCoinEventComponent : xmlComponent.getChildren())
    {
      if (xmlCoinEventComponent.getName().equals("CoinCollected"))
      {
        scoreValue = xmlCoinEventComponent.getInt("scoreValue");
        coinCollectedCoinParameterName = xmlCoinEventComponent.getString("coinParameterName");
        scoreValueParameterName = xmlCoinEventComponent.getString("scoreValueParameterName");
        coinCollectedSound = new SoundFile(mainObject, xmlCoinEventComponent.getString("coinCollectedSoundFile"));
        coinCollectedSound.rate(xmlCoinEventComponent.getFloat("rate"));
        try {coinCollectedSound.pan(xmlCoinEventComponent.getFloat("pan")); } catch (UnsupportedOperationException e) {}
        coinCollectedSound.amp(xmlCoinEventComponent.getFloat("amp"));
        coinCollectedSound.add(xmlCoinEventComponent.getFloat("add"));
      }
      else if (xmlCoinEventComponent.getName().equals("DestroyCoin"))
      {
        destroyCoinCoinParameterName = xmlCoinEventComponent.getString("coinParameterName");
      }
      else if (xmlCoinEventComponent.getName().equals("LevelUp"))
      {
        currentRiseSpeedParameterName = xmlCoinEventComponent.getString("currentRiseSpeedParameterName");
      }
    }
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.COIN_EVENT_HANDLER;
  }
  
  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.COIN_COLLECTED)
    {
      if (event.getRequiredGameObjectParameter(coinCollectedCoinParameterName).getUID() == gameObject.getUID())
      {
        Event updateScoreEvent = new Event(EventType.UPDATE_SCORE);
        updateScoreEvent.addIntParameter(scoreValueParameterName, scoreValue);
        eventManager.queueEvent(updateScoreEvent);
        gameObjectManager.removeGameObject(gameObject.getUID());
        coinCollectedSound.play();
      }
    }
    else if (event.getEventType() == EventType.DESTROY_COIN)
    {
      if (event.getRequiredGameObjectParameter(destroyCoinCoinParameterName).getUID() == gameObject.getUID())
      {
        gameObjectManager.removeGameObject(gameObject.getUID());
      }
    }
    else if (event.getEventType() == EventType.LEVEL_UP)
    {
      IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
      if (component != null)
      {
        RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
        rigidBodyComponent.setLinearVelocity(new PVector(0.0f, -event.getRequiredFloatParameter(currentRiseSpeedParameterName)));
      }
    }
  }
}

class CoinSpawnerControllerComponent extends Component implements IEventListener
{
  private String coinFile;
  private String tag;
  
  private String spawnRelativeTo;
  private int minSpawnWaitTime;
  private int maxSpawnWaitTime;
  private int nextSpawnTime;
  private int timePassed;
  
  private float minHorizontalOffset;
  private float maxHorizontalOffset;
  
  private float minVerticalOffset;
  private float maxVerticalOffset;
  
  private float minHeight;
  
  private String currentRiseSpeedParameterName;
  private float riseSpeed;
  
  public CoinSpawnerControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    eventManager.register(EventType.LEVEL_UP, this);
  }
  
  @Override public void destroy()
  {
    eventManager.deregister(EventType.LEVEL_UP, this);
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    coinFile = xmlComponent.getString("coinFile");
    tag = xmlComponent.getString("tag");
    
    spawnRelativeTo = xmlComponent.getString("spawnRelativeTo");
 
    maxSpawnWaitTime = xmlComponent.getInt("maxSpawnWaitTime");
    nextSpawnTime = int(random(minSpawnWaitTime, maxSpawnWaitTime));
    timePassed = 0;
    
    minHorizontalOffset = xmlComponent.getFloat("minHorizontalOffset");
    maxHorizontalOffset = xmlComponent.getFloat("maxHorizontalOffset");
    
    minVerticalOffset = xmlComponent.getFloat("minVerticalOffset");
    maxVerticalOffset = xmlComponent.getFloat("maxVerticalOffset");
    
    minHeight = xmlComponent.getFloat("minHeight");
    
    currentRiseSpeedParameterName = xmlComponent.getString("currentRiseSpeedParameterName");
    riseSpeed = 0.0f;
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.COIN_SPAWNER_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    timePassed += deltaTime;
    
    if (timePassed > nextSpawnTime)
    {
      spawnCoin();
      timePassed = 0;
      nextSpawnTime = int(random(minSpawnWaitTime, maxSpawnWaitTime));
    }
  }
  
  private void spawnCoin()
  {
    ArrayList<IGameObject> spawnRelativeToList = gameObjectManager.getGameObjectsByTag(spawnRelativeTo);
    
    int index = 0;
    while (index < spawnRelativeToList.size())
    {
      if (spawnRelativeToList.get(index).getTranslation().y < minHeight)
      {
        spawnRelativeToList.remove(index);
      }
      else
      {
        ++index;
      }
    }
    
    if (spawnRelativeToList.size() != 0)
    {
      IGameObject spawnRelativeToObject = spawnRelativeToList.get(int(random(0, spawnRelativeToList.size())));
      
      PVector translation = spawnRelativeToObject.getTranslation();
      PVector offset = new PVector(random(minHorizontalOffset, maxHorizontalOffset), random(minVerticalOffset, maxVerticalOffset));
      
      IGameObject coin = gameObjectManager.addGameObject(coinFile, translation.add(offset), new PVector(1.0, 1.0));
      coin.setTag(tag);
      IComponent component = coin.getComponent(ComponentType.RIGID_BODY);
      if (component != null)
      {
        RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
        rigidBodyComponent.setLinearVelocity(new PVector(0.0, -riseSpeed));
      }
    }
  }
  
  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.LEVEL_UP)
    {
      riseSpeed = event.getRequiredFloatParameter(currentRiseSpeedParameterName);
    }
  }
}

class ScoreTrackerComponent extends Component implements IEventListener
{
  private String scoreValueParameterName;
  private String scoreTextPrefix;
  private int totalScore;
  
  public ScoreTrackerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    totalScore = 0;
    
    eventManager.register(EventType.UPDATE_SCORE, this);
  }
  
  @Override public void destroy()
  {
    eventManager.deregister(EventType.UPDATE_SCORE, this);
    // add score obtained from game to cumulative score here.
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    scoreValueParameterName = xmlComponent.getString("scoreValueParameterName");
    scoreTextPrefix = xmlComponent.getString("scoreTextPrefix");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.SCORE_TRACKER;
  }
  
  @Override public void handleEvent(IEvent event)
  {
    totalScore += event.getRequiredIntParameter(scoreValueParameterName);
    
    IComponent component = gameObject.getComponent(ComponentType.RENDER);
    if (component != null)
    {
      RenderComponent renderComponent = (RenderComponent)component;
      RenderComponent.Text text = renderComponent.getTexts().get(0);
      if (text != null)
      {
        text.string = scoreTextPrefix + Integer.toString(totalScore);
      }
    }
  }
}

class CalibrateWizardComponent extends Component implements IEventListener
{
  ArrayList<String> actionsToRegister;
  String currentAction;
  
  public CalibrateWizardComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    actionsToRegister = new ArrayList<String>();
    actionsToRegister.add("LEFT");
    actionsToRegister.add("RIGHT");

    currentAction = actionsToRegister.remove(0);
    eventManager.register(EventType.COUNTDOWN_UPDATE, this);
  }
  
  @Override public void destroy()
  {
    eventManager.deregister(EventType.COUNTDOWN_UPDATE, this);
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    // can I read in actionsToRegister from XML?
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.CALIBRATE_WIZARD;
  }
  
  @Override public void handleEvent(IEvent event)
  {
    int countValue = event.getRequiredIntParameter("value");
    updateRenderComponent(countValue);

    if (countValue == 0)
    {
      // register action
      boolean success = emgManager.registerAction(currentAction);
      if (!success) {
        Event failureEvent = new Event(EventType.CALIBRATE_FAILURE);
        eventManager.queueEvent(failureEvent);
      }

      // increment action
      if (actionsToRegister.size() == 0)
      {
        Event successEvent = new Event(EventType.CALIBRATE_SUCCESS);
        eventManager.queueEvent(successEvent);
      }
      else {
        currentAction = actionsToRegister.remove(0);
      }

      // reset counter
      CountdownComponent c = (CountdownComponent) gameObject.getComponent(ComponentType.COUNTDOWN);
      c.reset();
    }
  }

  private void updateRenderComponent(int currentCount)
  {
    IComponent component = gameObject.getComponent(ComponentType.RENDER);
    if (component != null)
    {
      RenderComponent renderComponent = (RenderComponent)component;
      RenderComponent.Text text = renderComponent.getTexts().get(0);
      if (text != null)
      {
        text.string = currentAction + ": " + Integer.toString(currentCount);
      }
    }
  }
}


class CountdownComponent extends Component 
{
  private int value;
  private int countdownFrom;
  private int sinceLastTick;
  
  public CountdownComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    value = 0;
    countdownFrom = 0;
    sinceLastTick = 0;
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    countdownFrom = xmlComponent.getInt("countdownFrom");
    reset();
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.COUNTDOWN;
  }

  @Override public void update(int deltaTime)
  {
    sinceLastTick += deltaTime;
    if (sinceLastTick >= 1000)
    {
      value -= 1;
      sinceLastTick = 0;
      sendEvent();
    }

  }

  public void reset() {
    value = countdownFrom;
    sinceLastTick = 0;
    sendEvent();
  }

  private void sendEvent() {
    Event event = new Event(EventType.COUNTDOWN_UPDATE);
    event.addIntParameter("value", value);
    eventManager.queueEvent(event);
  }
}

class ButtonComponent extends Component implements IEventListener
{
  private int height;
  private int width;
  private SoundFile buttonClickedSound;

  public ButtonComponent(GameObject _gameObject)
  {
    super(_gameObject);

    height = 0;
    width = 0;

    eventManager.register(EventType.MOUSE_CLICKED, this);
  }

  @Override public void destroy()
  {
    eventManager.deregister(EventType.MOUSE_CLICKED, this);
  }

  @Override public void fromXML(XML xmlComponent)
  {
    // Multiply the height and width by the scale values to make the button that size
    height = xmlComponent.getInt("height") * (int)gameObject.getScale().y;
    width = xmlComponent.getInt("width") * (int)gameObject.getScale().x;
    buttonClickedSound = new SoundFile(mainObject, xmlComponent.getString("buttonClickedSound"));
    buttonClickedSound.rate(xmlComponent.getFloat("rate"));
    try { buttonClickedSound.pan(xmlComponent.getFloat("pan")); } catch (UnsupportedOperationException e) {}
    buttonClickedSound.amp(xmlComponent.getFloat("amp"));
    buttonClickedSound.add(xmlComponent.getFloat("add"));
  }

  @Override public ComponentType getComponentType()
  {
    return ComponentType.BUTTON;
  }

  @Override public void update(int deltaTime)
  {

  }

  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.MOUSE_CLICKED)
    {
      buttonClickedSound.play();
      
      float xButton = gameObject.getTranslation().x;
      float yButton = gameObject.getTranslation().y;

      int xMouse = event.getRequiredIntParameter("mouseX");
      int yMouse = event.getRequiredIntParameter("mouseY");

      if(xButton - 0.5 * width <= xMouse && xButton + 0.5 * width >= xMouse && yButton - 0.5 * height <= yMouse && yButton + 0.5 * height >= yMouse)
      {
        Event buttonEvent = new Event(EventType.BUTTON_CLICKED);
        buttonEvent.addStringParameter("tag",gameObject.getTag());
        eventManager.queueEvent(buttonEvent);
      }
    }
  }
}

class LevelDisplayComponent extends Component implements IEventListener
{
  private String currentLevelParameterName;
  private String levelTextPrefix;
  
  public LevelDisplayComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    eventManager.register(EventType.LEVEL_UP, this);
  }
  
  @Override public void destroy()
  {
    eventManager.deregister(EventType.LEVEL_UP, this);
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    currentLevelParameterName = xmlComponent.getString("currentLevelParameterName");
    levelTextPrefix = xmlComponent.getString("levelTextPrefix");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.LEVEL_DISPLAY;
  }
  
  @Override public void handleEvent(IEvent event)
  {
    if (event.getEventType() == EventType.LEVEL_UP)
    {
      IComponent component = gameObject.getComponent(ComponentType.RENDER);
      if (component != null)  
      {
         RenderComponent renderComponent = (RenderComponent)component;
         RenderComponent.Text text = renderComponent.getTexts().get(0);
         if (text != null)
         {
           text.string = levelTextPrefix + Integer.toString(event.getRequiredIntParameter(currentLevelParameterName));
         }
      }
    }    
  }
}

class LevelParametersComponent extends Component
{
  private int startingLevel;
  private int currentLevel;
  private int maxLevel;
  private float levelOneRiseSpeed;
  private float riseSpeedChangePerLevel;
  private float currentRiseSpeed;
  private int levelUpTime;
  private int timePassed;
  private int bonusScorePerLevel;
  private int timePerBonusScore;
  private String scoreValueParameterName;
  private int bonusTimePassed;
  private String currentLevelParameterName;
  private String currentRiseSpeedParameterName;
  private SoundFile levelUpSound;
  
  public LevelParametersComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    startingLevel = xmlComponent.getInt("startingLevel");
    currentLevel = startingLevel - 1;
    maxLevel = xmlComponent.getInt("maxLevel");
    levelOneRiseSpeed = xmlComponent.getFloat("levelOneRiseSpeed");
    riseSpeedChangePerLevel = xmlComponent.getFloat("riseSpeedChangePerLevel");
    currentRiseSpeed = levelOneRiseSpeed + (riseSpeedChangePerLevel * (currentLevel - 1));
    levelUpTime = xmlComponent.getInt("levelUpTime");
    timePassed = levelUpTime - 1;
    bonusScorePerLevel = xmlComponent.getInt("bonusScorePerLevel");
    timePerBonusScore = xmlComponent.getInt("timePerBonusScore");
    scoreValueParameterName = xmlComponent.getString("scoreValueParameterName");
    bonusTimePassed = 0;
    currentLevelParameterName = xmlComponent.getString("currentLevelParameterName");
    currentRiseSpeedParameterName = xmlComponent.getString("currentRiseSpeedParameterName");
    levelUpSound = new SoundFile(mainObject, xmlComponent.getString("levelUpSoundFile"));
    levelUpSound.rate(xmlComponent.getFloat("rate"));
    try { levelUpSound.pan(xmlComponent.getFloat("pan")); } catch (UnsupportedOperationException e) {}
    levelUpSound.amp(xmlComponent.getFloat("amp"));
    levelUpSound.add(xmlComponent.getFloat("add"));
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.LEVEL_PARAMETERS;
  }
  
  @Override public void update(int deltaTime)
  {
    timePassed += deltaTime;
    
    if (timePassed > levelUpTime)
    {
      if (currentLevel < maxLevel)
      {
        levelUp();
      }
      timePassed = 0;
    }
    
    bonusTimePassed += deltaTime;
    
    if (bonusTimePassed > timePerBonusScore)
    {
      Event updateScoreEvent = new Event(EventType.UPDATE_SCORE);
      updateScoreEvent.addIntParameter(scoreValueParameterName, bonusScorePerLevel * currentLevel);
      eventManager.queueEvent(updateScoreEvent);
      bonusTimePassed = 0;
    }
  }
  
  private void levelUp()
  {
    ++currentLevel;
    currentRiseSpeed += riseSpeedChangePerLevel;
    
    levelUpSound.play();
    
    Event levelUpEvent = new Event(EventType.LEVEL_UP);
    levelUpEvent.addIntParameter(currentLevelParameterName, currentLevel);
    levelUpEvent.addFloatParameter(currentRiseSpeedParameterName, currentRiseSpeed);
    eventManager.queueEvent(levelUpEvent);
  }
  
  public int getStartingLevel()
  {
    return startingLevel;
  }
  
  public int getCurrentLevel()
  {
    return currentLevel;
  }
  
  public int getMaxLevel()
  {
    return maxLevel;
  }
  
  public float getCurrentRiseSpeed()
  {
    return currentRiseSpeed;
  }
}

class MusicPlayerComponent extends Component
{
  SoundFile music;
  
  public MusicPlayerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  @Override public void destroy()
  {
    music.stop();
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    music = new SoundFile(mainObject, xmlComponent.getString("musicFile"));
    music.rate(xmlComponent.getFloat("rate"));
    // pan is not supported in stereo. that's fine, just continue.
    try { music.pan(xmlComponent.getFloat("pan")); } catch (UnsupportedOperationException e) {}
    music.amp(xmlComponent.getFloat("amp"));
    music.add(xmlComponent.getFloat("add"));
    music.loop();
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.MUSIC_PLAYER;
  }
  
  @Override public void update(int deltaTime)
  {
  }
}

IComponent componentFactory(GameObject gameObject, XML xmlComponent)
{
  IComponent component = null;
  String componentName = xmlComponent.getName();
  
  if (componentName.equals("Render"))
  {
    component = new RenderComponent(gameObject);
  }
  else if (componentName.equals("RigidBody"))
  {
    component = new RigidBodyComponent(gameObject);
  }
  else if (componentName.equals("PlayerController"))
  {
    component = new PlayerControllerComponent(gameObject);
  }
  else if (componentName.equals("PlatformManagerController"))
  {
    component = new PlatformManagerControllerComponent(gameObject);
  }
  else if (componentName.equals("CoinEventHandler"))
  {
    component = new CoinEventHandlerComponent(gameObject);
  }
  else if (componentName.equals("CoinSpawnerController"))
  {
    component = new CoinSpawnerControllerComponent(gameObject);
  }
  else if (componentName.equals("ScoreTracker"))
  {
    component = new ScoreTrackerComponent(gameObject);
  }
  else if (componentName.equals("CalibrateWizard"))
  {
    component = new CalibrateWizardComponent(gameObject);
  }
  else if (componentName.equals("Countdown"))
  {
    component = new CountdownComponent(gameObject);
  }
  else if (componentName.equals("LevelDisplay"))
  {
    component = new LevelDisplayComponent(gameObject);
  }
  else if (componentName.equals("LevelParameters"))
  {
    component = new LevelParametersComponent(gameObject);
  }
  else if (componentName.equals("Button"))
  {
    component = new ButtonComponent(gameObject);
  }
  else if (componentName.equals("MusicPlayer"))
  {
    component = new MusicPlayerComponent(gameObject);
  }
  
  if (component != null)
  {
    component.fromXML(xmlComponent);
  }
  
  return component;
}