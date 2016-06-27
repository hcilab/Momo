// Author: David Hanna
//
// Components are attached to Game Objects to provide their data and behaviour.
//======================================================================================================

//-------------------------------------------------------------------
// INTERFACE
//-------------------------------------------------------------------

public enum ComponentType
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
  SLIDER,
  STATS_COLLECTOR,
  POST_GAME_CONTROLLER,
  ANIMATION_CONTROLLER,
  GAME_OPTIONS_CONTROLLER,
  IO_OPTIONS_CONTROLLER,
  CALIBRATE_CONTROLLER,
  ID_COUNTER,
  FITTS_STATS,
  LOG_RAW_DATA,
}

public interface IComponent
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

public abstract class Component implements IComponent
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

public class RenderComponent extends Component
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
    public float strokeWeight;
    
    public Text(String _string, PFont _font, int _alignX, int _alignY, PVector _translation, color _fillColor, color _strokeColor, float _strokeWeight)
    {
      string = _string;
      font = _font;
      alignX = _alignX;
      alignY = _alignY;
      translation = _translation;
      fillColor = _fillColor;
      strokeColor = _strokeColor;
      strokeWeight = _strokeWeight;
    }
  }
  
  // Used only for the sprites on the Customize page
  public class CustomSprite
  {
    public OffsetSheetSprite sprite;
    public int cost;
    public String actualSrc;
    public int horzCount;
    public int vertCount;
    public int defaultCount;
    public float frameFreq;
    public boolean unlocked;
    public boolean active;

    public CustomSprite(OffsetSheetSprite _sprite, int _cost, String _actualSrc, int _horzCount, int _vertCount, int _defaultCount, float _frameFreq, String _unlocked, String _active)
    {
      sprite = _sprite;
      cost = _cost;
      actualSrc = _actualSrc;
      horzCount = _horzCount;
      vertCount = _vertCount;
      defaultCount = _defaultCount;
      frameFreq = _frameFreq;
      if (_unlocked.equals("true"))
      {
        unlocked = true;
      }
      else {
        unlocked = false;
      }

      if (_active.equals("true"))
      {
        active = true;
      }
      else {
        active = false;
      }
    }
  }

  private ArrayList<OffsetPShape> offsetShapes;
  private ArrayList<Text> texts;
  private ArrayList<OffsetSheetSprite> offsetSheetSprites;
  private ArrayList<OffsetPImage> offsetPImages;
  private ArrayList<CustomSprite> customSprites;

  public RenderComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    offsetShapes = new ArrayList<OffsetPShape>();
    texts = new ArrayList<Text>();
    offsetSheetSprites = new ArrayList<OffsetSheetSprite>();
    offsetPImages = new  ArrayList<OffsetPImage>();
    customSprites = new ArrayList<CustomSprite>();
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
      else if(xmlRenderable.getName().equals("SVG")){
         OffsetPShape offsetShape = new OffsetPShape(
         loadShape(xmlRenderable.getString("src")),
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("width"), xmlRenderable.getFloat("height"))
        );
         offsetShapes.add(offsetShape);
      }
      else if (xmlRenderable.getName().equals("Sprite")){
       for (XML xmlSpriteComponent : xmlRenderable.getChildren()){
         if(xmlSpriteComponent.getName().equals("SpriteSheet")){
           OffsetSheetSprite offsetSheetSprite = new OffsetSheetSprite(
               new Sprite(MyoFalldown.this, xmlSpriteComponent.getString("src"),xmlSpriteComponent.getInt("horzCount"), xmlSpriteComponent.getInt("vertCount"), xmlSpriteComponent.getInt("zOrder")),
               new PVector(xmlSpriteComponent.getFloat("x"), xmlSpriteComponent.getFloat("y")),
               new PVector(1, (xmlSpriteComponent.getFloat("scaleHeight")/xmlSpriteComponent.getFloat("height")))
            );
            offsetSheetSprite.sheetSprite.setFrameSequence(0, xmlSpriteComponent.getInt("defaultCount"), xmlSpriteComponent.getFloat("farmeFreq"));  
            offsetSheetSprite.sheetSprite.setDomain(-100,-100,width+100,height+100,Sprite.HALT);
            offsetSheetSprite.sheetSprite.setScale(xmlSpriteComponent.getFloat("scaleHeight")/xmlSpriteComponent.getFloat("height"));
            offsetSheetSprites.add(offsetSheetSprite);
         }
          else if(xmlSpriteComponent.getName().equals("Image")){
            OffsetPImage offsetsprite = new OffsetPImage(
              loadImage(xmlSpriteComponent.getString("src")),
              new PVector(xmlSpriteComponent.getFloat("x"), xmlSpriteComponent.getFloat("y")),
              new PVector(xmlSpriteComponent.getFloat("width"), xmlSpriteComponent.getFloat("height"))
            );
             offsetsprite.pimage.resize(xmlSpriteComponent.getInt("resizeWidth"),xmlSpriteComponent.getInt("resizeHeight"));
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
        
        float[] strokeWeight = new float[1];
        color[] fillAndStrokeColor = parseColorComponents(xmlRenderable, strokeWeight);
        if(xmlRenderable.getString("fontName").equals("Moire"))
        {
          texts.add(new Text(
            xmlRenderable.getString("string"),
            createFont("fonts/Raleway-Heavy.ttf", xmlRenderable.getInt("size"), xmlRenderable.getString("antialiasing").equals("true") ? true : false),
            alignX,
            alignY,
            new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
            fillAndStrokeColor[0],
            fillAndStrokeColor[1],
            strokeWeight[0]
          ));
        }
        else{
          texts.add(new Text(
            xmlRenderable.getString("string"),
            createFont("fonts/testfont.ttf", xmlRenderable.getInt("size"), xmlRenderable.getString("antialiasing").equals("true") ? true : false),
            alignX,
            alignY,
            new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
            fillAndStrokeColor[0],
            fillAndStrokeColor[1],
            strokeWeight[0]
          ));
        }
      }
      else if (xmlRenderable.getName().equals("CustomSprite"))
      {
        for (XML xmlSpriteComponent : xmlRenderable.getChildren()){
         if(xmlSpriteComponent.getName().equals("SpriteSheet")){
           CustomSprite customSprite = new CustomSprite(
                 new OffsetSheetSprite(
                 new Sprite(MyoFalldown.this, xmlSpriteComponent.getString("src"),xmlSpriteComponent.getInt("horzCount"), xmlSpriteComponent.getInt("vertCount"), xmlSpriteComponent.getInt("zOrder")),
                 new PVector(xmlSpriteComponent.getFloat("x"), xmlSpriteComponent.getFloat("y")),
                 new PVector(1, (xmlSpriteComponent.getFloat("scaleHeight")/xmlSpriteComponent.getFloat("height")))),
                 xmlRenderable.getInt("cost"),
                 xmlRenderable.getString("actualSrc"),
                 xmlSpriteComponent.getInt("horzCount"),
                 xmlSpriteComponent.getInt("vertCount"),
                 xmlSpriteComponent.getInt("defaultCount"),
                 xmlSpriteComponent.getFloat("farmeFreq"),
                 xmlRenderable.getString("unlocked"),
                 xmlRenderable.getString("active")
            );
            customSprite.sprite.sheetSprite.setFrameSequence(0, xmlSpriteComponent.getInt("defaultCount"), xmlSpriteComponent.getFloat("farmeFreq"));
            customSprite.sprite.sheetSprite.setDomain(-100,-100,width+100,height+100,Sprite.HALT);
            customSprite.sprite.sheetSprite.setScale(xmlSpriteComponent.getFloat("scaleHeight")/xmlSpriteComponent.getFloat("height"));
            offsetSheetSprites.add(customSprite.sprite);
            customSprites.add(customSprite);
          }
        }
      }
    }
  }
  
  private void parseShapeComponents(XML xmlShape, OffsetPShape offsetShape)
  {
    float[] strokeWeight = new float[1];
    color[] fillAndStrokeColor = parseColorComponents(xmlShape, strokeWeight);
    offsetShape.pshape.setFill(fillAndStrokeColor[0]);
    offsetShape.pshape.setStroke(fillAndStrokeColor[1]);
    offsetShape.pshape.setStrokeWeight(strokeWeight[0]);
  }
  
  // returns fill color in position 0 and stroke color in position 1
  private color[] parseColorComponents(XML xmlParent, float[] outStrokeWeight)
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
        outStrokeWeight[0] = xmlShapeComponent.getFloat("strokeWeight");
      }
    }
    
    return fillAndStrokeColor;
  }
  
  private color parseColor(XML xmlColor)
  {
    return color(xmlColor.getInt("r"), xmlColor.getInt("g"), xmlColor.getInt("b"), xmlColor.getInt("a"));
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
  
    for (OffsetSheetSprite offsetSprite: offsetSheetSprites)
    {
      offsetSprite.sheetSprite.setXY(gameObject.getTranslation().x + offsetSprite.translation.x, gameObject.getTranslation().y + offsetSprite.translation.y);
  
      if(gameObject.getTag().equals("player"))
      {
         IComponent animaionComponent = gameObject.getComponent(ComponentType.ANIMATION_CONTROLLER);
         AnimationControllerComponent animationComponent = (AnimationControllerComponent)animaionComponent;
         float[] direction = animationComponent.getDirection();
         offsetSprite.sheetSprite.setFrameSequence((int)direction[0], (int)direction[1], direction[2]);
      }
      offsetSprite.sheetSprite.setScale(gameObject.getScale().y * offsetSprite.scale.y);
      S4P.updateSprites(deltaTime / 1000.0f);
      offsetSprite.sheetSprite.draw();
    }
    
    for (OffsetPImage offsetImage : offsetPImages)
    {
       if(gameObject.getTag().equals("platform") || gameObject.getTag().equals("break_platform"))
       {
         PImage cropImg = offsetImage.pimage.get(0,0,ceil(gameObject.getScale().x)+1, (int)gameObject.getScale().y);
         image(cropImg, gameObject.getTranslation().x + offsetImage.translation.x, gameObject.getTranslation().y + offsetImage.translation.y,ceil(gameObject.getScale().x) *  offsetImage.scale.x+1, gameObject.getScale().y * offsetImage.scale.y);
       }
       else 
       {
         image(offsetImage.pimage, gameObject.getTranslation().x + offsetImage.translation.x, gameObject.getTranslation().y + offsetImage.translation.y,gameObject.getScale().x *  offsetImage.scale.x ,gameObject.getScale().y * offsetImage.scale.y );
       }
    }

    for (Text text : texts)
    {
      textFont(text.font);
      textAlign(text.alignX, text.alignY);
      fill(text.fillColor);
      stroke(text.strokeColor);
      strokeWeight(text.strokeWeight);
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

  public ArrayList<CustomSprite> getCustomSprites()
  {
    return customSprites;
  }
}

public class RigidBodyComponent extends Component
{
  private class OnCollideEvent
  {
    public String collidedWith;
    public EventType eventType;
    public HashMap<String, String> eventParameters;
  }

  private class OnExitEvent
  {
    public String exitFrom;
    public EventType eventType;
    public HashMap<String, String> eventParameters;
  }

  private Body body;
  public PVector latestForce;
  private ArrayList<OnCollideEvent> onCollideEvents;
  private ArrayList<OnExitEvent> onExitEvents;

  public RigidBodyComponent(IGameObject _gameObject) 
  {
    super(_gameObject);

    latestForce = new PVector();
    onCollideEvents = new ArrayList<OnCollideEvent>();
    onExitEvents = new ArrayList<OnExitEvent>();
  }
 
  @Override public void destroy() 
  {
    physicsWorld.destroyBody(body); 
  }  
 
  @Override public void fromXML(XML xmlComponent)  
  {  
    BodyDef bodyDefinition = new BodyDef();  
  
    String bodyType = xmlComponent.getString("type");  
    if (bodyType.equals("static")) 
    { 
      bodyDefinition.type = BodyType.STATIC; 
    }  
    else if (bodyType.equals("kinematic")) 
    {  
      bodyDefinition.type = BodyType.KINEMATIC; 
    }  
    else if (bodyType.equals("dynamic")) 
    {  
      bodyDefinition.type = BodyType.DYNAMIC; 
    } 
    else 
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
          }
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
            else if (stringEventType.equals("PLAYER_PLATFORM_COLLISION"))
            {
              onCollideEvent.eventType = EventType.PLAYER_PLATFORM_COLLISION;
              onCollideEvent.eventParameters = new HashMap<String, String>();
              onCollideEvent.eventParameters.put("platformParameterName", xmlOnCollideEvent.getString("platformParameterName"));
            }
            else if (stringEventType.equals("PLAYER_BREAK_PLATFORM_COLLISION"))
            {
              onCollideEvent.eventType = EventType.PLAYER_BREAK_PLATFORM_COLLISION;
              onCollideEvent.eventParameters = new HashMap<String, String>();
              onCollideEvent.eventParameters.put("breakPlatformParameterName", xmlOnCollideEvent.getString("breakPlatformParameterName"));
            }

            onCollideEvents.add(onCollideEvent);
          }
        }
      }
      else if (rigidBodyComponent.getName().equals("OnExitEvents"))
      {
        for (XML xmlOnCollideEvent : rigidBodyComponent.getChildren())
        {
          if (xmlOnCollideEvent.getName().equals("Event"))
          {
            OnExitEvent onExitEvent = new OnExitEvent();
            onExitEvent.exitFrom = xmlOnCollideEvent.getString("exitFrom");

            String stringEventType = xmlOnCollideEvent.getString("eventType");
            if (stringEventType.equals("PLAYER_PLATFORM_EXIT"))
            {
              onExitEvent.eventType = EventType.PLAYER_PLATFORM_EXIT;
              onExitEvent.eventParameters = new HashMap<String, String>();
              onExitEvent.eventParameters.put("platformParameterName", xmlOnCollideEvent.getString("platformParameterName"));
            }
            else if (stringEventType.equals("PLAYER_BREAK_PLATFORM_EXIT"))
            {
              onExitEvent.eventType = EventType.PLAYER_BREAK_PLATFORM_EXIT;
              onExitEvent.eventParameters = new HashMap<String, String>();
              onExitEvent.eventParameters.put("breakPlatformParameterName", xmlOnCollideEvent.getString("breakPlatformParameterName"));
            }

            onExitEvents.add(onExitEvent);
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
        else if (onCollideEvent.eventType == EventType.GAME_OVER)
        {
          eventManager.queueEvent(new Event(EventType.GAME_OVER));
        }
        else if (onCollideEvent.eventType == EventType.DESTROY_COIN) 
        {
          Event event = new Event(EventType.DESTROY_COIN);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("coinParameterName"), collider);
          eventManager.queueEvent(event);
        }
        else if (onCollideEvent.eventType == EventType.PLAYER_PLATFORM_COLLISION)
        {
          Event event = new Event(EventType.PLAYER_PLATFORM_COLLISION);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("platformParameterName"), collider);
          eventManager.queueEvent(event);
        }
        else if (onCollideEvent.eventType == EventType.PLAYER_BREAK_PLATFORM_COLLISION)
        {
          Event event = new Event(EventType.PLAYER_BREAK_PLATFORM_COLLISION);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("breakPlatformParameterName"), collider);
          eventManager.queueEvent(event);
        }
      }
    }
  }

  public void onExitEvent(IGameObject collider)
  {
    for (OnExitEvent onCollideEvent : onExitEvents)
    {
      if (onCollideEvent.exitFrom.equals(collider.getTag()))
      {
        if (onCollideEvent.eventType == EventType.PLAYER_PLATFORM_EXIT)
        {
          Event event = new Event(EventType.PLAYER_PLATFORM_EXIT);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("platformParameterName"), collider);
          eventManager.queueEvent(event);
        }
        else if (onCollideEvent.eventType == EventType.PLAYER_BREAK_PLATFORM_EXIT)
        {
          Event event = new Event(EventType.PLAYER_BREAK_PLATFORM_EXIT);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("breakPlatformParameterName"), collider);
          eventManager.queueEvent(event);
        }
      }
    }
  }
  
  public PVector getPosition()
  { 
    return new PVector(metersToPixels(body.getPosition().x), metersToPixels(body.getPosition().y)); 
  } 
  
  public PVector getLinearVelocity()
  {
    return new PVector(metersToPixels(body.getLinearVelocity().x), metersToPixels(body.getLinearVelocity().y));
  }
  
  public float getSpeed()
  {
    PVector linearVelocity = getLinearVelocity();
    return sqrt((linearVelocity.x * linearVelocity.x) + (linearVelocity.y * linearVelocity.y));
  }
  
  public PVector getAcceleration()
  { 
    return new PVector(metersToPixels(latestForce.x), metersToPixels(latestForce.y)); 
  }
  
  public void setPosition(PVector pos)  
  {  
    body.setTransform(new Vec2(pixelsToMeters(pos.x), body.getPosition().y),0);  
  }
  
  public void setPlatformPosition(PVector pos)  
  {  
    body.setTransform(new Vec2(body.getPosition().x, pixelsToMeters(pos.y)),0);  
  }
  
  public void setLinearVelocity(PVector linearVelocity)  
  {  
    body.setLinearVelocity(new Vec2(pixelsToMeters(linearVelocity.x), pixelsToMeters(linearVelocity.y)));  
  }  

  public void applyForce(PVector force, PVector position)  
  {  
    latestForce = force;  
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
 
public class PlayerControllerComponent extends Component 
{
  private PVector moveVectorX;
  private float acceleration;
  private float maxSpeed;
  private float minInputThreshold;
  private float jumpForce; 
  
  private String currentSpeedParameterName; 

  private String collidedPlatformParameterName;
  private String collidedBreakPlatformParameterName;
  private String gapDirection;
 
  private boolean upButtonDown; 
  private boolean leftButtonDown;
  private boolean rightButtonDown;
  
  private boolean leftMyoForce;
  private boolean rightMyoForce;
  
  private int jumpDelay;
  private int jumpTime;
  private int directionChanges;
  private boolean goingRight;
  private boolean goingLeft;
  private boolean notMoving;
  private int undershootCount;
  private int overshootCount;
  private int errors;
  private float currGapPosition;
  private float currGapWidth;
  private float currStartPoint;
  private boolean firstMove;
  private boolean onLeftSide;
  private boolean onRightSide;
  private int jumpCount; //<>// //<>//
  
  private SoundFile jumpSound;  //<>// //<>//
  private float amplitude; //<>// //<>//
 //<>// //<>//
 //<>// //<>//
  private SoundFile platformFallSound; //<>// //<>//
 //<>// //<>//
  private boolean onPlatform; //<>// //<>//
  private boolean onRegPlatform; //<>// //<>//
  private boolean onBreakPlatform; //<>// //<>//
  private IGameObject breakPlatform; //<>// //<>//
  private long breakTimerStart;
  private long crumbleTimerStart; //<>// //<>//
  private String crumblingPlatformFile; 
  private int platformLevelCount;
  private boolean justJumped;
  private HashMap<String, Float> rawInput;
  
  public PlayerControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);

    upButtonDown = false;
    leftButtonDown = false;
    rightButtonDown = false;
    onPlatform = false;
    onRegPlatform = false;
    onBreakPlatform = false;
    jumpCount = 0;
    justJumped = false;
    breakTimerStart = (long)Double.POSITIVE_INFINITY;
    moveVectorX = new PVector();
    platformLevelCount = 1;
  }

  @Override public void destroy()
  {

  }

  @Override public void fromXML(XML xmlComponent)
  {
    acceleration = xmlComponent.getFloat("acceleration");
    maxSpeed = xmlComponent.getFloat("maxSpeed");
    minInputThreshold = xmlComponent.getFloat("minInputThreshold");
    jumpForce = xmlComponent.getFloat("jumpForce");
    currentSpeedParameterName = xmlComponent.getString("currentSpeedParameterName");

    collidedPlatformParameterName = xmlComponent.getString("collidedPlatformParameterName");
    collidedBreakPlatformParameterName = xmlComponent.getString("collidedBreakPlatformParameterName");
    gapDirection = LEFT_DIRECTION_LABEL;
    jumpSound = new SoundFile(mainObject, xmlComponent.getString("jumpSoundFile"));
    jumpSound.rate(xmlComponent.getFloat("rate")); //<>//
    try { jumpSound.pan(xmlComponent.getFloat("pan")); } catch (UnsupportedOperationException e) {}
    amplitude = xmlComponent.getFloat("amp"); //<>//
    jumpSound.add(xmlComponent.getFloat("add")); //<>//
    jumpDelay = 500;
    platformFallSound = new SoundFile(mainObject, xmlComponent.getString("fallSoundFile")); //<>//
    platformFallSound.rate(xmlComponent.getFloat("rate")); //<>//
    try { platformFallSound.pan(xmlComponent.getFloat("pan")); } catch (UnsupportedOperationException e) {} //<>//
    platformFallSound.add(xmlComponent.getFloat("add")); //<>// //<>//
    crumblingPlatformFile = xmlComponent.getString("crumblePlatform"); //<>//
  } //<>//
 //<>// //<>//
  @Override public ComponentType getComponentType()
  {
    return ComponentType.PLAYER_CONTROLLER; //<>// //<>//
  } //<>//
 //<>//
  @Override public void update(int deltaTime)
  {
    
    handleEvents();
    rawInput = gatherRawInput();
    PVector moveVector = new PVector();
    
    if(!options.getGameOptions().getFittsLaw())
    {
      ControlPolicy policy = options.getGameOptions().getControlPolicy();
      if (policy == ControlPolicy.NORMAL)
        moveVector = applyNormalControls(rawInput);
      else if (policy == ControlPolicy.DIRECTION_ASSIST)
        moveVector = applyDirectionAssistControls(rawInput);
      else if (policy == ControlPolicy.SINGLE_MUSCLE)
        moveVector = applySingleMuscleControls(rawInput);
      else
        println("[ERROR] Invalid Control policy found in PlayerControllerComponent::update()");
    }
    else
    {
      if(onPlatform)
      {
      ControlPolicy policy = options.getGameOptions().getControlPolicy();
      if (policy == ControlPolicy.NORMAL)
        moveVector = applyNormalControls(rawInput);
      else if (policy == ControlPolicy.DIRECTION_ASSIST)
        moveVector = applyDirectionAssistControls(rawInput);
      else if (policy == ControlPolicy.SINGLE_MUSCLE)
        moveVector = applySingleMuscleControls(rawInput);
      else
        println("[ERROR] Invalid Control policy found in PlayerControllerComponent::update()");
      }
    }

    smoothControls(moveVector, deltaTime);

    IEvent currentSpeedEvent = new Event(EventType.PLAYER_CURRENT_SPEED);

    IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);

    moveVectorX = moveVector;

    if (component != null)
    {
      RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
      calculateOverShoots(rigidBodyComponent.getPosition());
      calculateDirectionChanges(moveVector, rigidBodyComponent.getPosition());
      
      if (options.getGameOptions().getBreakthroughMode() == BreakthroughMode.JUMP_3TIMES)
      {
        if (jumpCount >= 3 && onPlatform)
        {
          ++platformLevelCount;
          Event fittsLawLevelUp = new Event(EventType.PLAYER_BREAK_PLATFORM_FALL);
          fittsLawLevelUp.addIntParameter("platformLevel", platformLevelCount);
          eventManager.queueEvent(fittsLawLevelUp);

          jumpCount = 0;
          pc.setPlatformDescentSpeed(breakPlatform);
          platformFallSound.amp(amplitude * options.getIOOptions().getSoundEffectsVolume());
          platformFallSound.play();

          if(logFittsLaw)
          {
            IComponent componentFitts = gameObject.getComponent(ComponentType.FITTS_STATS);
            FittsStatsComponent fitsStats = (FittsStatsComponent)componentFitts;
            fitsStats.endLogLevel();
          }

          rigidBodyComponent.setPosition(new PVector(breakPlatform.getTranslation().x, 0));

          if(stillPlatforms)
          {
            pc.incrementPlatforms();
            pc.spawnPlatformLevelNoRiseSpeed();
          }
        }
      }
      else
      {
        if (System.currentTimeMillis() - crumbleTimerStart > 450 && breakPlatform != null)
        {
          crumbleTimerStart = System.currentTimeMillis();
          float crumbleScale = breakPlatform.getScale().x/2; 
          IGameObject crumblePlatform = gameStateController.getGameObjectManager().addGameObject(crumblingPlatformFile, new PVector(breakPlatform.getTranslation().x + random(-crumbleScale,crumbleScale), breakPlatform.getTranslation().y), new PVector(10, 10));
          crumblePlatform.setTag("crumble_platform");
          pc.setPlatformDescentSpeed(crumblePlatform);
        }
        if (System.currentTimeMillis() - breakTimerStart > 2000 && breakPlatform != null)
        {
          ++platformLevelCount;
          Event fittsLawLevelUp = new Event(EventType.PLAYER_BREAK_PLATFORM_FALL);
          fittsLawLevelUp.addIntParameter("platformLevel", platformLevelCount);
          eventManager.queueEvent(fittsLawLevelUp);

          breakTimerStart = System.currentTimeMillis();
          pc.setPlatformDescentSpeed(breakPlatform);
          platformFallSound.amp(amplitude * options.getIOOptions().getSoundEffectsVolume());
          platformFallSound.play();

          if(logFittsLaw)
          {
            IComponent componentFitts = gameObject.getComponent(ComponentType.FITTS_STATS);
            FittsStatsComponent fitsStats = (FittsStatsComponent)componentFitts;
            fitsStats.endLogLevel();
          }

          //Sets Momo in middle of break platform so player does not slow down against side of platforms
          rigidBodyComponent.setPosition(new PVector(breakPlatform.getTranslation().x, 0));

          if(stillPlatforms)
          {
            pc.incrementPlatforms();
            pc.spawnPlatformLevelNoRiseSpeed();
          }
        }
      }

      if (fittsLaw && rigidBodyComponent.gameObject.getTag().equals("player"))
      {
        if (onPlatform && (!leftButtonDown && !leftMyoForce) && (!rightButtonDown && !rightMyoForce) && !upButtonDown)
        {
          rigidBodyComponent.setLinearVelocity(new PVector(0,0));
        }
      }
      PVector linearVelocity = rigidBodyComponent.getLinearVelocity();  
      if (  (moveVector.x > 0 && linearVelocity.x < maxSpeed)
         || (moveVector.x < 0 && linearVelocity.x > -maxSpeed))
      {
        rigidBodyComponent.applyForce(new PVector(moveVector.x * acceleration * deltaTime, 0.0f), gameObject.getTranslation());
      }

      ArrayList<IGameObject> platformManagerList = gameStateController.getGameObjectManager().getGameObjectsByTag("platform_manager");
      if (!platformManagerList.isEmpty())
      {
        IComponent tcomponent = platformManagerList.get(0).getComponent(ComponentType.PLATFORM_MANAGER_CONTROLLER);  
        if (tcomponent != null)
        { 
          if (moveVector.y < -0.5f)
          {
            rigidBodyComponent.applyLinearImpulse(new PVector(0.0f, jumpForce), gameObject.getTranslation(), true); 
            jumpSound.amp(amplitude * options.getIOOptions().getSoundEffectsVolume());
            jumpSound.play();
            justJumped = true;
          }
        } 
      } 
       
      currentSpeedEvent.addFloatParameter(currentSpeedParameterName, rigidBodyComponent.getSpeed()); 
    } 
    else
    {
      gameObject.translate(moveVector);
      currentSpeedEvent.addFloatParameter(currentSpeedParameterName, sqrt((moveVector.x * moveVector.x) + (moveVector.y * moveVector.y)));
    }

    eventManager.queueEvent(currentSpeedEvent);
  }  

  private HashMap<String, Float> gatherRawInput() 
  {
    HashMap<String, Float> rawInput = emgManager.poll();

    Float keyboardLeftMagnitude;
    Float keyboardRightMagnitude;
    Float keyboardJumpMagnitude;

    Float myoLeftMagnitude;
    Float myoRightMagnitude;
    Float myoJumpMagnitude;

    if (fittsLaw)
    {
      if (onPlatform)
      {
        keyboardLeftMagnitude = leftButtonDown ? 1.0 : 0.0;
        keyboardRightMagnitude = rightButtonDown ? 1.0 : 0.0;
        keyboardJumpMagnitude = upButtonDown ? 1.0 : 0.0;

        myoLeftMagnitude = rawInput.get(LEFT_DIRECTION_LABEL);
        myoRightMagnitude = rawInput.get(RIGHT_DIRECTION_LABEL);
        myoJumpMagnitude = rawInput.get(JUMP_DIRECTION_LABEL);
      }
      else
      {
        // set left and right to zero - can't control movement when in the air
        keyboardLeftMagnitude = 0.0;
        keyboardRightMagnitude = 0.0;
        keyboardJumpMagnitude = upButtonDown ? 1.0 : 0.0;

        myoLeftMagnitude = 0.0;
        myoRightMagnitude = 0.0;
        myoJumpMagnitude = rawInput.get(JUMP_DIRECTION_LABEL);
      }
    }
    else
    {
      keyboardLeftMagnitude = leftButtonDown ? 1.0 : 0.0;
      keyboardRightMagnitude = rightButtonDown ? 1.0 : 0.0;
      keyboardJumpMagnitude = upButtonDown ? 1.0 : 0.0;

      myoLeftMagnitude = rawInput.get(LEFT_DIRECTION_LABEL);
      myoRightMagnitude = rawInput.get(RIGHT_DIRECTION_LABEL);
      myoJumpMagnitude = rawInput.get(JUMP_DIRECTION_LABEL);
    }

    // 0.1 for now, can be changed to higher/lower val
    // used as min required force to pick up movement
    leftMyoForce = rawInput.get(LEFT_DIRECTION_LABEL) > 0.1 ? true : false;
    rightMyoForce = rawInput.get(RIGHT_DIRECTION_LABEL) > 0.1 ? true : false;

    rawInput.put(LEFT_DIRECTION_LABEL, myoLeftMagnitude+keyboardLeftMagnitude);
    rawInput.put(RIGHT_DIRECTION_LABEL, myoRightMagnitude+keyboardRightMagnitude);
    rawInput.put(JUMP_DIRECTION_LABEL, myoJumpMagnitude+keyboardJumpMagnitude);
    return rawInput;
  }

  private PVector applyNormalControls(HashMap<String, Float> input)
  {
    PVector moveVector = new PVector();
    moveVector.x = input.get(RIGHT_DIRECTION_LABEL) - input.get(LEFT_DIRECTION_LABEL);
    moveVector.y = -input.get(JUMP_DIRECTION_LABEL);
    return moveVector;
  }
  
  private HashMap<String, Float> getRawInput()
  {
    return rawInput; 
  }

  private PVector applyDirectionAssistControls(HashMap<String, Float> input)
  {
    Float magnitude = 0.0;
    DirectionAssistMode mode = options.getGameOptions().getDirectionAssistMode();
    if (mode == DirectionAssistMode.LEFT_ONLY)
      magnitude = input.get(LEFT_DIRECTION_LABEL);
    else if (mode == DirectionAssistMode.RIGHT_ONLY)
      magnitude = input.get(RIGHT_DIRECTION_LABEL);
    else if (mode == DirectionAssistMode.BOTH)
      magnitude = input.get(LEFT_DIRECTION_LABEL) + input.get(RIGHT_DIRECTION_LABEL);
    else 
      println("[ERROR] Unrecognized control mode in PlayerControllerComponent::applyDirectionAssistControls"); 
    
    PVector moveVector = new PVector(); 
    if (gapDirection == LEFT_DIRECTION_LABEL) 
      moveVector.x = -magnitude;
    else 
      moveVector.x = magnitude;

    return moveVector;
  }

  private PVector applySingleMuscleControls(HashMap<String, Float> input)
  {
    PVector moveVector = new PVector();

    SingleMuscleMode mode = options.getGameOptions().getSingleMuscleMode();
    if (mode == SingleMuscleMode.AUTO_LEFT)
      moveVector.x = -1 + 2*input.get(RIGHT_DIRECTION_LABEL);
    else if (mode == SingleMuscleMode.AUTO_RIGHT)
      moveVector.x = 1 - 2*input.get(LEFT_DIRECTION_LABEL);
    else
      println("[ERROR] Unrecognized single muscle mode in PlayerControllerComponent::applySingleMuscleControls");

    return moveVector; 
  }

  public PVector getLatestMoveVector()
  {
    return moveVectorX;
  }
  
  public void calculateOverShoots(PVector pos)
  {
    if((pos.x > (currGapPosition + currGapWidth) && onLeftSide))
    {
      overshootCount++;
      onLeftSide = false;
      onRightSide = true;
    }
    else if((pos.x < (currGapPosition - currGapWidth) && onRightSide))
    {
      overshootCount++;
      onLeftSide = true;
      onRightSide = false;
    }
  }
  
  //And UnderShoots
  public void calculateDirectionChanges(PVector mVector, PVector pos)
  { 
    if(mVector.x < 0)
    {
      if(!goingLeft)
      {
        goingLeft = true;
        goingRight = false;
        directionChanges++;
      }
      notMoving = false;
      firstMove = false;
    }
    else if(mVector.x > 0)
    {
      if(!goingRight)
      {
        goingRight =true;
        goingLeft=false;
        directionChanges++;
      }
      notMoving = false;
      firstMove = false;
    }
    else if(mVector.x == 0)
    {
      if(!notMoving && !firstMove)
      {
        if((pos.x > (currGapPosition + currGapWidth)) || (pos.x < (currGapPosition - currGapWidth)))
        {
          errors++;
        } 
        if(goingLeft && (pos.x > (currGapPosition + currGapWidth)))
        {
          undershootCount++;
        }
        else if(goingRight && (pos.x < (currGapPosition - currGapWidth)))
        {
          undershootCount++;
        }
      }
      notMoving = true;
    }
  }
  
  public int getDirerctionChanges()
  {
    return directionChanges;
  }
  
  public int getUnderShoots()
  {
    return undershootCount;
  }
  
  public int getOverShoots()
  {
    return overshootCount;
  }
  
  public int getErrors()
  {
    return errors; 
  }
  
  public void setLoggingValuesZero(float gapPos, float halfGapWidth, float startingPosition)
  {
    firstMove = true;
    directionChanges = 0;
    undershootCount = 0;
    overshootCount=0;
    currGapPosition = gapPos;
    currGapWidth = halfGapWidth;
    currStartPoint = startingPosition;
    errors =0;
    if(currStartPoint < currGapPosition)
    {
      onLeftSide = true;
      onRightSide = false; 
    }
    else
    {
      onLeftSide = false;
      onRightSide = true; 
    }
  }
 
  private void handleEvents() 
  { 
    if (eventManager.getEvents(EventType.UP_BUTTON_PRESSED).size() > 0) 
      upButtonDown = true; 
 
    if (eventManager.getEvents(EventType.LEFT_BUTTON_PRESSED).size() > 0) 
      leftButtonDown = true; 

    if (eventManager.getEvents(EventType.RIGHT_BUTTON_PRESSED).size() > 0)
      rightButtonDown = true;
 
    if (eventManager.getEvents(EventType.UP_BUTTON_RELEASED).size() > 0) 
      upButtonDown = false;
      
    if (eventManager.getEvents(EventType.LEFT_BUTTON_RELEASED).size() > 0) 
      leftButtonDown = false;
      
    if (eventManager.getEvents(EventType.RIGHT_BUTTON_RELEASED).size() > 0) 
      rightButtonDown = false; 
      
    for (IEvent event : eventManager.getEvents(EventType.PLAYER_PLATFORM_COLLISION))
    {
      onPlatform = true;
      onRegPlatform = true;
      justJumped = false;
      IGameObject platform = event.getRequiredGameObjectParameter(collidedPlatformParameterName); 
      gapDirection = determineGapDirection(platform); 
      jumpCount = 0;
    }

    for (IEvent event : eventManager.getEvents(EventType.PLAYER_PLATFORM_EXIT))
    {
      if (!onBreakPlatform)
      {
        onPlatform = false;
      }
      onRegPlatform = false;
      jumpCount = 0;
    }

    for (IEvent event : eventManager.getEvents(EventType.PLAYER_BREAK_PLATFORM_COLLISION))
    {
      onPlatform = true;
      if (!onBreakPlatform)
      {
        breakTimerStart = System.currentTimeMillis();
        crumbleTimerStart = System.currentTimeMillis();
      }

      onBreakPlatform = true;
      IGameObject platform = event.getRequiredGameObjectParameter(collidedBreakPlatformParameterName);
      breakPlatform = platform;
      
      if (justJumped && (options.getGameOptions().getBreakthroughMode() == BreakthroughMode.JUMP_3TIMES))
      {
        jumpCount++;
        justJumped = false;
        float crumbleScale = breakPlatform.getScale().x/2; 
        IGameObject crumblePlatform = gameStateController.getGameObjectManager().addGameObject(crumblingPlatformFile, new PVector(breakPlatform.getTranslation().x + random(-crumbleScale,crumbleScale), breakPlatform.getTranslation().y), new PVector(10, 10));
        crumblePlatform.setTag("crumble_platform");
        pc.setPlatformDescentSpeed(crumblePlatform);
        crumblePlatform = gameStateController.getGameObjectManager().addGameObject(crumblingPlatformFile, new PVector(breakPlatform.getTranslation().x + random(-crumbleScale,crumbleScale), breakPlatform.getTranslation().y), new PVector(10, 10));
        crumblePlatform.setTag("crumble_platform");
        pc.setPlatformDescentSpeed(crumblePlatform);
      }
    }

    for (IEvent event : eventManager.getEvents(EventType.PLAYER_BREAK_PLATFORM_EXIT))
    {
      if (!onRegPlatform)
      {
        onPlatform = false;
      }
      onBreakPlatform = false;
      breakTimerStart = (long) Double.POSITIVE_INFINITY;
      breakPlatform = null;
    }
  }

  private String determineGapDirection(IGameObject platform) 
  {
    IGameObject leftWall = gameStateController.getGameObjectManager().getGameObjectsByTag("left_wall").get(0); 
    assert (leftWall != null); 
 
    float wallWidth = leftWall.getScale().x; 
    float playerWidth = gameObject.getScale().x; 
    float platformPositionX = platform.getTranslation().x; 
    float platformWidth = platform.getScale().x; 
 
    String direction = ""; 

    if (platformPositionX <= platformWidth/2.0 + wallWidth + playerWidth)
    {
      // platform extends all the way to left wall (i.e., no gap to the left)
      direction = RIGHT_DIRECTION_LABEL;
    } 
    else 
    { 
      direction = LEFT_DIRECTION_LABEL;
    }
    return direction;
  } 

  private void smoothControls(PVector moveVector, int deltaTime)
  {
    if (moveVector.x > -minInputThreshold && moveVector.x < minInputThreshold)
    {
      moveVector.x = 0.0f;
    }
    else if (moveVector.x < 0.0f) 
    {  
      moveVector.x += minInputThreshold;  
      moveVector.x *= options.getIOOptions().getLeftEMGSensitivity() * (1.0f - minInputThreshold);  
  
      if (moveVector.x < -1.0f)  
      {  
        moveVector.x = -1.0f;  
      } 
    }
    else
    { 
      moveVector.x -= minInputThreshold; 
      moveVector.x *= options.getIOOptions().getRightEMGSensitivity() * (1.0f - minInputThreshold); 
 

      if (moveVector.x > 1.0f)
      {
        moveVector.x = 1.0f;
      }
    } 
 
    jumpTime += deltaTime; 
    if (moveVector.y < -0.5  && jumpTime > jumpDelay)  
    { 
      jumpTime = 0; 
    }
    else
    {
      moveVector.y = 0.0f;
    }
  }
}

public class PlatformManagerControllerComponent extends Component
{ 
  private LinkedList<IGameObject> platforms; 
  private String platformFile;  
  private String breakPlatformFile;
  private String slipperyPlatformFile;  
  private float slipperyPlatformChance; 
  private String stickyPlatformFile; 
  private float stickyPlatformChance;
  private String tag; 
  
  private int maxPlatformLevels;
  
  private float leftSide;
  private float rightSide;
  
  private float platformHeight;
  
  private float disappearHeight;
  private float spawnHeight;

  private int minGapsPerLevel;
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
  
  private float minHeightBetweenPlatformLevels;
  private float maxHeightBetweenPlatformLevels; 
  private float nextHeightBetweenPlatformLevels; 

  private String currentRiseSpeedParameterName;
  private float riseSpeed;
  private int inputPlatformCounter;
  
  private boolean firstIteration;
  private boolean rising;
  private int initialHeight;
  private int thresholdHeight;
  private RigidBodyComponent initialPlat;

  public PlatformManagerControllerComponent(IGameObject _gameObject)
  {
    super (_gameObject);
    
    platforms = new LinkedList<IGameObject>();
    platformLevels = new ArrayList<ArrayList<Integer>>();
    platformGapPosition = new ArrayList<PVector>();
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    platformFile = xmlComponent.getString("platformFile");
    breakPlatformFile = xmlComponent.getString("breakPlatformFile");
    slipperyPlatformFile = xmlComponent.getString("slipperyPlatformFile");
    slipperyPlatformChance = xmlComponent.getFloat("slipperyPlatformChance");
    stickyPlatformFile = xmlComponent.getString("stickyPlatformFile");
    stickyPlatformChance = xmlComponent.getFloat("stickyPlatformChance");
    tag = xmlComponent.getString("tag");
    maxPlatformLevels = xmlComponent.getInt("maxPlatformLevels");
    leftSide = xmlComponent.getFloat("leftSide");
    rightSide = xmlComponent.getFloat("rightSide");
    platformHeight = xmlComponent.getFloat("platformHeight");
    disappearHeight = xmlComponent.getFloat("disappearHeight");
    spawnHeight = xmlComponent.getFloat("spawnHeight");
    if (fittsLaw)
    {
      minGapsPerLevel = 1;
      maxGapsPerLevel = 1;
    }
    else
    {
      minGapsPerLevel = xmlComponent.getInt("minGapsPerLevel");
      maxGapsPerLevel = xmlComponent.getInt("maxGapsPerLevel");
    }
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
    minHeightBetweenPlatformLevels = xmlComponent.getFloat("minHeightBetweenPlatformLevels");
    maxHeightBetweenPlatformLevels = xmlComponent.getFloat("maxHeightBetweenPlatformLevels");
    nextHeightBetweenPlatformLevels = random(minHeightBetweenPlatformLevels, maxHeightBetweenPlatformLevels);
    currentRiseSpeedParameterName = xmlComponent.getString("currentRiseSpeedParameterName");
    riseSpeed = 0.0f;
    firstIteration = true;
    rising = false;
    initialHeight = 0;
    thresholdHeight = 125;
    initialPlat = null;
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.PLATFORM_MANAGER_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    handleEvents();
    
    while (!platforms.isEmpty() && platforms.getFirst().getTranslation().y < disappearHeight)
    {
      IGameObject platform = platforms.removeFirst();
      gameStateController.getGameObjectManager().removeGameObject(platform.getUID());
    }
    
    if (platforms.isEmpty()
      || (platforms.size() < maxPlatformLevels && ((spawnHeight - platforms.getLast().getTranslation().y) > nextHeightBetweenPlatformLevels)))
    {
      if (riseSpeed > 0.0f)
      {
        if(!stillPlatforms)
        {
          if(!((totalRowCountInput <= inputPlatformCounter) && inputPlatformGaps))
          {
            spawnPlatformLevel();
          }
        }
        else
        {
          if(totalRowCountInput > inputPlatformCounter)
          {
            spawnPlatformLevelNoRiseSpeed();
            incrementPlatforms();
            spawnPlatformLevelNoRiseSpeed();
            incrementPlatforms();
            spawnPlatformLevelNoRiseSpeed();
            firstIteration = false;
          }
        }
        nextHeightBetweenPlatformLevels = random(minHeightBetweenPlatformLevels, maxHeightBetweenPlatformLevels);
      }
    }

    if (rising)
    {
      if (initialHeight - initialPlat.getPosition().y >= thresholdHeight)
      {
        for (IGameObject platform : platforms)
        {
          IComponent component = platform.getComponent(ComponentType.RIGID_BODY);
          if (component != null)
          {
            RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
            rigidBodyComponent.setLinearVelocity(new PVector(0.0, 0.0));
          }
        }
        rising = false;
      }
    }
  }
  
  private void spawnPlatformLevel()
  {
    ArrayList<PVector> platformRanges = new ArrayList<PVector>();
    platformRanges.add(new PVector(leftSide, rightSide));
    ArrayList<Integer> platLevels = new ArrayList<Integer>();
    int gapsInLevel = int(random(minGapsPerLevel, maxGapsPerLevel + 1));
    int rangeSelector;
    PVector range;
    if(inputPlatformGaps)
    {
      rangeSelector = int(random(0, platformRanges.size() - 1));
      range = platformRanges.get(rangeSelector);
      
      TableRow row = tableInput.getRow(inputPlatformCounter);
      float gapPosition = row.getFloat("placement")  + 12;
      float halfGapWidth = row.getFloat("halfWidth");
      platformGapPosition.add(new PVector(gapPosition,halfGapWidth));
      platformRanges.add(rangeSelector + 1, new PVector(gapPosition + halfGapWidth, range.y));
      range.y = gapPosition - halfGapWidth;
      
      if(fittsLaw)
      {
        IGameObject breakPlatform = gameStateController.getGameObjectManager().addGameObject(breakPlatformFile, new PVector(gapPosition, spawnHeight), new PVector(halfGapWidth*2, platformHeight));
        breakPlatform.setTag("break_platform");
        setPlatformRiseSpeed(breakPlatform);
        platforms.add(breakPlatform);
        platLevels.add(breakPlatform.getUID());
      }
    inputPlatformCounter++;
    }
    else
    {
      for (int i = 0; i < gapsInLevel; ++i)
      {
        rangeSelector = int(random(0, platformRanges.size() - 1));
        range = platformRanges.get(rangeSelector);
        float rangeWidth = range.y - range.x;
        float rangeWidthMinusDistanceBetweenGaps = rangeWidth - minDistanceBetweenGaps;
        if (rangeWidthMinusDistanceBetweenGaps < minGapSize)
        {
          continue;
        }
        float halfGapWidth = random(minGapSize, min(maxGapSize, rangeWidthMinusDistanceBetweenGaps)) / 2.0;
        float gapPosition = random(range.x + minDistanceBetweenGaps + halfGapWidth, range.y - minDistanceBetweenGaps - halfGapWidth);
        platformGapPosition.add(new PVector(gapPosition,halfGapWidth));
        platformRanges.add(rangeSelector + 1, new PVector(gapPosition + halfGapWidth, range.y));
        range.y = gapPosition - halfGapWidth;
        //Have to change to see if we need break platforms
        if(fittsLaw)
        {
          IGameObject breakPlatform = gameStateController.getGameObjectManager().addGameObject(breakPlatformFile, new PVector(gapPosition, spawnHeight), new PVector(halfGapWidth*2, platformHeight));
          breakPlatform.setTag("break_platform");
          setPlatformRiseSpeed(breakPlatform);
          platforms.add(breakPlatform);
          platLevels.add(breakPlatform.getUID());
        }
      }
    }
    
    for (PVector platformRange : platformRanges)
    {
      float platformPosition = (platformRange.x + platformRange.y) / 2.0f;
      float platformWidth = platformRange.y - platformRange.x;
      
      IGameObject platform;
      
      if (options.getGameOptions().getPlatformMods())
      {
        if (random(0.0, 1.0) < slipperyPlatformChance)
        {
          platform = gameStateController.getGameObjectManager().addGameObject(slipperyPlatformFile, new PVector(platformPosition, spawnHeight), new PVector(platformWidth, platformHeight));
        }
        else if (random(0.0, 1.0) < stickyPlatformChance)
        {
          platform = gameStateController.getGameObjectManager().addGameObject(stickyPlatformFile, new PVector(platformPosition, spawnHeight), new PVector(platformWidth, platformHeight));
        }
        else
        {
          platform = gameStateController.getGameObjectManager().addGameObject(platformFile, new PVector(platformPosition, spawnHeight), new PVector(platformWidth, platformHeight));
        }
      }
      else
      {
        platform = gameStateController.getGameObjectManager().addGameObject(platformFile, new PVector(platformPosition, spawnHeight), new PVector(platformWidth, platformHeight));
      }
      
      platform.setTag(tag);
      setPlatformRiseSpeed(platform);
      platforms.add(platform);
      platLevels.add(platform.getUID());
      
      if (options.getGameOptions().getObstacles())
      {
        float generateObstacle = random(0.0, 1.0);
        if ((generateObstacle < obstacleChance) && platformWidth > 8)
        {
          float obstacleWidth = random(obstacleMinWidth, obstacleMaxWidth);
          float obstacleHeight = random(obstacleMinHeight, obstacleMaxHeight);
          
          float obstacleOffset = random((-platformWidth/2)+obstacleWidth, platformWidth/2-obstacleWidth);

          IGameObject obstacle = gameStateController.getGameObjectManager().addGameObject(
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
    platformLevels.add(platLevels);
  }
  
  public void spawnPlatformLevelNoRiseSpeed()
  {
      float tempSpawnHeight = spawnHeight;
      ArrayList<PVector> platformRanges = new ArrayList<PVector>();
      platformRanges.add(new PVector(leftSide, rightSide));
      ArrayList<Integer> platLevels = new ArrayList<Integer>();
  
      int rangeSelector = int(random(0, platformRanges.size() - 1));
      PVector range = platformRanges.get(rangeSelector);
      if(inputPlatformGaps)
      {
        if(totalRowCountInput > inputPlatformCounter)
        {
          TableRow row = tableInput.getRow(inputPlatformCounter);
          float gapPosition = row.getFloat("placement") + 12;
          float halfGapWidth = row.getFloat("halfWidth");
          platformGapPosition.add(new PVector(gapPosition,halfGapWidth));
          platformRanges.add(rangeSelector + 1, new PVector(gapPosition + halfGapWidth, range.y));
          range.y = gapPosition - halfGapWidth;
              
          if(fittsLaw)
          {
            IGameObject breakPlatform = gameStateController.getGameObjectManager().addGameObject(breakPlatformFile, new PVector(gapPosition, spawnHeight), new PVector(halfGapWidth*2, platformHeight));
            breakPlatform.setTag("break_platform");
            platforms.add(breakPlatform);
            platLevels.add(breakPlatform.getUID());
          }
        }
        else if (totalRowCountInput == inputPlatformCounter)
        {
          inputPlatformCounter++;
        }
        else
        {
          eventManager.queueEvent(new Event(EventType.GAME_OVER));
        }
        inputPlatformCounter++;
      }
      else
      {
        int gapsInLevel = int(random(minGapsPerLevel, maxGapsPerLevel + 1)); 
        for (int i = 0; i < gapsInLevel; ++i)
        {
          rangeSelector = int(random(0, platformRanges.size() - 1));
          range = platformRanges.get(rangeSelector);
          float rangeWidth = range.y - range.x;
          float rangeWidthMinusDistanceBetweenGaps = rangeWidth - minDistanceBetweenGaps;
          if (rangeWidthMinusDistanceBetweenGaps < minGapSize)
          {
            continue;
          }
          float halfGapWidth = random(minGapSize, min(maxGapSize, rangeWidthMinusDistanceBetweenGaps)) / 2.0;
          float gapPosition = random(range.x + minDistanceBetweenGaps + halfGapWidth, range.y - minDistanceBetweenGaps - halfGapWidth);
          platformGapPosition.add(new PVector(gapPosition,halfGapWidth));
          platformRanges.add(rangeSelector + 1, new PVector(gapPosition + halfGapWidth, range.y));
          range.y = gapPosition - halfGapWidth;
          if(fittsLaw)
          {
            IGameObject breakPlatform = gameStateController.getGameObjectManager().addGameObject(breakPlatformFile, new PVector(gapPosition, spawnHeight), new PVector(halfGapWidth*2, platformHeight));
            breakPlatform.setTag("break_platform");
            platforms.add(breakPlatform);
            platLevels.add(breakPlatform.getUID());
          }
        }
      }
   
      for (PVector platformRange : platformRanges)
      {
        float platformPosition = (platformRange.x + platformRange.y) / 2.0f;
        float platformWidth = platformRange.y - platformRange.x;
        
        IGameObject platform;
        platform = gameStateController.getGameObjectManager().addGameObject(platformFile, new PVector(platformPosition, tempSpawnHeight), new PVector(platformWidth, platformHeight));

        platform.setTag(tag);
        platforms.add(platform);
        platLevels.add(platform.getUID());
      }
      platformLevels.add(platLevels);
  }
  
  public void incrementPlatforms()
  {
    if (firstIteration)
    {
      for(IGameObject platform : platforms)
      {
        IComponent component = platform.getComponent(ComponentType.RIGID_BODY);
        if (component != null)
        {
          RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
          rigidBodyComponent.setPlatformPosition(new PVector(0.0, rigidBodyComponent.getPosition().y-125));
        }
      }
    }
    else
    {
      rising = true;
      for(IGameObject platform : platforms)
      {
        IComponent component = platform.getComponent(ComponentType.RIGID_BODY);
        if (component != null)
        {
          RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
          if (platform.getUID() == platforms.get(2).getUID())
          {
            initialPlat = rigidBodyComponent;
            initialHeight = (int)rigidBodyComponent.getPosition().y;
          }
          rigidBodyComponent.setLinearVelocity(new PVector(0.0, -50));
        }
      }
    }
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.LEVEL_UP))
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

  private void setPlatformDescentSpeed(IGameObject platform)
  {
    IComponent component = platform.getComponent(ComponentType.RIGID_BODY);
    if (component != null)
    {
      RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
      rigidBodyComponent.setLinearVelocity(new PVector(0.0, 300));
    }
    platforms.remove(platform);
  }
}

public class CoinEventHandlerComponent extends Component
{
  private int scoreValue;
  private String coinCollectedCoinParameterName;
  private String scoreValueParameterName;
  
  private SoundFile coinCollectedSound;
  private float amplitude;
  
  private String destroyCoinCoinParameterName;
  
  private String currentRiseSpeedParameterName;

  public CoinEventHandlerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  @Override public void destroy()
  {
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
        amplitude = xmlCoinEventComponent.getFloat("amp");
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
  
  @Override public void update(int deltaTime)
  {
    handleEvents();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.COIN_COLLECTED))
    {
      if (event.getRequiredGameObjectParameter(coinCollectedCoinParameterName).getUID() == gameObject.getUID())
      {
        Event updateScoreEvent = new Event(EventType.UPDATE_SCORE);
        updateScoreEvent.addIntParameter(scoreValueParameterName, scoreValue);
        eventManager.queueEvent(updateScoreEvent);
        gameStateController.getGameObjectManager().removeGameObject(gameObject.getUID());
        coinCollectedSound.amp(amplitude * options.getIOOptions().getSoundEffectsVolume());
        coinCollectedSound.play();
      }
    }
    for (IEvent event : eventManager.getEvents(EventType.DESTROY_COIN))
    {
      if (event.getRequiredGameObjectParameter(destroyCoinCoinParameterName).getUID() == gameObject.getUID())
      {
        gameStateController.getGameObjectManager().removeGameObject(gameObject.getUID());
      }
    }
    for (IEvent event : eventManager.getEvents(EventType.LEVEL_UP))
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

public class CoinSpawnerControllerComponent extends Component
{
  private String coinFile;
  private String tag;
  
  private String spawnRelativeTo;
  private int levelOneAvgSpawnTime;
  private int spawnTimeDecreasePerLevel;
  private int spawnTimeRandomWindowSize;
  private int nextSpawnTime;
  private int timePassed;
  
  private float minVerticalOffset;
  private float maxVerticalOffset;
  
  private float minHeight;
  
  private String currentLevelParameterName;
  private int currentLevel;
  private String currentRiseSpeedParameterName;
  private float riseSpeed;
  
  public CoinSpawnerControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    coinFile = xmlComponent.getString("coinFile");
    tag = xmlComponent.getString("tag");
    
    spawnRelativeTo = xmlComponent.getString("spawnRelativeTo");
 
    levelOneAvgSpawnTime = xmlComponent.getInt("levelOneAvgSpawnTime");
    spawnTimeDecreasePerLevel = xmlComponent.getInt("spawnTimeDecreasePerLevel");
    spawnTimeRandomWindowSize = xmlComponent.getInt("spawnTimeRandomWindowSize");
    nextSpawnTime = calculateNextSpawnTime();
    timePassed = 0;
    
    minVerticalOffset = xmlComponent.getFloat("minVerticalOffset");
    maxVerticalOffset = xmlComponent.getFloat("maxVerticalOffset");
    
    minHeight = xmlComponent.getFloat("minHeight");
    
    currentLevelParameterName = xmlComponent.getString("currentLevelParameterName");
    currentLevel = 1;
    currentRiseSpeedParameterName = xmlComponent.getString("currentRiseSpeedParameterName");
    riseSpeed = 0.0f;
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.COIN_SPAWNER_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    if ((options.getGameOptions().getControlPolicy() == ControlPolicy.NORMAL) && !fittsLaw && !inputPlatformGaps)
    {
      handleEvents();
    
      timePassed += deltaTime;
      
      if (timePassed > nextSpawnTime)
      {
        spawnCoin();
        timePassed = 0;
        nextSpawnTime = calculateNextSpawnTime();
      }
    }
  }
  
  private void spawnCoin()
  {
    ArrayList<IGameObject> spawnRelativeToList = gameStateController.getGameObjectManager().getGameObjectsByTag(spawnRelativeTo);
    //ArrayList<IGameObject> spawnRelativeObstacle = gameStateController.getGameObjectManager().getGameObjectsByTag("obstacle");
    
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
    //To make coin not appear in 
    //int indexObstacle = 0;
    //while (indexObstacle < spawnRelativeObstacle.size() && spawnRelativeToList.size() != 0)
    //{
    //  if (spawnRelativeObstacle.get(indexObstacle).getTranslation().y + spawnRelativeObstacle.get(indexObstacle).getScale().y < minHeight)
    //  {
    //    spawnRelativeObstacle.remove(indexObstacle);
    //  }
    //  else
    //  {
    //    //println("obstacle: " + spawnRelativeObstacle.get(indexObstacle).getTranslation().y);
    //    ++indexObstacle;
    //  }
    //}
    
    if (spawnRelativeToList.size() != 0)
    {
      IGameObject spawnRelativeToObject = spawnRelativeToList.get(int(random(0, spawnRelativeToList.size())));
      
      PVector translation = spawnRelativeToObject.getTranslation();
      PVector offset = new PVector(random((-spawnRelativeToObject.getScale().x/2)+15, spawnRelativeToObject.getScale().x/2-15), random(minVerticalOffset, maxVerticalOffset));
      IGameObject coin = gameStateController.getGameObjectManager().addGameObject(coinFile, translation.add(offset), new PVector(1.0, 1.0));
      coin.setTag(tag);
      IComponent component = coin.getComponent(ComponentType.RIGID_BODY);
      if (component != null)
      {
        RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
        rigidBodyComponent.setLinearVelocity(new PVector(0.0, -riseSpeed));
      }
    }
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.LEVEL_UP))
    {
      currentLevel = event.getRequiredIntParameter(currentLevelParameterName);
      riseSpeed = event.getRequiredFloatParameter(currentRiseSpeedParameterName);
    }
  }

  private int calculateNextSpawnTime()
  {
    int avgSpawnTime = levelOneAvgSpawnTime - (currentLevel-1)*spawnTimeDecreasePerLevel;
    return int(random(avgSpawnTime - spawnTimeRandomWindowSize/2, avgSpawnTime + spawnTimeRandomWindowSize/2));
  }
}

public class ScoreTrackerComponent extends Component
{
  private String scoreValueParameterName;
  private String scoreTextPrefix;
  private int totalScore;
  
  public ScoreTrackerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    totalScore = 0;
  }
  
  @Override public void destroy()
  {
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
  
  @Override public void update(int deltaTime)
  {
    handleEvents();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.UPDATE_SCORE))
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
}

public class CalibrateWizardComponent extends Component
{
  ArrayList<String> actionsToRegister;
  String currentAction;
  
  public CalibrateWizardComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    actionsToRegister = new ArrayList<String>();
    actionsToRegister.add(LEFT_DIRECTION_LABEL);
    actionsToRegister.add(RIGHT_DIRECTION_LABEL);

    currentAction = actionsToRegister.remove(0);
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    // can I read in actionsToRegister from XML?
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.CALIBRATE_WIZARD;
  }
  
  @Override public void update(int deltaTime)
  {
    handleEvents();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.SPACEBAR_PRESSED))
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

      updateRenderComponent();
    }
  }

  private void updateRenderComponent()
  {
    IComponent component = gameObject.getComponent(ComponentType.RENDER);
    if (component != null)
    {
      RenderComponent renderComponent = (RenderComponent)component;
      RenderComponent.Text text = renderComponent.getTexts().get(0);
      RenderComponent.Text handtext = renderComponent.getTexts().get(1);
      RenderComponent.OffsetPImage img1 = renderComponent.getImages().get(0);
      RenderComponent.OffsetPImage img2 = renderComponent.getImages().get(1);
      if (text != null)
      {
        text.string = currentAction;
        if(currentAction.equals("RIGHT")){
            handtext.string = "Signal Right";
            img1.pimage = loadImage("images/myo_gesture_icons/wave-right.png");
            img2.pimage = loadImage("images/myo_gesture_icons/LHwave-right.png");
        }
      }
    }
  }
}


public class CountdownComponent extends Component 
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

public class ButtonComponent extends Component
{
  private int buttonHeight;
  private int buttonWidth;
  
  private boolean mouseOver;
  
  private SoundFile buttonClickedSound;
  private float amplitude;

  public ButtonComponent(GameObject _gameObject)
  {
    super(_gameObject);

    buttonHeight = 0;
    buttonWidth = 0;
    
    mouseOver = false;
  }

  @Override public void destroy()
  {
  }

  @Override public void fromXML(XML xmlComponent)
  {
    // Multiply the height and width by the scale values to make the button that size
    buttonHeight = xmlComponent.getInt("height") * (int)gameObject.getScale().y;
    buttonWidth = xmlComponent.getInt("width") * (int)gameObject.getScale().x;
    buttonClickedSound = new SoundFile(mainObject, xmlComponent.getString("buttonClickedSound"));
    buttonClickedSound.rate(xmlComponent.getFloat("rate"));
    try { buttonClickedSound.pan(xmlComponent.getFloat("pan")); } catch (UnsupportedOperationException e) {}
    amplitude = xmlComponent.getFloat("amp");
    buttonClickedSound.add(xmlComponent.getFloat("add"));
  }

  @Override public ComponentType getComponentType()
  {
    return ComponentType.BUTTON;
  }

  @Override public void update(int deltaTime)
  {
    float widthScale = (width / 500.0f);
    float heightScale = (height / 500.0f);
    
    float xButton = gameObject.getTranslation().x * widthScale;
    float yButton = gameObject.getTranslation().y * heightScale;
    
    float actualButtonWidth = buttonWidth * widthScale;
    float actualButtonHeight = buttonHeight * heightScale;
    
    if (xButton - 0.5 * actualButtonWidth <= mouseX && xButton + 0.5 * actualButtonWidth >= mouseX && yButton - 0.5 * actualButtonHeight <= mouseY && yButton + 0.5 * actualButtonHeight >= mouseY)
    {
      mouseOver = true;
      mouseHand = true;
    }
    else
    {
      mouseOver = false;
    }
    
    for (IEvent event : eventManager.getEvents(EventType.MOUSE_CLICKED))
    {
      if (mouseOver)
      {
        Event buttonEvent = new Event(EventType.BUTTON_CLICKED);
        buttonEvent.addStringParameter("tag",gameObject.getTag());
        eventManager.queueEvent(buttonEvent);
        buttonClickedSound.amp(amplitude * options.getIOOptions().getSoundEffectsVolume());
        buttonClickedSound.play();
      }
    }
  }
}

public class SliderComponent extends Component
{
  private int sliderHeight;
  private int sliderWidth;
  private boolean mouseOver;
  private boolean active;

  public SliderComponent(GameObject _gameObject)
  {
    super(_gameObject);

    sliderHeight = 0;
    sliderWidth = 0;
    mouseOver = false;
    active = false;
  }

  @Override public void destroy()
  {
  }

  @Override public void fromXML(XML xmlComponent)
  {
    // Multiply the height and width by the scale values to make the button that size
    sliderHeight = xmlComponent.getInt("height") * (int)gameObject.getScale().y;
    sliderWidth = xmlComponent.getInt("width") * (int)gameObject.getScale().x;

    // Adjust ticks on slider
    RenderComponent renderComponent = (RenderComponent) gameObject.getComponent(ComponentType.RENDER);
    renderComponent.getShapes().get(0).translation.x = -(sliderWidth * 0.5);
    renderComponent.getShapes().get(2).translation.x = sliderWidth * 0.5;

    float distBetweenTicks = sliderWidth / 5.0;
    for(int j = 1, i = 3; i < 7; i++, j++)
    {
      renderComponent.getShapes().get(i).translation.x = -(sliderWidth * 0.5) + distBetweenTicks * j;
    }
  }

  @Override public ComponentType getComponentType()
  {
    return ComponentType.SLIDER;
  }

  @Override public void update(int deltaTime)
  {
    float widthScale = (width / 500.0f);
    float heightScale = (height / 500.0f);
    
    PVector screenTranslation = new PVector(gameObject.getTranslation().x * widthScale, gameObject.getTranslation().y * heightScale);
    
    int actualSliderWidth = (int)(sliderWidth * widthScale);
    int actualSliderHeight = (int)(sliderHeight * heightScale);
    
    // Slider rect boundaries
    int xLeft = (int)(screenTranslation.x - (actualSliderWidth * 0.5));
    int xRight = (int)(screenTranslation.x + (actualSliderWidth * 0.5));
    int yTop = (int)(screenTranslation.y - (actualSliderHeight * 0.5));
    int yBottom = (int)(screenTranslation.y + (actualSliderHeight * 0.5));
    
    if (active || (xLeft <= mouseX && xRight >= mouseX && yTop <= mouseY && yBottom >= mouseY))
    {
      mouseOver = true;
      mouseHand = true;
    }
    else
    {
      mouseOver = false;
    }
    
    for (IEvent event : eventManager.getEvents(EventType.MOUSE_PRESSED))
    {
      if (mouseOver)
      {
        active = true;
      }
    }

    if (active)
    {
      for (IEvent event : eventManager.getEvents(EventType.MOUSE_DRAGGED))
      {
        float xMouse = (float)event.getRequiredIntParameter("mouseX");
        
        if (xMouse < xLeft)
        {
          xMouse = xLeft;
        }
        else if (xMouse > xRight)
        {
          xMouse = xRight;
        }
        
        RenderComponent renderComponent = (RenderComponent) gameObject.getComponent(ComponentType.RENDER);
        renderComponent.getImages().get(0).translation.x = (xMouse - (gameObject.getTranslation().x * widthScale)) / widthScale;
        float sliderPixelVal = xMouse - (xLeft);
        float sliderValue = sliderPixelVal/actualSliderWidth * 100;
        
        IEvent sliderDraggedEvent = new Event(EventType.SLIDER_DRAGGED);
        sliderDraggedEvent.addStringParameter("tag", gameObject.getTag());
        sliderDraggedEvent.addFloatParameter("sliderValue", sliderValue);
        eventManager.queueEvent(sliderDraggedEvent);
      }
      
      for (IEvent event : eventManager.getEvents(EventType.MOUSE_RELEASED))
      {
        float xMouse = (float)event.getRequiredIntParameter("mouseX");
        
        if (xMouse < xLeft)
        {
          xMouse = xLeft;
        }
        else if (xMouse > xRight)
        {
          xMouse = xRight;
        }
        
        RenderComponent renderComponent = (RenderComponent) gameObject.getComponent(ComponentType.RENDER);
        renderComponent.getImages().get(0).translation.x = (xMouse - (gameObject.getTranslation().x * widthScale)) / widthScale;
        float sliderPixelVal = xMouse - (xLeft);
        float sliderValue = sliderPixelVal/actualSliderWidth * 100;
        
        IEvent sliderReleasedEvent = new Event(EventType.SLIDER_RELEASED);
        sliderReleasedEvent.addStringParameter("tag", gameObject.getTag());
        sliderReleasedEvent.addFloatParameter("sliderValue", sliderValue);
        eventManager.queueEvent(sliderReleasedEvent);
        
        active = false;
      }
    }
  }
  
  public void setTabPosition(float x)
  {
    float widthScale = width / 500.0f;
    RenderComponent renderComponent = (RenderComponent) gameObject.getComponent(ComponentType.RENDER);
    renderComponent.getImages().get(0).translation.x = (x - (gameObject.getTranslation().x * widthScale)) / widthScale;
  }
}

public class LevelDisplayComponent extends Component
{
  private String currentLevelParameterName;
  private String levelTextPrefix;
  private String platformLevelPrefix;
  
  public LevelDisplayComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    currentLevelParameterName = xmlComponent.getString("currentLevelParameterName");
    levelTextPrefix = xmlComponent.getString("levelTextPrefix");
    platformLevelPrefix = xmlComponent.getString("platformLevelPrefix");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.LEVEL_DISPLAY;
  }
  
  @Override public void update(int deltaTime)
  {
    handleEvents();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.LEVEL_UP))
    {
      IComponent component = gameObject.getComponent(ComponentType.RENDER);
      if (component != null)  
      {
         RenderComponent renderComponent = (RenderComponent)component;
         RenderComponent.Text text = renderComponent.getTexts().get(0);
         if (text != null)
         { 
           if(!inputPlatformGaps)
           {
             text.string = levelTextPrefix + Integer.toString(event.getRequiredIntParameter(currentLevelParameterName));
           }
         }
      }
    }
    
    for (IEvent event : eventManager.getEvents(EventType.PLAYER_BREAK_PLATFORM_FALL))
    {
      IComponent component = gameObject.getComponent(ComponentType.RENDER);
      if (component != null)  
      {
         RenderComponent renderComponent = (RenderComponent)component;
         RenderComponent.Text text = renderComponent.getTexts().get(0);
         if (text != null)
         { 
           if(inputPlatformGaps)
           {
             text.string = platformLevelPrefix + Integer.toString(event.getRequiredIntParameter("platformLevel"));
           }
         }
      }
    }
  }
}

public class CounterIDComponent extends Component
{
  private String countUp;
  private String countDown;
  private int count;
  private ArrayList<Integer> idCounts;
  public CounterIDComponent(GameObject _gameObject)
  {
    super(_gameObject);
    idCounts = new ArrayList<Integer>();
    count = 0;
  }

  @Override public void destroy()
  {
  }

  @Override public void fromXML(XML xmlComponent)
  {
    countUp = xmlComponent.getString("countup");
    countDown = xmlComponent.getString("countdown");
    idCounts.add(0);
    idCounts.add(0);
    idCounts.add(0);
  }

  @Override public ComponentType getComponentType()
  {
    return ComponentType.ID_COUNTER;
  }

  @Override public void update(int deltaTime)
  {
    handleEvents();
  }
  
  private void handleEvents()
  {
     
      for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
      {
        String tag = event.getRequiredStringParameter("tag");
        int index = 0;
           
        if(tag.contains(countUp)){
          index = Integer.parseInt(tag.substring(tag.length()-1));
          incrementCounter(index-1,1);
        }
        else if(tag.contains(countDown)){
          index = Integer.parseInt(tag.substring(tag.length()-1));
          incrementCounter(index-1,-1);
        }
      }
  }
  
  private void incrementCounter(int index,int counter){
      IComponent component = gameObject.getComponent(ComponentType.RENDER);
      count = idCounts.get(index) + counter;
      if(count > 9)
        count = 0;
      if(count<0)
        count = 9;
        idCounts.set(index, count);
      
      if (component != null)
      {
        RenderComponent renderComponent = (RenderComponent)component;
        ArrayList<RenderComponent.Text> texts = renderComponent.getTexts();
          if (texts.size() > 0)
          {
             texts.get(index).string = Integer.toString(count);
          }
      }
  }
  
  public String getUserIDNumber(){
    String iD = idCounts.get(0).toString() +idCounts.get(1).toString() +idCounts.get(2).toString();
    return iD;
  }
}


public class LevelParametersComponent extends Component
{
  private int currentLevel;
  private int maxLevel;
  private float levelOneRiseSpeed;
  private float riseSpeedChangePerLevel;
  private float currentRiseSpeed;
  private boolean levelUpAtLeastOnce;
  private int levelUpTime;
  private int timePassed;
  private int bonusScorePerLevel;
  private int timePerBonusScore;
  private String scoreValueParameterName;
  private int bonusTimePassed;
  private String currentLevelParameterName;
  private String currentRiseSpeedParameterName;
  private SoundFile levelUpSound;
  private float amplitude;
  
  public LevelParametersComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    currentLevel = options.getGameOptions().getStartingLevel() - 1;
    maxLevel = xmlComponent.getInt("maxLevel");
    levelOneRiseSpeed = xmlComponent.getFloat("levelOneRiseSpeed");
    riseSpeedChangePerLevel = xmlComponent.getFloat("riseSpeedChangePerLevel");
    currentRiseSpeed = levelOneRiseSpeed + (riseSpeedChangePerLevel * (currentLevel - 1));
    levelUpAtLeastOnce = false;
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
    amplitude = xmlComponent.getFloat("amp");
    levelUpSound.add(xmlComponent.getFloat("add"));
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.LEVEL_PARAMETERS;
  }
  
  @Override public void update(int deltaTime)
  {
    if ((options.getGameOptions().getLevelUpOverTime() || !levelUpAtLeastOnce))
    {
      timePassed += deltaTime;
    
      if (timePassed > levelUpTime)
      {
        if (currentLevel < maxLevel)
        {
          levelUp();
          levelUpAtLeastOnce = true;
        }
        timePassed = 0;
      }
    }
    
    bonusTimePassed += deltaTime;
    if(!inputPlatformGaps)
    {
      if (bonusTimePassed > timePerBonusScore)
      {
        Event updateScoreEvent = new Event(EventType.UPDATE_SCORE);
        updateScoreEvent.addIntParameter(scoreValueParameterName, bonusScorePerLevel * currentLevel);
        eventManager.queueEvent(updateScoreEvent);
        bonusTimePassed = 0;
      }
    }
  }
  
  private void levelUp()
  {
    ++currentLevel;
    currentRiseSpeed += riseSpeedChangePerLevel;
    
    levelUpSound.amp(amplitude * options.getIOOptions().getSoundEffectsVolume());
    levelUpSound.play();
    
    Event levelUpEvent = new Event(EventType.LEVEL_UP);
    levelUpEvent.addIntParameter(currentLevelParameterName, currentLevel);
    levelUpEvent.addFloatParameter(currentRiseSpeedParameterName, currentRiseSpeed);
    eventManager.queueEvent(levelUpEvent);
    if(inputPlatformGaps)
    {
      Event updatePlatformLevelEvent = new Event(EventType.PLAYER_BREAK_PLATFORM_FALL);
      updatePlatformLevelEvent.addIntParameter("platformLevel", 1);
      eventManager.queueEvent(updatePlatformLevelEvent); 
    }
  }
}

public class MusicPlayerComponent extends Component
{
  SoundFile music;
  float amplitude;
  
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
    amplitude = xmlComponent.getFloat("amp");
    music.amp(amplitude * options.getIOOptions().getMusicVolume());
    music.add(xmlComponent.getFloat("add"));
    music.loop();
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.MUSIC_PLAYER;
  }
  
  @Override public void update(int deltaTime)
  {
    setMusicVolume(options.getIOOptions().getMusicVolume());
  }
  
  public void setMusicVolume(float volume)
  {
    music.amp(amplitude * volume);
  }
}

public class StatsCollectorComponent extends Component
{
  private String currentLevelParameterName;
  private String scoreValueParameterName;
  private String currentSpeedParameterName;
  
  private int levelAchieved;
  private int scoreAchieved;
  private int timePlayed;
  private float speedInstances;
  private float averageSpeed;
  private int coinsCollected;
  
  public StatsCollectorComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    levelAchieved = 0;
    scoreAchieved = 0;
    timePlayed = 0;
    speedInstances = 0.0f;
    averageSpeed = 0.0f;
    coinsCollected = 0;
  }
  
  @Override public void destroy()
  {
    IStats stats = options.getStats();
    ICustomizeOptions custom = options.getCustomizeOptions();
    
    IGameRecord record = stats.createGameRecord();
    record.setLevelAchieved(levelAchieved); 
    record.setScoreAchieved(scoreAchieved);
    record.setTimePlayed(timePlayed);
    record.setAverageSpeed(averageSpeed);
    record.setCoinsCollected(coinsCollected);
    custom.setCoinsCollected(coinsCollected);
    record.setDate(new Date().getTime());
    record.setIsFittsLawMode(fittsLaw);
    
    stats.addGameRecord(record);
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    currentLevelParameterName = xmlComponent.getString("currentLevelParameterName");
    scoreValueParameterName = xmlComponent.getString("scoreValueParameterName");
    currentSpeedParameterName = xmlComponent.getString("currentSpeedParameterName");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.STATS_COLLECTOR;
  }
  
  @Override public void update(int deltaTime)
  {
    handleEvents();
    timePlayed += deltaTime;
  }
  
  private void handleEvents()
  {
    if(fittsLaw)
    {
      for (IEvent event : eventManager.getEvents(EventType.PLAYER_BREAK_PLATFORM_FALL))
      {
        levelAchieved = event.getRequiredIntParameter("platformLevel");
      }
    }
    else
    {
      for (IEvent event : eventManager.getEvents(EventType.LEVEL_UP))
      {
        levelAchieved = event.getRequiredIntParameter(currentLevelParameterName);
      }
    }
    
    for (IEvent event : eventManager.getEvents(EventType.UPDATE_SCORE))
    {
      scoreAchieved += event.getRequiredIntParameter(scoreValueParameterName);
    }
    
    for (IEvent event : eventManager.getEvents(EventType.PLAYER_CURRENT_SPEED))
    {
      float currentSpeed = event.getRequiredFloatParameter(currentSpeedParameterName);
      speedInstances += 1.0f;
      averageSpeed = (((speedInstances - 1.0f) * averageSpeed) + currentSpeed) / speedInstances;
    }
    
    for (IEvent event : eventManager.getEvents(EventType.COIN_COLLECTED))
    {
      coinsCollected++;
    }
  }
}

public class PostGameControllerComponent extends Component
{
  private IGameRecord lastGameRecord;
  private boolean textIsSet;
  
  public PostGameControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    ArrayList<IGameRecord> records = options.getStats().getGameRecords();
    lastGameRecord = records.get(records.size() - 1);
    textIsSet = false;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.POST_GAME_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    if (!textIsSet)
    {
      IComponent component = gameObject.getComponent(ComponentType.RENDER);
      if (component != null)
      {
        RenderComponent renderComponent = (RenderComponent)component;
        ArrayList<RenderComponent.Text> textElements = renderComponent.getTexts();
        textElements.get(0).string = Integer.toString(lastGameRecord.getLevelAchieved());
        textElements.get(1).string = Integer.toString(lastGameRecord.getScoreAchieved());
        textElements.get(2).string = Integer.toString((int)(lastGameRecord.getAverageSpeed()));
        textElements.get(3).string = Integer.toString(lastGameRecord.getCoinsCollected());
        int milliseconds = lastGameRecord.getTimePlayed();                                                                     
        int seconds = (milliseconds/1000) % 60;                                                                            
        int minutes = milliseconds/60000;  
        textElements.get(4).string = String.format("%3d:%02d", minutes, seconds); 
      }
      
      textIsSet = true;
    }
  }
}

public class GameOptionsControllerComponent extends Component
{
  private String sliderTag;
  private float sliderLeftBoundary;
  private float sliderRightBoundary;
  private float yPosition;
  
  private String increaseDifficultyOverTimeTag;
  private String defaultTag;
  private String autoDirectTag;
  private String leftTag;
  private String rightTag;
  private String bothTag;
  private String singleMuscleTag;
  private String autoLeftTag;
  private String autoRightTag;
  private String obstaclesTag;
  private String terrainModsTag;
  private String logRawDataTag;
  private String fittsLawTag;
  private String inputPlatformTag;
  private String logFittsTag;
  private String constraintsFittsTag;
  private String jump3timestag;
  private String wait2secstag;
  private float checkBoxXPosition;
  private float radioButtonXposition;
  private float falseDisplacement;
  
  
  public GameOptionsControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    sliderTag = xmlComponent.getString("sliderTag");
    sliderLeftBoundary = xmlComponent.getFloat("sliderLeftBoundary");
    sliderRightBoundary = xmlComponent.getFloat("sliderRightBoundary");
    yPosition = xmlComponent.getFloat("yPosition");
    
    increaseDifficultyOverTimeTag = xmlComponent.getString("increaseDifficultyOverTimeTag");
    defaultTag = xmlComponent.getString("defaultTag");
    autoDirectTag = xmlComponent.getString("autoDirectTag");
    leftTag = xmlComponent.getString("left");
    rightTag = xmlComponent.getString("right");
    bothTag = xmlComponent.getString("both");
    singleMuscleTag = xmlComponent.getString("singleMuscleTag");
    autoLeftTag = xmlComponent.getString("autoLeftTag");
    autoRightTag = xmlComponent.getString("autoRightTag");
    obstaclesTag = xmlComponent.getString("obstaclesTag");
    terrainModsTag = xmlComponent.getString("terrainModsTag");
    logRawDataTag = xmlComponent.getString("logRawDataTag");
    fittsLawTag = xmlComponent.getString("fittsLawTag");
    inputPlatformTag = xmlComponent.getString("inputPlatformTag");
    logFittsTag = xmlComponent.getString("logFittsTag");
    constraintsFittsTag = xmlComponent.getString("constraintsFittsTag");
    wait2secstag = xmlComponent.getString("wait2secstag");
    jump3timestag = xmlComponent.getString("jump3timestag");
    checkBoxXPosition = xmlComponent.getFloat("checkBoxXPosition");
    radioButtonXposition = xmlComponent.getFloat("radioButtonXposition");
    falseDisplacement = xmlComponent.getFloat("falseDisplacement");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.GAME_OPTIONS_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    IGameOptions gameOptions = options.getGameOptions();
    
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      
      if (tag.equals(increaseDifficultyOverTimeTag))
      {
        gameOptions.setLevelUpOverTime(!gameOptions.getLevelUpOverTime());
      }
      else if(tag.equals(defaultTag))
      {
        gameOptions.setControlPolicy(ControlPolicy.NORMAL);
      }
      else if (tag.equals(autoDirectTag))
      {
        if (gameOptions.getControlPolicy() == ControlPolicy.DIRECTION_ASSIST)
        {
          gameOptions.setControlPolicy(ControlPolicy.NORMAL);
        }
        else
        {
          gameOptions.setControlPolicy(ControlPolicy.DIRECTION_ASSIST);
          gameOptions.setDirectionAssistMode(DirectionAssistMode.LEFT_ONLY);
          gameOptions.setObstacles(false);
          if(gameOptions.getFittsLaw())
          {
            gameOptions.setBreakthroughMode(BreakthroughMode.WAIT_2SEC);
          }
        }
      }
      else if (tag.equals(singleMuscleTag))
      {
        if (gameOptions.getControlPolicy() == ControlPolicy.SINGLE_MUSCLE) {
          gameOptions.setControlPolicy(ControlPolicy.NORMAL);
        }
        else
        {
          gameOptions.setControlPolicy(ControlPolicy.SINGLE_MUSCLE);
          gameOptions.setSingleMuscleMode(SingleMuscleMode.AUTO_LEFT);
          gameOptions.setObstacles(false);
          if(gameOptions.getFittsLaw())
          {
            gameOptions.setBreakthroughMode(BreakthroughMode.WAIT_2SEC);
          }
        }
      }
      else if (tag.equals(obstaclesTag))
      {
        gameOptions.setObstacles(!gameOptions.getObstacles());
        if (gameOptions.getObstacles())
        {
          gameOptions.setControlPolicy(ControlPolicy.NORMAL);
        }
      }
      else if (tag.equals(terrainModsTag))
      {
        gameOptions.setPlatformMods(!gameOptions.getPlatformMods());
      }
      else if(tag.equals(logRawDataTag))
      {
        gameOptions.setLogRawData(!gameOptions.getLogRawData());
      }
      else if (tag.equals(fittsLawTag))
      {
        gameOptions.setFittsLaw(!gameOptions.getFittsLaw());
        if(gameOptions.getFittsLaw())
        {
          gameOptions.setInputPlatforms(true);
          gameOptions.setLogFitts(true);
          gameOptions.setStillPlatforms(true);
          gameOptions.setLevelUpOverTime(false);
          gameOptions.setObstacles(false);
          gameOptions.setPlatformMods(false);
        }
        else
        {
          gameOptions.setInputPlatforms(false);
          gameOptions.setLogFitts(false);
          gameOptions.setStillPlatforms(false);
        }
      }
      else if (tag.equals(inputPlatformTag))
      {
        gameOptions.setInputPlatforms(!gameOptions.getInputPlatforms());
      }
      else if (tag.equals(logFittsTag))
      {
        gameOptions.setLogFitts(!gameOptions.getLogFitts());
      }
      else if (tag.equals(constraintsFittsTag))
      {
        gameOptions.setStillPlatforms(!gameOptions.getStillPlatforms());
      }
      
      if(gameOptions.getFittsLaw())
      {
        if(tag.equals(wait2secstag))
        {
          gameOptions.setBreakthroughMode(BreakthroughMode.WAIT_2SEC);
        }
        else if(tag.equals(jump3timestag))
        {
          gameOptions.setBreakthroughMode(BreakthroughMode.JUMP_3TIMES);
          if(!(gameOptions.getControlPolicy() == ControlPolicy.NORMAL))
          {
            gameOptions.setControlPolicy(ControlPolicy.NORMAL);
          }
        }
        
      }
      
       
      if(gameOptions.getControlPolicy() == ControlPolicy.DIRECTION_ASSIST)
      {
        if (tag.equals(leftTag))
        {
          gameOptions.setDirectionAssistMode(DirectionAssistMode.LEFT_ONLY);
        }
        else if (tag.equals(rightTag))
        {
          gameOptions.setDirectionAssistMode(DirectionAssistMode.RIGHT_ONLY);
        }
          else if (tag.equals(bothTag))
        {
          gameOptions.setDirectionAssistMode(DirectionAssistMode.BOTH);
        } 
      }

      if(gameOptions.getControlPolicy() == ControlPolicy.SINGLE_MUSCLE)
      {
        if (tag.equals(autoLeftTag))
          gameOptions.setSingleMuscleMode(SingleMuscleMode.AUTO_LEFT);
        else if (tag.equals(autoRightTag))
          gameOptions.setSingleMuscleMode(SingleMuscleMode.AUTO_RIGHT);
      }
    }
    
    IComponent component = gameObject.getComponent(ComponentType.RENDER);
    if (component != null)
    {
      RenderComponent renderComponent = (RenderComponent)component;
      
      ArrayList<RenderComponent.Text> texts = renderComponent.getTexts();
      if (texts.size() > 0)
      {
        RenderComponent.Text sliderText = texts.get(0);
        
        int startingLevel = options.getGameOptions().getStartingLevel();
        sliderText.string = Integer.toString(startingLevel);
        sliderText.translation.x = ((startingLevel / 100.0f) * (sliderRightBoundary - sliderLeftBoundary)) + sliderLeftBoundary;
        sliderText.translation.y = yPosition;
        
        ArrayList<IGameObject> sliderList = gameStateController.getGameObjectManager().getGameObjectsByTag(sliderTag);
        if (sliderList.size() > 0)
        {
          IGameObject slider = sliderList.get(0);
          component = slider.getComponent(ComponentType.SLIDER);
          if (component != null)
          {
            SliderComponent sliderComponent = (SliderComponent)component;
            sliderComponent.setTabPosition((width / 500.0) * sliderText.translation.x);
          }
        }
      }
      
      ArrayList<RenderComponent.OffsetPShape> shapes = renderComponent.getShapes();
      ArrayList<RenderComponent.OffsetPImage> images = renderComponent.getImages();
      if (shapes.size() > 3)
      {
        RenderComponent.OffsetPImage levelUpOverTimeCheckBox = images.get(0);
        RenderComponent.OffsetPImage obstaclesCheckBox = images.get(1);
        RenderComponent.OffsetPImage terrainModsCheckBox = images.get(2);
         RenderComponent.OffsetPImage logRawDataCheckBox = images.get(3);
        RenderComponent.OffsetPImage fittsLawCheckBox = images.get(4);
       
        
        RenderComponent.OffsetPImage inputPlatformsCheckBox = images.get(5);
        RenderComponent.OffsetPImage logFittsCheckBox = images.get(6);
        RenderComponent.OffsetPImage contraintsFittsCheckBox = images.get(7);

        
        //Ellipses for Auto-DirectMode
        RenderComponent.OffsetPShape deafultControlCheckBox = shapes.get(0);
        RenderComponent.OffsetPShape autoDirectCheckBox = shapes.get(1);
        RenderComponent.OffsetPShape leftCheckbox = shapes.get(2);
        RenderComponent.OffsetPShape rightCheckbox = shapes.get(3);
        RenderComponent.OffsetPShape bothCheckbox = shapes.get(4);

        RenderComponent.OffsetPShape singleMuscleCheckBox = shapes.get(5);
        RenderComponent.OffsetPShape autoLeftCheckBox = shapes.get(6);
        RenderComponent.OffsetPShape autoRightCheckBox = shapes.get(7);
        
        RenderComponent.OffsetPShape wait2secCheckbox = shapes.get(8);
        RenderComponent.OffsetPShape jump3timeCheckbox = shapes.get(9);
        
        levelUpOverTimeCheckBox.translation.x = checkBoxXPosition + (gameOptions.getLevelUpOverTime() ? 0.0f : falseDisplacement);
        
        deafultControlCheckBox.translation.x = radioButtonXposition + (gameOptions.getControlPolicy() == ControlPolicy.NORMAL ? 0.0f : falseDisplacement);
        
        autoDirectCheckBox.translation.x = radioButtonXposition + (gameOptions.getControlPolicy() == ControlPolicy.DIRECTION_ASSIST ? 0.0f : falseDisplacement);
        leftCheckbox.translation.x = 75 + ((gameOptions.getDirectionAssistMode() == DirectionAssistMode.LEFT_ONLY && gameOptions.getControlPolicy() == ControlPolicy.DIRECTION_ASSIST) ? 0.0f : falseDisplacement);
        rightCheckbox.translation.x = 150 + ((gameOptions.getDirectionAssistMode() == DirectionAssistMode.RIGHT_ONLY && gameOptions.getControlPolicy() == ControlPolicy.DIRECTION_ASSIST) ? 0.0f : falseDisplacement);
        bothCheckbox.translation.x = 230 + ((gameOptions.getDirectionAssistMode() == DirectionAssistMode.BOTH && gameOptions.getControlPolicy() == ControlPolicy.DIRECTION_ASSIST) ? 0.0f : falseDisplacement);
        
        singleMuscleCheckBox.translation.x = radioButtonXposition + (gameOptions.getControlPolicy() == ControlPolicy.SINGLE_MUSCLE ? 0.0f : falseDisplacement);
        autoLeftCheckBox.translation.x = 75 + ((gameOptions.getSingleMuscleMode() == SingleMuscleMode.AUTO_LEFT && gameOptions.getControlPolicy() == ControlPolicy.SINGLE_MUSCLE) ? 0.0f : falseDisplacement);
        autoRightCheckBox.translation.x = 200 + ((gameOptions.getSingleMuscleMode() == SingleMuscleMode.AUTO_RIGHT && gameOptions.getControlPolicy() == ControlPolicy.SINGLE_MUSCLE) ? 0.0f : falseDisplacement);
        
        obstaclesCheckBox.translation.x = checkBoxXPosition + (gameOptions.getObstacles() ? 0.0f : falseDisplacement);
        terrainModsCheckBox.translation.x = checkBoxXPosition + (gameOptions.getPlatformMods() ? 0.0f : falseDisplacement);
        logRawDataCheckBox.translation.x = checkBoxXPosition + (gameOptions.getLogRawData() ? 0.0f : falseDisplacement);
        
        fittsLawCheckBox.translation.x = checkBoxXPosition + (gameOptions.getFittsLaw() ? 0.0f : falseDisplacement);
        inputPlatformsCheckBox.translation.x = 60 + (gameOptions.getInputPlatforms() ? 0.0f : falseDisplacement);
        logFittsCheckBox.translation.x = 60 + (gameOptions.getLogFitts() ? 0.0f : falseDisplacement);
        contraintsFittsCheckBox.translation.x = 60 + (gameOptions.getStillPlatforms() ? 0.0f : falseDisplacement);
        
        wait2secCheckbox.translation.x = 315 + ((gameOptions.getBreakthroughMode() == BreakthroughMode.WAIT_2SEC && gameOptions.getFittsLaw()) ? 0.0f : falseDisplacement);
        jump3timeCheckbox.translation.x = 315 + ((gameOptions.getBreakthroughMode() == BreakthroughMode.JUMP_3TIMES && gameOptions.getFittsLaw()) ? 0.0f : falseDisplacement);
      }
    }
  }
}

public class IOOptionsControllerComponent extends Component
{
  private String musicSliderTag;
  private float musicSliderLeftBoundary;
  private float musicSliderRightBoundary;
  private float musicSliderYPosition;
  
  private String soundEffectsSliderTag;
  private float soundEffectsSliderLeftBoundary;
  private float soundEffectsSliderRightBoundary;
  private float soundEffectsSliderYPosition;
  
  private String leftSensitivitySliderTag;
  private float leftSensitivitySliderLeftBoundary;
  private float leftSensitivitySliderRightBoundary;
  
  private String rightSensitivitySliderTag;
  private float rightSensitivitySliderLeftBoundary;
  private float rightSensitivitySliderRightBoundary;
  
  public IOOptionsControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    musicSliderTag = xmlComponent.getString("musicSliderTag");
    musicSliderLeftBoundary = xmlComponent.getFloat("musicSliderLeftBoundary");
    musicSliderRightBoundary = xmlComponent.getFloat("musicSliderRightBoundary");
    musicSliderYPosition = xmlComponent.getFloat("musicSliderYPosition");
    
    soundEffectsSliderTag = xmlComponent.getString("soundEffectsSliderTag");
    soundEffectsSliderLeftBoundary = xmlComponent.getFloat("soundEffectsSliderLeftBoundary");
    soundEffectsSliderRightBoundary = xmlComponent.getFloat("soundEffectsSliderRightBoundary");
    soundEffectsSliderYPosition = xmlComponent.getFloat("soundEffectsSliderYPosition");
    
    leftSensitivitySliderTag = xmlComponent.getString("leftSensitivitySliderTag");
    leftSensitivitySliderLeftBoundary = xmlComponent.getFloat("leftSensitivitySliderLeftBoundary");
    leftSensitivitySliderRightBoundary = xmlComponent.getFloat("leftSensitivitySliderRightBoundary");
    
    rightSensitivitySliderTag = xmlComponent.getString("rightSensitivitySliderTag");
    rightSensitivitySliderLeftBoundary = xmlComponent.getFloat("rightSensitivitySliderLeftBoundary");
    rightSensitivitySliderRightBoundary = xmlComponent.getFloat("rightSensitivitySliderRightBoundary");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.IO_OPTIONS_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    IComponent component = gameObject.getComponent(ComponentType.RENDER);
    if (component != null)
    {
      RenderComponent renderComponent = (RenderComponent)component;
      ArrayList<RenderComponent.Text> texts = renderComponent.getTexts();
      if (texts.size() > 1)
      {
        RenderComponent.Text musicSliderText = texts.get(0);
        RenderComponent.Text soundEffectsSliderText = texts.get(1);
        
        float musicVolume = options.getIOOptions().getMusicVolume();
        float soundEffectsVolume = options.getIOOptions().getSoundEffectsVolume();
        float leftEMGSensitivity = options.getIOOptions().getLeftEMGSensitivity();
        float rightEMGSensitivity = options.getIOOptions().getRightEMGSensitivity();
        
        musicSliderText.string = Integer.toString((int)(musicVolume * 100.0f));
        musicSliderText.translation.x = (musicVolume * (musicSliderRightBoundary - musicSliderLeftBoundary)) + musicSliderLeftBoundary;
        musicSliderText.translation.y = musicSliderYPosition;
        
        soundEffectsSliderText.string = Integer.toString((int)(soundEffectsVolume * 100.0f));
        soundEffectsSliderText.translation.x = (soundEffectsVolume * (soundEffectsSliderRightBoundary - soundEffectsSliderLeftBoundary)) + soundEffectsSliderLeftBoundary;
        soundEffectsSliderText.translation.y = soundEffectsSliderYPosition;
        
        ArrayList<IGameObject> musicSliderList = gameStateController.getGameObjectManager().getGameObjectsByTag(musicSliderTag);
        if (musicSliderList.size() > 0)
        {
          IGameObject musicSlider = musicSliderList.get(0);
          component = musicSlider.getComponent(ComponentType.SLIDER);
          if (component != null)
          {
            SliderComponent sliderComponent = (SliderComponent)component;
            sliderComponent.setTabPosition((width / 500.0f) * musicSliderText.translation.x);
          }
        }
        
        ArrayList<IGameObject> soundEffectsSliderList = gameStateController.getGameObjectManager().getGameObjectsByTag(soundEffectsSliderTag);
        if (soundEffectsSliderList.size() > 0)
        {
          IGameObject soundEffectsSlider = soundEffectsSliderList.get(0);
          component = soundEffectsSlider.getComponent(ComponentType.SLIDER);
          if (component != null)
          {
            SliderComponent sliderComponent = (SliderComponent)component;
            sliderComponent.setTabPosition((width / 500.0f) * soundEffectsSliderText.translation.x);
          }
        }
        
        ArrayList<IGameObject> leftSensitivitySliderList = gameStateController.getGameObjectManager().getGameObjectsByTag(leftSensitivitySliderTag);
        if (leftSensitivitySliderList.size() > 0)
        {
          IGameObject leftSensitivitySlider = leftSensitivitySliderList.get(0);
          component = leftSensitivitySlider.getComponent(ComponentType.SLIDER);
          if (component != null)
          {
            SliderComponent sliderComponent = (SliderComponent)component;
            sliderComponent.setTabPosition((width / 500.0f) * ((((leftEMGSensitivity - 0.2f) / 4.8f) * (leftSensitivitySliderRightBoundary - leftSensitivitySliderLeftBoundary)) + leftSensitivitySliderLeftBoundary));
          }
        }
        
        ArrayList<IGameObject> rightSensitivitySliderList = gameStateController.getGameObjectManager().getGameObjectsByTag(rightSensitivitySliderTag);
        if (rightSensitivitySliderList.size() > 0)
        {
          IGameObject rightSensitivitySlider = rightSensitivitySliderList.get(0);
          component = rightSensitivitySlider.getComponent(ComponentType.SLIDER);
          if (component != null)
          {
            SliderComponent sliderComponent = (SliderComponent)component;
            sliderComponent.setTabPosition((width / 500.0f) * ((((rightEMGSensitivity - 0.2f) / 4.8f) * (rightSensitivitySliderRightBoundary - rightSensitivitySliderLeftBoundary)) + rightSensitivitySliderLeftBoundary));
          }
        }
      }
    }
  }
}

public class AnimationControllerComponent extends Component
{
 
  public float[] right;
  public float[] left;
  public float[] still = {0,0,0};
  public boolean isRight;
  
  public AnimationControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
     right = new float[3];
     left = new float[3];
     isRight = false;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
     right[0] = xmlComponent.getInt("rightStart");
     right[1] = xmlComponent.getInt("rightEnd");
     left[0] = xmlComponent.getInt("leftStart");
     left[1] = xmlComponent.getInt("leftEnd");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.ANIMATION_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {  
  }
  
  public float[] getDirection()
  {
    IComponent componentRigid = gameObject.getComponent(ComponentType.PLAYER_CONTROLLER);
    PlayerControllerComponent playComp = (PlayerControllerComponent)componentRigid;
    float vectorX = playComp.getLatestMoveVector().x;
    float magnitude = playComp.getLatestMoveVector().mag();
    //to normalize the frequency the max magnitude is 1.41212
    if(magnitude !=0)
    {
      magnitude = abs(1.5-magnitude);
    }
    
    if(vectorX > 0)
    {
      isRight = true;
      right[2] = magnitude;
      return right;
    }
    else if(vectorX < 0)
    {
     isRight = false;
     left[2]= magnitude;
     return left; 
    }
    else
    {
      if(isRight)
      {
        right[2] = (magnitude);
        return right;
      }
      else
      {
        left[2] = (magnitude);
        return left;
      } 
    }
  }
}

public class FittsStatsComponent extends Component
{ 
  private int levelCount;
  private float startTime;
  private float endTime;
  private int errors;
  private int undershoots;
  private int overshoots;
  private int directionChanges;
  private float totalTime;
  public FittsStatsComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    levelCount =0;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.FITTS_STATS;
  }
  
  @Override public void update(int deltaTime)
  {
    if(fittsLaw)
    {
      handleEvents();
      totalTime += deltaTime;
    }
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.PLAYER_PLATFORM_COLLISION))
    {
      IGameObject platform = event.getRequiredGameObjectParameter("platform");
      if(!platformLevels.isEmpty())
      {
        for(int i = 0; i<platformLevels.size(); i++)
        {
          if(platformLevels.get(i).contains(platform.getUID()))
          {
            for(int j=0; j<i +1; j++)
            {
              if(stillPlatforms && !fittsLaw)
              {
                pc.incrementPlatforms();
                pc.spawnPlatformLevelNoRiseSpeed();
              }
              levelCount++;
              platformLevels.remove(0); 
            }
          
            TableRow newRow = tableFittsStats.addRow(); 
            startLogLevel(newRow);
          }
        }
      }
    }
    
    for (IEvent event : eventManager.getEvents(EventType.PLAYER_BREAK_PLATFORM_COLLISION))
    {
      IGameObject platform = event.getRequiredGameObjectParameter("break_platform");
      if(!platformLevels.isEmpty())
      {
        for(int i = 0; i<platformLevels.size(); i++)
        {
          if(platformLevels.get(i).contains(platform.getUID()))
          {
            for(int j=0; j<i +1; j++)
            {
              if(stillPlatforms && !fittsLaw)
              {
                pc.incrementPlatforms();
                pc.spawnPlatformLevelNoRiseSpeed();
              }
              levelCount++;
              platformLevels.remove(0); 
            }
          
            TableRow newRow = tableFittsStats.addRow(); 
            startLogLevel(newRow);
          }
        }
      }
    }
  }
  
  private int getCurrentLevel()
  {
    return levelCount;
  }
  
  private void startLogLevel(TableRow newRow)
  {
    startTime = totalTime;
    if(logFittsLaw)
    {
      IComponent componentPlayerComp = gameObject.getComponent(ComponentType.PLAYER_CONTROLLER);
      PlayerControllerComponent playComp = (PlayerControllerComponent)componentPlayerComp;
      IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
      PVector pos = new PVector();
      if(component != null){
        RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
        pos = rigidBodyComponent.getPosition();
      }
      float gapPos = platformGapPosition.get(tableFittsStats.getRowCount()-1).x;
      float gapWidth = platformGapPosition.get(tableFittsStats.getRowCount()-1).y;
      playComp.setLoggingValuesZero(gapPos, gapWidth, pos.x);
      String iD = options.getUserInformation().getUserID();
      if(iD == null)
        iD ="-1";
      newRow.setString("id", iD);
      newRow.setInt("trial", tableFittsStats.getRowCount());
      newRow.setInt("level", levelCount);
      newRow.setString("condition", "Simple");
      newRow.setFloat("start point x", pos.x);
      newRow.setFloat("start time", startTime);
    }
  }
  
  private void endLogLevel()
  {
    if(inputPlatformGaps)
    {
      endTime = totalTime;
      Event updateScoreEvent = new Event(EventType.UPDATE_SCORE);
      int timeValue = (int)((10000-(endTime - startTime))*0.01);
      if(timeValue < 0)
        timeValue = 0;
      int scoreValue = (250 + timeValue);
      updateScoreEvent.addIntParameter("scoreValue", scoreValue);
      eventManager.queueEvent(updateScoreEvent);
    }
          
    if(logFittsLaw)
    {
      TableRow newRow = tableFittsStats.getRow(tableFittsStats.getRowCount() - 1);
      IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
      PVector pos = new PVector();
      if(component != null)
      {
        RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
        pos = rigidBodyComponent.getPosition();
      }
      IComponent componentRigid = gameObject.getComponent(ComponentType.PLAYER_CONTROLLER);
      PlayerControllerComponent playComp = (PlayerControllerComponent)componentRigid;
      directionChanges = playComp.getDirerctionChanges();
      overshoots =  playComp.getOverShoots();
      undershoots = playComp.getUnderShoots();
      errors = playComp.getErrors();
      newRow.setFloat("end point x", pos.x);
      newRow.setFloat("end time", endTime);
      newRow.setInt("errors", errors);
      newRow.setInt("undershoots", undershoots);
      newRow.setInt("overshoots", overshoots);
      newRow.setInt("direction changes", directionChanges);
      newRow.setFloat("total time",endTime - startTime);
    }
  }
}


public class LogRawDataComponent extends Component
{ 
  private String userID;
  private Date d;
  private int platLevel;
  private String playingWith;
  private String inputType;
  private String mode;
  private boolean movingLeft;
  private boolean movingRight;
  private boolean isJumping;
  
  private int totalTime;
  private int nextLogTime;
  private EmgSamplingPolicy sampPolicy;
  private ControlPolicy contPolicy;
  
  public LogRawDataComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    d = new Date();
    userID = options.getUserInformation().getUserID();
    if(userID == null)
      userID ="-1";  
    
    sampPolicy = options.getIOOptions().getEmgSamplingPolicy();
    if(sampPolicy == EmgSamplingPolicy.DIFFERENCE)
      inputType = "diff";
    else if(sampPolicy == EmgSamplingPolicy.MAX)
      inputType = "max";
    else
      inputType = "first-over";
      
    contPolicy = options.getGameOptions().getControlPolicy();
    if(ControlPolicy.SINGLE_MUSCLE == contPolicy)
    {
      mode = "Single Muscle - " + options.getGameOptions().getSingleMuscleMode();
    }
    else if(ControlPolicy.DIRECTION_ASSIST == contPolicy)
    {
      mode = "Direction Assist - " + options.getGameOptions().getDirectionAssistMode();
    }
    else
    {
      mode = "Normal"; 
    }
    
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.LOG_RAW_DATA;
  }
  
  @Override public void update(int deltaTime)
  {
    totalTime += deltaTime;
    if(options.getGameOptions().getLogRawData() && logRawData && (totalTime - nextLogTime) > 100)
    {
      nextLogTime = totalTime;
      TableRow newRow = tableRawData.addRow(); 
      logRawData(newRow);
    }
  }
  
  private void logRawData(TableRow newRow)
  {
    if(emgManager.isCalibrated())
      playingWith = "Myo Armband";
    else
      playingWith = "Keyboard";
    d = new Date();
    IComponent componentFittsStats = gameObject.getComponent(ComponentType.FITTS_STATS);
    FittsStatsComponent FittsStatComp = (FittsStatsComponent)componentFittsStats;
    platLevel = FittsStatComp.getCurrentLevel();
    IComponent componentPlayerComp = gameObject.getComponent(ComponentType.PLAYER_CONTROLLER);
    PlayerControllerComponent playComp = (PlayerControllerComponent)componentPlayerComp;
    HashMap<String, Float> input = playComp.getRawInput();
    IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
    RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
    PVector vel = rigidBodyComponent.getLinearVelocity();
    if(vel.x<0)
    {
      movingLeft = true;
      movingRight= false;
    }
    else if(vel.x>0)
    {
      movingLeft = false;
      movingRight= true;
    }
    else
    {
      movingLeft = false;
      movingRight= false;
    }
    
    if(vel.y<0)
    {
      isJumping = true;
    }
    else
    {
      isJumping = false;
    }
    
    newRow.setFloat("timestamp", totalTime);
    newRow.setString("userID", userID);
    newRow.setString("Playing With", playingWith);
    newRow.setInt("level", platLevel);
    newRow.setFloat("SensorLeft", input.get(LEFT_DIRECTION_LABEL));
    newRow.setFloat("SensorRight", input.get(RIGHT_DIRECTION_LABEL));
    newRow.setFloat("SensorJump", input.get(JUMP_DIRECTION_LABEL));
    newRow.setString("InputType", inputType);
    newRow.setString("Mode", mode);
    newRow.setString("MovingLeft", movingLeft ? "1" : "0");
    newRow.setString("MovingRight", movingRight ? "1" : "0");
    newRow.setInt("Jumping", isJumping ? 1 : 0);   
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
    pc = (PlatformManagerControllerComponent) component;
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
  else if (componentName.equals("Slider"))
  {
    component = new SliderComponent(gameObject);
  }
  else if (componentName.equals("StatsCollector"))
  {
    component = new StatsCollectorComponent(gameObject);
  }
  else if (componentName.equals("PostGameController"))
  {
    component = new PostGameControllerComponent(gameObject);
  }
  else if (componentName.equals("GameOptionsController"))
  {
    component = new GameOptionsControllerComponent(gameObject);
  }
  else if (componentName.equals("IOOptionsController"))
  {
    component = new IOOptionsControllerComponent(gameObject);
  }
  else if (componentName.equals("AnimationController"))
  {
    component = new AnimationControllerComponent(gameObject);
  }
  else if(componentName.equals("CounterID"))
  {
    component = new CounterIDComponent(gameObject);
  }
  else if(componentName.equals("FittsStatsComponent"))
  {
   component = new FittsStatsComponent(gameObject); 
  }
  else if(componentName.equals("LogRawDataComponent"))
  {
   component = new LogRawDataComponent(gameObject); 
  }
  
  if (component != null)
  {
    component.fromXML(xmlComponent);
  }
  
  return component;
}