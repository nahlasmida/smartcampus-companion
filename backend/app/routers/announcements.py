from fastapi import APIRouter, HTTPException, status, Depends, Header
from typing import List, Optional
from app.schemas.announcement import (
    AnnouncementCreate, 
    AnnouncementUpdate, 
    AnnouncementResponse
)
from app.services.announcement_service import (
    get_all_announcements,
    get_announcement_by_id,
    create_announcement,
    update_announcement,
    delete_announcement
)
from app.dependencies.auth import get_current_user
from app.models.user import User

# Simple admin secret (change this!)
ADMIN_SECRET = "campus-admin-2024"

router = APIRouter(prefix="/announcements", tags=["Announcements"])

# ============ PUBLIC ENDPOINTS (Everyone can read) ============

@router.get("/")
async def list_announcements():
    """Get all announcements - Public endpoint"""
    announcements = await get_all_announcements()
    return announcements

@router.get("/{announcement_id}")
async def get_announcement(announcement_id: str):
    """Get a single announcement by ID - Public endpoint"""
    announcement = await get_announcement_by_id(announcement_id)
    if not announcement:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Announcement not found"
        )
    return announcement

# ============ ADMIN ENDPOINTS (Require admin key) ============

@router.post("/")
async def create_new_announcement(
    announcement: AnnouncementCreate,
    admin_key: Optional[str] = Header(None)
):
    """Create a new announcement - Admin only (use admin-key header)"""
    
    # Check admin key
    if not admin_key or admin_key != ADMIN_SECRET:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing admin key"
        )
    
    new_announcement = await create_announcement(announcement)
    return new_announcement

@router.put("/{announcement_id}")
async def update_existing_announcement(
    announcement_id: str,
    announcement: AnnouncementUpdate,
    admin_key: Optional[str] = Header(None)
):
    """Update an announcement - Admin only (use admin-key header)"""
    
    if not admin_key or admin_key != ADMIN_SECRET:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing admin key"
        )
    
    updated = await update_announcement(announcement_id, announcement)
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Announcement not found"
        )
    return updated

@router.delete("/{announcement_id}")
async def delete_existing_announcement(
    announcement_id: str,
    admin_key: Optional[str] = Header(None)
):
    """Delete an announcement - Admin only (use admin-key header)"""
    
    if not admin_key or admin_key != ADMIN_SECRET:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing admin key"
        )
    
    deleted = await delete_announcement(announcement_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Announcement not found"
        )
    return {"message": "Announcement deleted successfully"}