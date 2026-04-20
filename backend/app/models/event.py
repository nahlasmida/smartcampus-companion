from beanie import Document
from datetime import datetime
from typing import List, Optional

class Event(Document):
    title: str
    description: str
    location: str = ""
    start_time: datetime
    end_time: datetime
    image_url: str = ""
    tags: List[str] = []
    created_by: Optional[str] = None
    created_at: datetime = datetime.utcnow()

    class Settings:
        name = "events"