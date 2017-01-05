//=========================================================================================================
// Author: David Hanna
//
// A collection of modules that comprise a re-usable game event system.
//=========================================================================================================

//----------------------------------------------------------------
// INTERFACE
//----------------------------------------------------------------

// The supported types of events. When adding a new event type, also add to the
// EventManager constructor a new collection for the type.
enum EventType
{
  // Key pressed events.
  UP_BUTTON_PRESSED,
  LEFT_BUTTON_PRESSED,
  RIGHT_BUTTON_PRESSED,
  DOWN_BUTTON_PRESSED,
  SPACEBAR_PRESSED,
  ESCAPE_PRESSED,
  
  // Key released events.
  UP_BUTTON_RELEASED,
  LEFT_BUTTON_RELEASED,
  RIGHT_BUTTON_RELEASED,
  
  COIN_COLLECTED,
  UPDATE_SCORE,
  MUSIC_RESTART,

  // Mouse clicked events.
  MOUSE_PRESSED,
  MOUSE_CLICKED,
  MOUSE_DRAGGED,
  MOUSE_RELEASED,
  MOUSE_MOVED,

  // Button clicked events.
  BUTTON_CLICKED,
  
  SLIDER_DRAGGED,
  SLIDER_RELEASED,

  GAME_OVER,
  DESTROY_COIN,
  LEVEL_UP,
  PLATFORM_LEVEL_UP,
  
  //Events Associated with the Bonus Fitts Law Level
  PUSH_BONUS,
  FINISH_BONUS,
  BONUS_COINS_COLLECTED,
  THROUGH_PLATFORM_GAP,
  
  // Events associated with the calibrate screen
  CALIBRATE_SUCCESS,
  CALIBRATE_FAILURE,

  COUNTDOWN_UPDATE,

  PLAYER_CURRENT_SPEED,
  PLAYER_PLATFORM_COLLISION,
  PLAYER_GROUND_COLLISION,

  MODAL_HOVER,
  MODAL_OFF,

  PLAYER_PLATFORM_EXIT,
  PLAYER_BREAK_PLATFORM_COLLISION,
  PLAYER_BREAK_PLATFORM_EXIT,
  PLAYER_BREAK_PLATFORM_FALL,
  TOGGLE_CALIBRATION_DISPLAY,
  TOGGLE_GRAPH_DISPLAY,
  PLAYER_PORTAL_COLLISION,
  PLAYER_END_PORTAL_COLLISION,

  NO_BUTTONS_DOWN;
}

// This is the actual event that is created by the sender and sent to all listeners.
// Events must have a type, and may specify additional context parameters.
public interface IEvent
{
  // Use this to differentiate if your object is listening for multiple event types.
  public EventType   getEventType();
  
  // Adds a new context parameter of a certain type to this event.
  public void        addStringParameter(String name, String value);
  public void        addFloatParameter(String name, float value);
  public void        addIntParameter(String name, int value);
  public void        addGameObjectParameter(String name, IGameObject value);
  
  // Use these to get a parameter, but it does not have to have been set by the sender. A default value is required.
  public String      getOptionalStringParameter(String name, String defaultValue);
  public float       getOptionalFloatParameter(String name, float defaultValue);
  public int         getOptionalIntParameter(String name, int defaultValue);
  public IGameObject getOptionalGameObjectParameter(String name, IGameObject defaultValue);
  
  // Use these to get a parameter that must have been set by the sender. If the sender did not set it, this is an error
  // and the game will halt.
  public String      getRequiredStringParameter(String name);
  public float       getRequiredFloatParameter(String name);
  public int         getRequiredIntParameter(String name);
  public IGameObject getRequiredGameObjectParameter(String name);
}

// The Event Manager keeps track of listeners and forwards events to them.
interface IEventManager
{
  // Use queueEvent to send out an event you have created to all listeners.
  // It will be received by listeners next frame.
  public void queueEvent(IEvent event);
  
  // Returns the events of a given type that were queued last frame.
  public ArrayList<IEvent> getEvents(EventType eventType);
  
  // Only the main loop should call this. Clears ready events from last frame and 
  // moves the queued events to the ready events for this frame.
  public void update();
}

//-------------------------------------------------------------------------
// IMPLEMENTATION
//-------------------------------------------------------------------------

class Event implements IEvent
{
  private EventType eventType;
  
  private HashMap<String, String> stringParameters;
  private HashMap<String, Float> floatParameters;
  private HashMap<String, Integer> intParameters;
  private HashMap<String, IGameObject> gameObjectParameters;
  
  public Event(EventType _eventType)
  {
    eventType = _eventType;
    stringParameters = new HashMap<String, String>();
    floatParameters = new HashMap<String, Float>();
    intParameters = new HashMap<String, Integer>();
    gameObjectParameters = new HashMap<String, IGameObject>();
  }
  
  @Override public EventType getEventType()
  {
    return eventType;
  }
  
  @Override public void addStringParameter(String name, String value)
  {
    stringParameters.put(name, value);
  }
  
  @Override public void addFloatParameter(String name, float value)
  {
    floatParameters.put(name, value);
  }
  
  @Override public void addIntParameter(String name, int value)
  {
    intParameters.put(name, value);
  }
  
  @Override public void addGameObjectParameter(String name, IGameObject value)
  {
    gameObjectParameters.put(name, value);
  }
  
  @Override public String getOptionalStringParameter(String name, String defaultValue)
  {
    if (stringParameters.containsKey(name))
    {
      return stringParameters.get(name);
    }
    
     return defaultValue;
  }
  
  @Override public float getOptionalFloatParameter(String name, float defaultValue)
  {
    if (floatParameters.containsKey(name))
    {
      return floatParameters.get(name);
    }
     
     return defaultValue;
  }
  
  @Override public int getOptionalIntParameter(String name, int defaultValue)
  {
    if (intParameters.containsKey(name))
    {
      return intParameters.get(name);
    }
    
    return defaultValue;
  }
  
  @Override public IGameObject getOptionalGameObjectParameter(String name, IGameObject defaultValue)
  {
    if (gameObjectParameters.containsKey(name))
    {
      return gameObjectParameters.get(name);
    }
    
    return defaultValue;
  }
  
 @Override  public String getRequiredStringParameter(String name)
  {
    assert(stringParameters.containsKey(name));
    return stringParameters.get(name);
  }
  
  @Override public float getRequiredFloatParameter(String name)
  {
    assert(floatParameters.containsKey(name));
    return floatParameters.get(name);
  }
  
  @Override public int getRequiredIntParameter(String name)
  {
    assert(intParameters.containsKey(name));
    return intParameters.get(name);
  }
  
  @Override public IGameObject getRequiredGameObjectParameter(String name)
  {
    assert(gameObjectParameters.containsKey(name));
    return gameObjectParameters.get(name);
  }
}

class EventManager implements IEventManager
{
  // queued events will be ready and received by listeners next frame. cleared each frame.
  private HashMap<EventType, ArrayList<IEvent>> queuedEvents;
  
  // ready events are cleared and added to from queued events each frame.
  private HashMap<EventType, ArrayList<IEvent>> readyEvents;
  
  public EventManager()
  {
    queuedEvents = new HashMap<EventType, ArrayList<IEvent>>();
    readyEvents = new HashMap<EventType, ArrayList<IEvent>>();
    
    addEventTypeToMaps(EventType.UP_BUTTON_PRESSED);
    addEventTypeToMaps(EventType.LEFT_BUTTON_PRESSED);
    addEventTypeToMaps(EventType.RIGHT_BUTTON_PRESSED);
    addEventTypeToMaps(EventType.DOWN_BUTTON_PRESSED);
    addEventTypeToMaps(EventType.SPACEBAR_PRESSED);
    addEventTypeToMaps(EventType.ESCAPE_PRESSED);
    
    addEventTypeToMaps(EventType.UP_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.LEFT_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.RIGHT_BUTTON_RELEASED);
    
    addEventTypeToMaps(EventType.COIN_COLLECTED);
    addEventTypeToMaps(EventType.UPDATE_SCORE);
    addEventTypeToMaps(EventType.MUSIC_RESTART);
    
    addEventTypeToMaps(EventType.MOUSE_PRESSED);
    addEventTypeToMaps(EventType.MOUSE_CLICKED);
    addEventTypeToMaps(EventType.MOUSE_DRAGGED);
    addEventTypeToMaps(EventType.MOUSE_RELEASED);
    addEventTypeToMaps(EventType.MOUSE_MOVED);

    addEventTypeToMaps(EventType.BUTTON_CLICKED);
    
    addEventTypeToMaps(EventType.SLIDER_DRAGGED);
    addEventTypeToMaps(EventType.SLIDER_RELEASED);

    addEventTypeToMaps(EventType.GAME_OVER);
    addEventTypeToMaps(EventType.DESTROY_COIN);
    addEventTypeToMaps(EventType.LEVEL_UP);
    addEventTypeToMaps(EventType.PLATFORM_LEVEL_UP);
    
    addEventTypeToMaps(EventType.PUSH_BONUS);
    addEventTypeToMaps(EventType.FINISH_BONUS);
    addEventTypeToMaps(EventType.BONUS_COINS_COLLECTED);
    addEventTypeToMaps(EventType.THROUGH_PLATFORM_GAP);
    
    addEventTypeToMaps(EventType.CALIBRATE_SUCCESS);
    addEventTypeToMaps(EventType.CALIBRATE_FAILURE);

    addEventTypeToMaps(EventType.COUNTDOWN_UPDATE);
    
    addEventTypeToMaps(EventType.PLAYER_CURRENT_SPEED);
    addEventTypeToMaps(EventType.PLAYER_PLATFORM_COLLISION);
    addEventTypeToMaps(EventType.PLAYER_GROUND_COLLISION);

    addEventTypeToMaps(EventType.MODAL_HOVER);
    addEventTypeToMaps(EventType.MODAL_OFF);

    addEventTypeToMaps(EventType.PLAYER_PLATFORM_EXIT);
    addEventTypeToMaps(EventType.PLAYER_BREAK_PLATFORM_COLLISION);
    addEventTypeToMaps(EventType.PLAYER_BREAK_PLATFORM_EXIT);
    addEventTypeToMaps(EventType.PLAYER_BREAK_PLATFORM_FALL);
    addEventTypeToMaps(EventType.TOGGLE_CALIBRATION_DISPLAY);
    addEventTypeToMaps(EventType.TOGGLE_GRAPH_DISPLAY);
    addEventTypeToMaps(EventType.PLAYER_PORTAL_COLLISION);
    addEventTypeToMaps(EventType.PLAYER_END_PORTAL_COLLISION);

    addEventTypeToMaps(EventType.NO_BUTTONS_DOWN);
  }
  
  private void addEventTypeToMaps(EventType eventType)
  {
    queuedEvents.put(eventType, new ArrayList<IEvent>());
    readyEvents.put(eventType, new ArrayList<IEvent>());
  }
  
  @Override public void queueEvent(IEvent event)
  {
    queuedEvents.get(event.getEventType()).add(event);
  }
  
  @Override public ArrayList<IEvent> getEvents(EventType eventType)
  {
    return readyEvents.get(eventType);
  }
  
  @Override public void update()
  {
    for (Map.Entry entry : queuedEvents.entrySet())
    {
      EventType eventType = (EventType)entry.getKey();
      ArrayList<IEvent> queuedEventsList = (ArrayList<IEvent>)entry.getValue();
      
      ArrayList<IEvent> readyEventsList = readyEvents.get(eventType);
      readyEventsList.clear();
      
      for (IEvent event : queuedEventsList)
      {
        readyEventsList.add(event);
      }
      
      queuedEventsList.clear();
    }
  }
}