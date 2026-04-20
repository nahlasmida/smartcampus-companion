from beanie import init_beanie
from motor.motor_asyncio import AsyncIOMotorClient
from app.core.config import settings
from app.models.user import User
from app.models.announcement import Announcement
from app.models.event import Event
from app.models.timetable import TimetableItem

async def init_db():
    # Use localhost because Docker exposes MongoDB to Windows on port 27017
    client = AsyncIOMotorClient("mongodb://localhost:27017")
    
    await init_beanie(
        database=client.smartcampus,
        document_models=[User, Announcement, Event, TimetableItem]
    )
    print("✅ Database connected to MongoDB in Docker!")