from fastapi import APIRouter, HTTPException, status, Header
from fastapi.responses import Response
from typing import List, Optional
from datetime import datetime

from app.schemas.timetable import TimetableCreate, TimetableUpdate
from app.services.timetable_service import (
    get_all_timetable,
    get_timetable_by_day,
    get_timetable_by_id,
    create_timetable_entry,
    update_timetable_entry,
    delete_timetable_entry,
    get_current_class
)
from app.services.export_service import generate_json_export, generate_pdf_export

ADMIN_SECRET = "campus-admin-2024"

router = APIRouter(prefix="/timetable", tags=["Timetable"])

# ============ PUBLIC ENDPOINTS ============

@router.get("/")
async def list_timetable():
    """Get all timetable entries - Public endpoint"""
    entries = await get_all_timetable()
    return entries

@router.get("/day/{day}")
async def list_timetable_by_day(day: str):
    """Get timetable for a specific day - Public endpoint"""
    entries = await get_timetable_by_day(day)
    return entries

@router.get("/current")
async def current_class():
    """Get the class currently happening - Public endpoint"""
    entry = await get_current_class()
    if not entry:
        return {"message": "No class currently in session"}
    return entry

@router.get("/{entry_id}")
async def get_timetable_entry(entry_id: str):
    """Get a single timetable entry by ID - Public endpoint"""
    entry = await get_timetable_by_id(entry_id)
    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Timetable entry not found"
        )
    return entry

# ============ EXPORT ENDPOINTS ============

@router.get("/export/json")
async def export_timetable_json():
    """Export timetable as JSON file - Public endpoint"""
    entries = await get_all_timetable()
    
    json_data = await generate_json_export(entries)
    
    return Response(
        content=json_data,
        media_type="application/json",
        headers={
            "Content-Disposition": f"attachment; filename=timetable_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        }
    )

@router.get("/export/pdf")
async def export_timetable_pdf():
    """Export timetable as PDF file - Public endpoint"""
    entries = await get_all_timetable()
    
    pdf_bytes = await generate_pdf_export(entries)
    
    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={
            "Content-Disposition": f"attachment; filename=timetable_{datetime.now().strftime('%Y%m%d_%H%M%S')}.pdf"
        }
    )

# ============ ADMIN ENDPOINTS ============

@router.post("/")
async def create_new_timetable_entry(
    entry: TimetableCreate,
    admin_key: Optional[str] = Header(None)
):
    """Create a new timetable entry - Admin only (use admin-key header)"""
    
    if not admin_key or admin_key != ADMIN_SECRET:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing admin key"
        )
    
    new_entry = await create_timetable_entry(entry)
    return new_entry

@router.put("/{entry_id}")
async def update_existing_timetable_entry(
    entry_id: str,
    entry: TimetableUpdate,
    admin_key: Optional[str] = Header(None)
):
    """Update a timetable entry - Admin only (use admin-key header)"""
    
    if not admin_key or admin_key != ADMIN_SECRET:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing admin key"
        )
    
    updated = await update_timetable_entry(entry_id, entry)
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Timetable entry not found"
        )
    return updated

@router.delete("/{entry_id}")
async def delete_existing_timetable_entry(
    entry_id: str,
    admin_key: Optional[str] = Header(None)
):
    """Delete a timetable entry - Admin only (use admin-key header)"""
    
    if not admin_key or admin_key != ADMIN_SECRET:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing admin key"
        )
    
    deleted = await delete_timetable_entry(entry_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Timetable entry not found"
        )
    return {"message": "Timetable entry deleted successfully"}