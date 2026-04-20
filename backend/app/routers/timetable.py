from fastapi import APIRouter, Depends
from app.services.campus_service import get_timetable
from app.dependencies.auth import get_current_user

router = APIRouter(prefix="/timetable", tags=["Timetable"])

@router.get("/")
async def list_timetable(user=Depends(get_current_user)):
    items = await get_timetable()
    return [
        {
            "id": str(i.id),
            "subject": i.subject,
            "room": i.room,
            "day": i.day,
            "start_time": i.start_time,
            "end_time": i.end_time,
            "professor": i.professor,
            "group": i.group,
            "semester": i.semester
        }
        for i in items
    ]