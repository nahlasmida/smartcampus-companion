from pydantic import BaseModel

class TimetableItemOut(BaseModel):
    id: str
    subject: str
    room: str
    day: str
    start_time: str
    end_time: str
    professor: str
    group: str
    semester: int