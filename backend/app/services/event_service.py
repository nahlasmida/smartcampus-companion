from app.models.event import Event
from app.schemas.event import EventCreate, EventUpdate
from datetime import datetime
from typing import List, Optional
from bson import ObjectId

async def get_all_events() -> List[dict]:
    """Get all events"""
    events = await Event.find_all().to_list()
    
    result = []
    for event in events:
        event_dict = event.model_dump()
        event_dict["id"] = str(event_dict["id"])
        result.append(event_dict)
    
    return result

async def get_upcoming_events() -> List[dict]:
    """Get only upcoming events (start_time >= now)"""
    now = datetime.utcnow()
    events = await Event.find(Event.start_time >= now).to_list()
    
    result = []
    for event in events:
        event_dict = event.model_dump()
        event_dict["id"] = str(event_dict["id"])
        result.append(event_dict)
    
    return result

async def get_event_by_id(event_id: str) -> Optional[dict]:
    """Get a single event by ID"""
    try:
        event = await Event.get(ObjectId(event_id))
        if not event:
            return None
        
        event_dict = event.model_dump()
        event_dict["id"] = str(event_dict["id"])
        return event_dict
    except:
        return None

async def create_event(data: EventCreate) -> dict:
    """Create a new event"""
    event = Event(
        title=data.title,
        description=data.description,
        location=data.location,
        start_time=data.start_time,
        end_time=data.end_time,
        organizer=data.organizer,
        image_url=data.image_url,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    await event.insert()
    
    event_dict = event.model_dump()
    event_dict["id"] = str(event_dict["id"])
    return event_dict

async def update_event(event_id: str, data: EventUpdate) -> Optional[dict]:
    """Update an existing event"""
    try:
        event = await Event.get(ObjectId(event_id))
        if not event:
            return None
        
        update_data = data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(event, key, value)
        
        event.updated_at = datetime.utcnow()
        await event.save()
        
        event_dict = event.model_dump()
        event_dict["id"] = str(event_dict["id"])
        return event_dict
    except:
        return None

async def delete_event(event_id: str) -> bool:
    """Delete an event"""
    try:
        event = await Event.get(ObjectId(event_id))
        if not event:
            return False
        await event.delete()
        return True
    except:
        return False