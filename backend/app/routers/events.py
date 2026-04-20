from fastapi import APIRouter, Depends
from app.services.campus_service import get_events
from app.dependencies.auth import get_current_user

router = APIRouter(prefix="/events", tags=["Events"])

@router.get("/")
async def list_events(user=Depends(get_current_user)):
    items = await get_events()
    return [
        {
            "id": str(i.id),
            "title": i.title,
            "description": i.description,
            "location": i.location,
            "start_time": i.start_time.isoformat(),
            "end_time": i.end_time.isoformat(),
            "image_url": i.image_url,
            "tags": i.tags
        }
        for i in items
    ]