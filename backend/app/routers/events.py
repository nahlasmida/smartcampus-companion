from fastapi import APIRouter, HTTPException, status, Header
from typing import List, Optional
from app.schemas.event import EventCreate, EventUpdate
from app.services.event_service import (
    get_all_events,
    get_upcoming_events,
    get_event_by_id,
    create_event,
    update_event,
    delete_event
)

ADMIN_SECRET = "campus-admin-2024"

router = APIRouter(prefix="/events", tags=["Events"])

# ============ PUBLIC ENDPOINTS ============

@router.get("/")
async def list_events():
    """Get all events - Public endpoint"""
    events = await get_all_events()
    return events

@router.get("/upcoming")
async def list_upcoming_events():
    """Get only upcoming events - Public endpoint"""
    events = await get_upcoming_events()
    return events

@router.get("/{event_id}")
async def get_event(event_id: str):
    """Get a single event by ID - Public endpoint"""
    event = await get_event_by_id(event_id)
    if not event:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found"
        )
    return event

# ============ ADMIN ENDPOINTS ============

@router.post("/")
async def create_new_event(
    event: EventCreate,
    admin_key: Optional[str] = Header(None)
):
    """Create a new event - Admin only (use admin-key header)"""
    
    if not admin_key or admin_key != ADMIN_SECRET:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing admin key"
        )
    
    new_event = await create_event(event)
    return new_event

@router.put("/{event_id}")
async def update_existing_event(
    event_id: str,
    event: EventUpdate,
    admin_key: Optional[str] = Header(None)
):
    """Update an event - Admin only (use admin-key header)"""
    
    if not admin_key or admin_key != ADMIN_SECRET:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing admin key"
        )
    
    updated = await update_event(event_id, event)
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found"
        )
    return updated

@router.delete("/{event_id}")
async def delete_existing_event(
    event_id: str,
    admin_key: Optional[str] = Header(None)
):
    """Delete an event - Admin only (use admin-key header)"""
    
    if not admin_key or admin_key != ADMIN_SECRET:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing admin key"
        )
    
    deleted = await delete_event(event_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found"
        )
    return {"message": "Event deleted successfully"}