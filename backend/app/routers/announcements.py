from fastapi import APIRouter, Depends
from app.services.campus_service import get_announcements
from app.dependencies.auth import get_current_user

router = APIRouter(prefix="/announcements", tags=["Announcements"])

@router.get("/")
async def list_announcements(user=Depends(get_current_user)):
    items = await get_announcements()
    return [
        {
            "id": str(i.id),
            "title": i.title,
            "body": i.body,
            "image_url": i.image_url,
            "category": i.category,
            "is_pinned": i.is_pinned,
            "created_at": i.created_at.isoformat()
        }
        for i in items
    ]