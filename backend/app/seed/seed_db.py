import asyncio
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from motor.motor_asyncio import AsyncIOMotorClient
from beanie import init_beanie
from app.core.config import settings
from app.core.security import hash_password
from app.models.user import User
from app.models.announcement import Announcement
from app.models.event import Event
from app.models.timetable import TimetableItem
from datetime import datetime

async def seed():
    print("Connecting to MongoDB...")
    client = AsyncIOMotorClient(settings.MONGO_URI)
    await init_beanie(
        database=client.smartcampus,
        document_models=[User, Announcement, Event, TimetableItem]
    )

    print("Clearing existing data...")
    await User.delete_all()
    await Announcement.delete_all()
    await Event.delete_all()
    await TimetableItem.delete_all()

    print("Seeding users...")
    user = User(
        email="student@campus.dz",
        hashed_password=hash_password("password123"),
        full_name="Ali Benali",
        role="student"
    )
    await user.insert()

    print("Seeding announcements...")
    await Announcement(
        title="Welcome Back to Campus!",
        body="We are excited to welcome all students back for the new semester. Please check your timetables and report to your departments.",
        category="general",
        is_pinned=True
    ).insert()

    await Announcement(
        title="Library Extended Hours",
        body="The campus library will now be open from 7am to 11pm on weekdays during exam season.",
        category="facilities",
        is_pinned=False
    ).insert()

    await Announcement(
        title="WiFi Maintenance Notice",
        body="Campus WiFi will be unavailable on Saturday from 2am to 6am for scheduled maintenance.",
        category="IT",
        is_pinned=False
    ).insert()

    print("Seeding events...")
    await Event(
        title="Annual Tech Conference",
        description="Join us for the annual Computer Science conference featuring guest speakers from major tech companies.",
        location="Main Auditorium - Building A",
        start_time=datetime(2025, 9, 20, 9, 0),
        end_time=datetime(2025, 9, 20, 17, 0),
        tags=["tech", "conference", "networking"]
    ).insert()

    await Event(
        title="Student Club Fair",
        description="Discover all student clubs and associations. Sign up for activities that interest you!",
        location="Campus Central Plaza",
        start_time=datetime(2025, 9, 25, 10, 0),
        end_time=datetime(2025, 9, 25, 16, 0),
        tags=["students", "clubs", "social"]
    ).insert()

    print("Seeding timetable...")
    timetable_items = [
        TimetableItem(subject="Mobile Development", room="B204", day="Monday",
                      start_time="08:30", end_time="10:00", professor="Dr. Meziane", semester=1),
        TimetableItem(subject="Algorithms", room="A101", day="Monday",
                      start_time="10:15", end_time="11:45", professor="Dr. Khelil", semester=1),
        TimetableItem(subject="Database Systems", room="C302", day="Tuesday",
                      start_time="08:30", end_time="10:00", professor="Dr. Hamdi", semester=1),
        TimetableItem(subject="Networks", room="B105", day="Tuesday",
                      start_time="13:00", end_time="14:30", professor="Dr. Saidi", semester=1),
        TimetableItem(subject="Software Engineering", room="A203", day="Wednesday",
                      start_time="10:15", end_time="11:45", professor="Dr. Ait Ali", semester=1),
        TimetableItem(subject="Mobile Development", room="B204", day="Thursday",
                      start_time="08:30", end_time="10:00", professor="Dr. Meziane", semester=1),
    ]
    for item in timetable_items:
        await item.insert()

    print("")
    print("Database seeded successfully!")
    print(f"  Login email   : student@campus.dz")
    print(f"  Login password: password123")

if __name__ == "__main__":
    asyncio.run(seed())