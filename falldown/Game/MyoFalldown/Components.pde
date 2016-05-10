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
}

interface IComponent
{
  public void            destroy();
  public void            fromXML(XML xmlComponent);
  public ComponentType   getComponentType();
  public GameObject      getGameObject();
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
  protected GameObject gameObject;
  
  public Component(GameObject _gameObject)
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
  @Override final public GameObject getGameObject()
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
  private class OffsetPShape
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
  
  private class Text
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
  
  public RenderComponent(GameObject _gameObject)
  {
    super(_gameObject);
    
    offsetShapes = new ArrayList<OffsetPShape>();
    texts = new ArrayList<Text>();
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
    
    for (Text text : texts)
    { 
      textFont(text.font);
      textAlign(text.alignX, text.alignY);
      fill(text.fillColor);
      stroke(text.strokeColor);
      text(text.string, text.translation.x + gameObject.getTranslation().x, text.translation.y + gameObject.getTranslation().y);
    }
  }
}

class RigidBodyComponent extends Component implements ContactListener
{
  private Body body;
  
  public RigidBodyComponent(GameObject _gameObject)
  {
    super(_gameObject);
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
    
    for (XML xmlFixture : xmlComponent.getChildren())
    {
      if (xmlFixture.getName().equals("Fixture"))
      {
        FixtureDef fixtureDef = new FixtureDef();
        fixtureDef.density = xmlFixture.getFloat("density");
        fixtureDef.friction = xmlFixture.getFloat("friction");
        fixtureDef.restitution = xmlFixture.getFloat("restitution");
        fixtureDef.isSensor = xmlFixture.getString("isSensor").equals("true") ? true : false;
        
        for (XML xmlShape : xmlFixture.getChildren())
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
  
  public PVector getLinearVelocity()
  {
    return new PVector(metersToPixels(body.getLinearVelocity().x), metersToPixels(body.getLinearVelocity().y));
  }
  
  public void setLinearVelocity(PVector linearVelocity)
  {
    body.setLinearVelocity(new Vec2(pixelsToMeters(linearVelocity.x), pixelsToMeters(linearVelocity.y)));
  }
  
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
    return pixels / 10.0f;
  }
  
  private float metersToPixels(float meters)
  {
    return meters * 10.0f;
  }
  
  @Override public void beginContact(Contact contact)
  {
  }
  
  @Override public void endContact(Contact contact)
  {
  }
  
  @Override public void preSolve(Contact contact, Manifold oldManifold)
  {
  }
  
  @Override public void postSolve(Contact contact, ContactImpulse impulse)
  {
  }
}

class PlayerControllerComponent extends Component implements IEventListener
{
  private float acceleration;
  private float maxSpeed;
  private float jumpForce;
  
  private boolean upButtonDown;
  private boolean leftButtonDown;
  private boolean rightButtonDown;
  
  public PlayerControllerComponent(GameObject _gameObject)
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
  }
  
  @Override public void destroy()
  {
    eventManager.deregister(EventType.UP_BUTTON_PRESSED, this);
    eventManager.deregister(EventType.LEFT_BUTTON_PRESSED, this);
    eventManager.deregister(EventType.RIGHT_BUTTON_PRESSED, this);
    
    eventManager.deregister(EventType.UP_BUTTON_RELEASED, this);
    eventManager.deregister(EventType.LEFT_BUTTON_RELEASED, this);
    eventManager.deregister(EventType.RIGHT_BUTTON_RELEASED, this);
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    acceleration = xmlComponent.getFloat("acceleration");
    maxSpeed = xmlComponent.getFloat("maxSpeed");
    jumpForce = xmlComponent.getFloat("jumpForce");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.PLAYER_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    PVector moveVector = new PVector();
    
    moveVector.add(getKeyboardInput());
    moveVector.add(getEmgInput());

    moveVector.normalize();
    
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
      
      // NOTE: This jump-mechanic is really hacky and should be replaced by collision detection using JBox 2D.
      ArrayList<IGameObject> platformManagerList = gameObjectManager.getGameObjectsByTag("platform_manager");
      if (!platformManagerList.isEmpty())
      {
        IComponent tcomponent = platformManagerList.get(0).getComponent(ComponentType.PLATFORM_MANAGER_CONTROLLER);
        if (tcomponent != null)
        {
          PlatformManagerControllerComponent platformManagerControllerComponent = (PlatformManagerControllerComponent)tcomponent;
          float riseSpeed = platformManagerControllerComponent.getRiseSpeed();
          
          if (linearVelocity.y < 0.01f - riseSpeed && linearVelocity.y > -0.01f - riseSpeed)
          {
            rigidBodyComponent.applyLinearImpulse(new PVector(0.0f, moveVector.y * jumpForce * deltaTime), gameObject.getTranslation(), true);
          }
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

  private PVector getEmgInput() {
    HashMap<String, Float> readings = emgManager.poll();
    return new PVector(
      readings.get("RIGHT")-readings.get("LEFT"),
      -readings.get("JUMP"));
  }
}

class PlatformManagerControllerComponent extends Component
{
  private LinkedList<IGameObject> platforms;
  
  private String platformFile;
  
  private int maxPlatformLevels;
  
  private float leftSide;
  private float rightSide;
  
  private float disappearHeight;
  private float spawnHeight;
  
  private int minGapsPerLevel;
  private int maxGapsPerLevel;
  
  private float minGapSize;
  private float maxGapSize;
  private float minDistanceBetweenGaps;
  
  private float minHeightBetweenPlatformLevels;
  private float maxHeightBetweenPlatformLevels;
  private float nextHeightBetweenPlatformLevels;
  
  private float riseSpeed;
  
  public PlatformManagerControllerComponent(GameObject _gameObject)
  {
    super (_gameObject);
    
    platforms = new LinkedList<IGameObject>();
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    platformFile = xmlComponent.getString("platformFile");
    maxPlatformLevels = xmlComponent.getInt("maxPlatformLevels");
    leftSide = xmlComponent.getFloat("leftSide");
    rightSide = xmlComponent.getFloat("rightSide");
    disappearHeight = xmlComponent.getFloat("disappearHeight");
    spawnHeight = xmlComponent.getFloat("spawnHeight");
    minGapsPerLevel = xmlComponent.getInt("minGapsPerLevel");
    maxGapsPerLevel = xmlComponent.getInt("maxGapsPerLevel");
    minGapSize = xmlComponent.getFloat("minGapSize");
    maxGapSize = xmlComponent.getFloat("maxGapSize");
    minDistanceBetweenGaps = xmlComponent.getFloat("minDistanceBetweenGaps");
    minHeightBetweenPlatformLevels = xmlComponent.getFloat("minHeightBetweenPlatformLevels");
    maxHeightBetweenPlatformLevels = xmlComponent.getFloat("maxHeightBetweenPlatformLevels");
    nextHeightBetweenPlatformLevels = random(minHeightBetweenPlatformLevels, maxHeightBetweenPlatformLevels);
    riseSpeed = xmlComponent.getFloat("riseSpeed");
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
      spawnPlatformLevel();
      nextHeightBetweenPlatformLevels = random(minHeightBetweenPlatformLevels, maxHeightBetweenPlatformLevels);
    }
  }
  
  private void spawnPlatformLevel()
  {
    ArrayList<PVector> platformRanges = new ArrayList<PVector>();
    platformRanges.add(new PVector(leftSide, rightSide));
    
    int gapsInLevel = int(random(minGapsPerLevel, maxGapsPerLevel + 1)); //<>//
    
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
      
      IGameObject platform = gameObjectManager.addGameObject(platformFile, new PVector(platformPosition, spawnHeight), new PVector(platformWidth, 1.0));
      IComponent component = platform.getComponent(ComponentType.RIGID_BODY);
      if (component != null)
      {
        RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
        rigidBodyComponent.setLinearVelocity(new PVector(0.0, -riseSpeed));
      }
      platforms.add(platform);
    }
  }
  
  public float getRiseSpeed() 
  { 
    return riseSpeed; 
  }
}

IComponent componentFactory(GameObject gameObject, XML xmlComponent)
{
  IComponent component;
  String componentName = xmlComponent.getName();
  
  if (componentName.equals("Render"))
  {
    component = new RenderComponent(gameObject);
    component.fromXML(xmlComponent);
    return component;
  }
  else if (componentName.equals("RigidBody"))
  {
    component = new RigidBodyComponent(gameObject);
    component.fromXML(xmlComponent);
    return component;
  }
  else if (componentName.equals("PlayerController"))
  {
    component = new PlayerControllerComponent(gameObject);
    component.fromXML(xmlComponent);
    return component;
  }
  else if (componentName.equals("PlatformManagerController"))
  {
    component = new PlatformManagerControllerComponent(gameObject);
    component.fromXML(xmlComponent);
    return component;
  }
  
  return null;
}