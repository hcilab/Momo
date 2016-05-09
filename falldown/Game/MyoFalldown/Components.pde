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
  
  private ArrayList<OffsetPShape> offsetShapes;
  
  public RenderComponent(GameObject _gameObject)
  {
    super(_gameObject);
    
    offsetShapes = new ArrayList<OffsetPShape>();
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
    }
  }
  
  private void parseShapeComponents(XML xmlShape, OffsetPShape offsetShape)
  {
    for (XML xmlShapeComponent : xmlShape.getChildren())
    {
      if (xmlShapeComponent.getName().equals("FillColor"))
      {
        offsetShape.pshape.setFill(color(xmlShapeComponent.getInt("r"), xmlShapeComponent.getInt("g"), xmlShapeComponent.getInt("b"), xmlShapeComponent.getInt("a")));
      }
      else if (xmlShapeComponent.getName().equals("StrokeColor"))
      {
        offsetShape.pshape.setStroke(color(xmlShapeComponent.getInt("r"), xmlShapeComponent.getInt("g"), xmlShapeComponent.getInt("b"), xmlShapeComponent.getInt("a")));
      }
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
    
    bodyDefinition.position.set(gameObject.getTranslation().x, gameObject.getTranslation().y);
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
              circleShape.m_p.set(xmlShape.getFloat("x"), xmlShape.getFloat("y"));
              circleShape.m_radius = xmlShape.getFloat("radius") * gameObject.getScale().x;
              
              fixtureDef.shape = circleShape; 
            }
            else if (shapeType.equals("box"))
            {
              PolygonShape boxShape = new PolygonShape();
              boxShape.setAsBox(xmlShape.getFloat("halfWidth") * gameObject.getScale().x, xmlShape.getFloat("halfHeight") * gameObject.getScale().y);
              
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
  
  public Body getBody()
  {
    return body;
  }
  
  @Override public void update(int deltaTime)
  {
    // Reverse sync the physically simulated position to the Game Object position.
    gameObject.setTranslation(new PVector(body.getPosition().x, body.getPosition().y));
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
    
    if (upButtonDown)
    {
      moveVector.y -= 1.0f;
    }
    if (leftButtonDown)
    {
      moveVector.x -= 1.0f;
    }
    if (rightButtonDown)
    {
      moveVector.x += 1.0f;
    }
    
    moveVector.normalize();
    
    IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
    if (component != null)
    {
      RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
      Body body = rigidBodyComponent.getBody();
      if (  (moveVector.x > 0 && body.getLinearVelocity().x < maxSpeed)
         || (moveVector.x < 0 && body.getLinearVelocity().x > -maxSpeed))
      {
        body.applyForce(new Vec2(moveVector.x * acceleration * deltaTime, 0.0f), body.getWorldCenter());
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
          
          if (body.getLinearVelocity().y < 0.01f - riseSpeed && body.getLinearVelocity().y > -0.01f - riseSpeed)
          {
            body.applyLinearImpulse(new Vec2(0.0f, moveVector.y * jumpForce * deltaTime), body.getWorldCenter(), true);
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
        rigidBodyComponent.getBody().setLinearVelocity(new Vec2(0.0, -riseSpeed));
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