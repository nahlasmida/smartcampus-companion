import asyncio
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from app.core.database import init_db
from app.models.announcement import Announcement
from datetime import datetime

async def seed_announcements():
    await init_db()
    
    # Delete existing
    await Announcement.find_all().delete()
    
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
            content="During exam week (May 1-15), the library will be open until 10 PM. Good luck with your exams!",
            author="Library Staff",
            is_pinned=False,
            created_at=datetime.utcnow()
        ),
        Announcement(
            title="💻 Guest Lecture: AI in Education",
            content="Join us on Friday at 2 PM in Hall A for a special lecture by Dr. Sarah Ahmed.",
            author="CS Department",
            is_pinned=False,
            created_at=datetime.utcnow()
        ),
        Announcement(
            title="🏆 Hackathon 2026",
            content="Register now for the annual campus hackathon! Prizes worth $5000. Deadline: May 20th.",
            author="Student Union",
            is_pinned=True,
            created_at=datetime.utcnow()
        ),
        Announcement(
            title="🚌 Shuttle Schedule Update",
            content="New shuttle timings starting next week. Check the app for updated schedules.",
            author="Transport Office",
            is_pinned=False,
            created_at=datetime.utcnow()
        )
    ]
    
    for ann in announcements:
        result = await ann.insert()
        print(f"✅ Inserted: {ann.title} (ID: {result})")
    
    # Verify
    count = await Announcement.find_all().count()
    print(f"📊 Total announcements in DB: {count}")

if __name__ == "__main__":
    asyncio.run(seed_announcements())