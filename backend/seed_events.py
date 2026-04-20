import asyncio
import sys
import os
from datetime import datetime, timedelta

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import init_db
from app.models.event import Event

async def seed_events():
    print("🌱 Seeding events...")
    await init_db()
    
    # Clear existing events
    await Event.find_all().delete()
    print("🗑️ Cleared existing events")
    
    now = datetime.utcnow()
    
    events = [
        Event(
            title="🎓 Freshman Orientation",
            description="Welcome new students! Meet faculty and get your campus tour.",
            location="Main Hall",
            start_time=now + timedelta(days=5),
            end_time=now + timedelta(days=5, hours=3),
            organizer="Student Affairs"
        ),
        Event(
            title="💻 Coding Workshop",
            description="Learn Flutter and FastAPI basics.",
            location="CS Building, Room 101",
            start_time=now + timedelta(days=7),
            end_time=now + timedelta(days=7, hours=2),
            organizer="CS Club"
        ),
        Event(
            title="🏃‍♂️ Campus Marathon",
            description="Annual charity run around campus.",
            location="Stadium",
            start_time=now + timedelta(days=14),
            end_time=now + timedelta(days=14, hours=4),
            organizer="Sports Club"
        ),
        Event(
            title="📚 Exam Prep Session",
            description="Study tips and stress management.",
            location="Library",
            start_time=now + timedelta(days=3),
            end_time=now + timedelta(days=3, hours=2),
            organizer="Academic Support"
        )
    ]
    
    for event in events:
        await event.insert()
        print(f"✅ Inserted: {event.title}")
    
    count = await Event.find_all().count()
    print(f"\n📊 Total events in database: {count}")

if __name__ == "__main__":
    asyncio.run(seed_events())