from beanie import Document

class TimetableItem(Document):
    subject: str
    room: str
    day: str
    start_time: str
    end_time: str
    professor: str = ""
    group: str = ""
    semester: int = 1

    class Settings:
        name = "timetable"