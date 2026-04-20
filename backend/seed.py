import asyncio
import sys
import os

# Add current directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import init_db
from app.models.announcement import Announcement
from datetime import datetime

async def seed():
    print("🌱 Starting seed...")
    
    # Initialize database
    await init_db()
    
    # Clear existing announcements
    await Announcement.find_all().delete()
    print("🗑️ Cleared existing announcements")
    
    # Create new announcements
    announcements = [
        Announcement(
            title="🎉 Welcome to SmartCampus!",
            content="Your campus companion app is now live! Check your timetable, events, and announcements.",
            author="University Admin",
            is_pinned=True,
            created_at=datetime.utcnow()
        ),
        Announcement(
            title="📚 Library Hours Extended",
            content="During exam week, the library will be open until 10 PM.",
            author="Library Staff",
            is_pinned=False,
            created_at=datetime.utcnow()
        ),
        Announcement(
            title="💻 Guest Lecture: AI in Education",
            content="Join us on Friday at 2 PM in Hall A.",
            author="CS Department",
            is_pinned=False,
            created_at=datetime.utcnow()
        ),
        Announcement(
            title="🏆 Hackathon 2026",
            content="Register now! Prizes worth $5000.",
            author="Student Union",
            is_pinned=True,
            created_at=datetime.utcnow()
        )
    ]
    
    # Insert each announcement
    for ann in announcements:
        await ann.insert()
        print(f"✅ Inserted: {ann.title}")
    
    # Verify
    count = await Announcement.find_all().count()
    print(f"\n📊 Total announcements in database: {count}")

if __name__ == "__main__":
    asyncio.run(seed())