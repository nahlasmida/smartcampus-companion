from app.models.announcement import Announcement
from app.models.event import Event
from app.models.timetable import TimetableItem
from typing import List

async def get_announcements() -> List[Announcement]:
    return await Announcement.find_all().sort(-Announcement.created_at).to_list()

async def get_events() -> List[Event]:
    return await Event.find_all().sort(Event.start_time).to_list()

async def get_timetable() -> List[TimetableItem]:
    return await TimetableItem.find_all().to_list()