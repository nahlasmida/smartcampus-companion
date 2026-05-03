from beanie import Document
from datetime import datetime
from typing import Optional

from bson import ObjectId

class Announcement(Document):
    title: str
    content: str
    author: str = "Admin"
    image_url: str = ""
    created_at: datetime = datetime.utcnow()
    updated_at: datetime = datetime.utcnow()
    is_pinned: bool = False
    
    class Settings:
        name = "announcements"
        
    class Config:
        json_encoders = {ObjectId: str}