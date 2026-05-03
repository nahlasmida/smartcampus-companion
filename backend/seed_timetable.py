import asyncio
import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import init_db
from app.models.timetable import Timetable

async def seed_timetable():
    print("🌱 Seeding timetable...")
    await init_db()
    
    # Clear existing
    await Timetable.find_all().delete()
    print("🗑️ Cleared existing timetable entries")
    
    entries = [
        Timetable(
            course_name="Mobile App Development",
            teacher="Dr. Ahmed",
            day="Monday",
            start_time="09:00",
            end_time="10:30",
            room="Room 101",
            color="#4CAF50"
        ),
        Timetable(
            course_name="Database Systems",
            teacher="Prof. Sarah",
            day="Monday",
            start_time="11:00",
            end_time="12:30",
            room="Room 202",
            color="#2196F3"
        ),
        Timetable(
           course_name="Study Day",
           teacher="Self Study",
           day="Sunday",
           start_time="10:00",
           end_time="16:00",
           room="Library",
           color="#9C27B0"
),
        Timetable(
            course_name="Web Development",
            teacher="Dr. Karim",
            day="Tuesday",
            start_time="09:00",
            end_time="10:30",
            room="Lab 301",
            color="#FF9800"
        ),
        Timetable(
            course_name="Computer Networks",
            teacher="Prof. Lina",
            day="Tuesday",
            start_time="13:00",
            end_time="14:30",
            room="Room 105",
            color="#9C27B0"
        ),
        Timetable(
            course_name="Artificial Intelligence",
            teacher="Dr. Mohamed",
            day="Wednesday",
            start_time="10:00",
            end_time="11:30",
            room="Room 203",
            color="#E91E63"
        ),
        Timetable(
            course_name="Software Engineering",
            teacher="Prof. Nadia",
            day="Thursday",
            start_time="09:00",
            end_time="10:30",
            room="Room 101",
            color="#00BCD4"
        ),
        Timetable(
            course_name="Cloud Computing",
            teacher="Dr. Youssef",
            day="Thursday",
            start_time="14:00",
            end_time="15:30",
            room="Lab 302",
            color="#3F51B5"
        ),
        Timetable(
            course_name="Cybersecurity",
            teacher="Prof. Omar",
            day="Friday",
            start_time="09:00",
            end_time="10:30",
            room="Room 204",
            color="#F44336"
        ),
        Timetable(
            course_name="Data Science",
            teacher="Dr. Leila",
            day="Friday",
            start_time="11:00",
            end_time="12:30",
            room="Lab 303",
            color="#8BC34A"
        ),
        Timetable(
            course_name="Graduation Project",
            teacher="Dr. Ahmed",
            day="Saturday",
            start_time="10:00",
            end_time="12:00",
            room="Room 101",
            color="#795548"
        )
    ]
    
    for entry in entries:
        await entry.insert()
        print(f"✅ Inserted: {entry.course_name} - {entry.day} at {entry.start_time}")
    
    count = await Timetable.find_all().count()
    print(f"\n📊 Total timetable entries in database: {count}")

if __name__ == "__main__":
    asyncio.run(seed_timetable())