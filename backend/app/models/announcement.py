from beanie import Document
from datetime import datetime
from typing import Optional
from bson import ObjectId

class Announcement(Document):
    title: str
    body: str
    image_url: str = ""
    category: str = "general"
    is_pinned: bool = False
    created_at: datetime = datetime.utcnow()
    author_id: Optional[str] = None

    class Settings:
        name = "announcements"