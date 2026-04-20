from beanie import Document
from datetime import datetime
from typing import Optional

class Event(Document):
    title: str
    description: str
    location: str
    start_time: datetime
    end_time: datetime
    organizer: str = "Student Union"
    image_url: str = ""
    created_at: datetime = datetime.utcnow()
    updated_at: datetime = datetime.utcnow()
    
    class Settings:
        name = "events"