from beanie import init_beanie
from motor.motor_asyncio import AsyncIOMotorClient
from app.models.user import User
from app.models.announcement import Announcement
from app.models.event import Event
from app.models.timetable import TimetableItem

async def init_db():
    # Connect to MongoDB (Docker container)
    client = AsyncIOMotorClient("mongodb://localhost:27017")
    
    # Use smartcampus database
    database = client.smartcampus
    
    # Test connection
    await database.command("ping")
    print("✅ MongoDB connected!")
    
    await init_beanie(
        database=database,
        document_models=[User, Announcement, Event, TimetableItem]
    )
    print("✅ Beanie initialized with smartcampus database")