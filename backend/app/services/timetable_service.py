from app.models.timetable import Timetable
from app.schemas.timetable import TimetableCreate, TimetableUpdate
from datetime import datetime
from typing import List, Optional
from bson import ObjectId

async def get_all_timetable() -> List[dict]:
    """Get all timetable entries"""
    entries = await Timetable.find_all().to_list()
    
    result = []
    for entry in entries:
        entry_dict = entry.model_dump()
        entry_dict["id"] = str(entry_dict["id"])
        result.append(entry_dict)
    
    return result

async def get_timetable_by_day(day: str) -> List[dict]:
    """Get timetable entries for a specific day, sorted by start_time"""
    entries = await Timetable.find(Timetable.day == day).to_list()
    
    # Sort by start_time
    entries.sort(key=lambda x: x.start_time)
    
    result = []
    for entry in entries:
        entry_dict = entry.model_dump()
        entry_dict["id"] = str(entry_dict["id"])
        result.append(entry_dict)
    
    return result

async def get_timetable_by_id(entry_id: str) -> Optional[dict]:
    """Get a single timetable entry by ID"""
    try:
        entry = await Timetable.get(ObjectId(entry_id))
        if not entry:
            return None
        
        entry_dict = entry.model_dump()
        entry_dict["id"] = str(entry_dict["id"])
        return entry_dict
    except:
        return None

async def create_timetable_entry(data: TimetableCreate) -> dict:
    """Create a new timetable entry"""
    entry = Timetable(
        course_name=data.course_name,
        teacher=data.teacher,
        day=data.day,
        start_time=data.start_time,
        end_time=data.end_time,
        room=data.room,
        color=data.color,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    await entry.insert()
    
    entry_dict = entry.model_dump()
    entry_dict["id"] = str(entry_dict["id"])
    return entry_dict

async def update_timetable_entry(
    entry_id: str, 
    data: TimetableUpdate
) -> Optional[dict]:
    """Update an existing timetable entry"""
    try:
        entry = await Timetable.get(ObjectId(entry_id))
        if not entry:
            return None
        
        update_data = data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(entry, key, value)
        
        entry.updated_at = datetime.utcnow()
        await entry.save()
        
        entry_dict = entry.model_dump()
        entry_dict["id"] = str(entry_dict["id"])
        return entry_dict
    except:
        return None

async def delete_timetable_entry(entry_id: str) -> bool:
    """Delete a timetable entry"""
    try:
        entry = await Timetable.get(ObjectId(entry_id))
        if not entry:
            return False
        await entry.delete()
        return True
    except:
        return False

async def get_current_class() -> Optional[dict]:
    """Get the class currently happening based on current time and day"""
    from datetime import datetime as dt
    now = dt.now()
    current_day = now.strftime("%A")  # Monday, Tuesday, etc.
    current_time = now.strftime("%H:%M")
    
    entries = await Timetable.find(Timetable.day == current_day).to_list()
    
    for entry in entries:
        if entry.start_time <= current_time <= entry.end_time:
            entry_dict = entry.model_dump()
            entry_dict["id"] = str(entry_dict["id"])
            return entry_dict
    
    return None