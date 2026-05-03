from app.models.announcement import Announcement
from app.schemas.announcement import AnnouncementCreate, AnnouncementUpdate
from datetime import datetime
from typing import List, Optional
from bson import ObjectId

async def get_all_announcements() -> List[dict]:
    """Get all announcements, pinned first then by date"""
    announcements = await Announcement.find_all().sort(
        -Announcement.is_pinned, 
        -Announcement.created_at
    ).to_list()
    
    # Convert ObjectId to string for each announcement
    result = []
    for ann in announcements:
        ann_dict = ann.model_dump()
        # Beanie uses 'id' not '_id'
        ann_dict["id"] = str(ann_dict["id"])
        result.append(ann_dict)
    
    return result

async def get_announcement_by_id(announcement_id: str) -> Optional[dict]:
    """Get a single announcement by ID"""
    try:
        announcement = await Announcement.get(ObjectId(announcement_id))
        if not announcement:
            return None
        
        ann_dict = announcement.model_dump()
        ann_dict["id"] = str(ann_dict["id"])
        return ann_dict
    except:
        return None

async def create_announcement(data: AnnouncementCreate) -> dict:
    """Create a new announcement"""
    announcement = Announcement(
        title=data.title,
        content=data.content,
        author=data.author,
        image_url=data.image_url,
        is_pinned=data.is_pinned,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    await announcement.insert()
    
    ann_dict = announcement.model_dump()
    ann_dict["id"] = str(ann_dict["id"])
    return ann_dict

async def update_announcement(
    announcement_id: str, 
    data: AnnouncementUpdate
) -> Optional[dict]:
    """Update an existing announcement"""
    try:
        announcement = await Announcement.get(ObjectId(announcement_id))
        if not announcement:
            return None
        
        update_data = data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(announcement, key, value)
        
        announcement.updated_at = datetime.utcnow()
        await announcement.save()
        
        ann_dict = announcement.model_dump()
        ann_dict["id"] = str(ann_dict["id"])
        return ann_dict
    except:
        return None

async def delete_announcement(announcement_id: str) -> bool:
    """Delete an announcement"""
    try:
        announcement = await Announcement.get(ObjectId(announcement_id))
        if not announcement:
            return False
        await announcement.delete()
        return True
    except:
        return False