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
  
  // Key released events.
  UP_BUTTON_RELEASED,
  LEFT_BUTTON_RELEASED,
  RIGHT_BUTTON_RELEASED,
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

// A class must implement this interface to register as a listener for events.
interface IEventListener
{
  // When an event is sent by the manager, this method will receive it.
  public void handleEvent(IEvent event);
}

// The Event Manager keeps track of listeners and forwards events to them.
interface IEventManager
{
  // Register and deregister your object to certain event types.
  public void register(EventType eventType, IEventListener listener);
  public void deregister(EventType eventType, IEventListener listener);
  
  // Use queueEvent to send out an event you have created to all listeners.
  // It will be queued for sending during the sendEvents() part of the main loop.
  public void queueEvent(IEvent event);
  
  // Only the main loop should call this. Sends all queued events out to listeners.
  public void sendEvents();
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
  private HashMap<EventType, LinkedList<IEventListener>> listeners;
  private HashMap<EventType, LinkedList<IEventListener>> addMap;
  private HashMap<EventType, LinkedList<IEventListener>> removeMap;
  
  private HashMap<EventType, LinkedList<IEvent>> eventMap;
  
  public EventManager()
  {
    listeners = new HashMap<EventType, LinkedList<IEventListener>>();
    addMap = new HashMap<EventType, LinkedList<IEventListener>>();
    removeMap = new HashMap<EventType, LinkedList<IEventListener>>();
    eventMap = new HashMap<EventType, LinkedList<IEvent>>();
    
    addEventTypeToMaps(EventType.UP_BUTTON_PRESSED);
    addEventTypeToMaps(EventType.LEFT_BUTTON_PRESSED);
    addEventTypeToMaps(EventType.RIGHT_BUTTON_PRESSED);
    
    addEventTypeToMaps(EventType.UP_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.LEFT_BUTTON_RELEASED);
    addEventTypeToMaps(EventType.RIGHT_BUTTON_RELEASED);
  }
  
  private void addEventTypeToMaps(EventType eventType)
  {
    listeners.put(eventType, new LinkedList<IEventListener>());
    addMap.put(eventType, new LinkedList<IEventListener>());
    removeMap.put(eventType, new LinkedList<IEventListener>());
    eventMap.put(eventType, new LinkedList<IEvent>());
  }
  
  @Override public void register(EventType eventType, IEventListener listener)
  {
    addMap.get(eventType).add(listener);
  }
  
  @Override public void deregister(EventType eventType, IEventListener listener)
  {
    removeMap.get(eventType).add(listener);
  }
  
  @Override public void queueEvent(IEvent event)
  {
    eventMap.get(event.getEventType()).addLast(event);
  }
  
  @Override public void sendEvents()
  {
    for (Map.Entry entry : eventMap.entrySet())
    {
      EventType eventType = (EventType)entry.getKey();
      LinkedList<IEvent> eventQueue = (LinkedList<IEvent>)entry.getValue();
      
      IEvent event = eventQueue.pollFirst();
      while (event != null)
      {
        for (IEventListener listener : listeners.get(eventType))
        {
          listener.handleEvent(event);
        }
        
        event = eventQueue.pollFirst();
      }
     
      assert(eventQueue.size() == 0);
    }
    
    for (Map.Entry entry : addMap.entrySet())
    {
      EventType eventType = (EventType)entry.getKey();
      LinkedList<IEventListener> listenersToAdd = (LinkedList<IEventListener>)entry.getValue();
      
      for (IEventListener listener : listenersToAdd)
      {
        listeners.get(eventType).add(listener);
      }
      
      listenersToAdd.clear();
    }
    
    for (Map.Entry entry : removeMap.entrySet())
    {
      EventType eventType = (EventType)entry.getKey();
      LinkedList<IEventListener> listenersToRemove = (LinkedList<IEventListener>)entry.getValue();
      
      for (IEventListener listener : listenersToRemove)
      {
        listeners.get(eventType).remove(listener);
      }
      
      listenersToRemove.clear();
    }
  }
}