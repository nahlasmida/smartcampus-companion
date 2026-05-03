from beanie import Document
from datetime import datetime
from typing import Optional

class Timetable(Document):
    course_name: str
    teacher: str
    day: str  # Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
    start_time: str  # "08:00", "09:30", etc.
    end_time: str
    room: str
    color: str = "#4CAF50"  # For UI color coding
    created_at: datetime = datetime.utcnow()
    updated_at: datetime = datetime.utcnow()
    
    class Settings:
        name = "timetable"