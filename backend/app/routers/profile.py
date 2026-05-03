from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status
from app.dependencies.auth import get_current_user
from app.models.user import User
from app.schemas.profile import ProfileResponse, ProfileUpdateRequest
from app.services.profile_service import get_user_profile, update_user_profile

router = APIRouter(prefix="/profile", tags=["Profile"])

@router.get("/me", response_model=ProfileResponse)
async def get_my_profile(current_user: User = Depends(get_current_user)):
    """Get current user's full profile"""
    return await get_user_profile(current_user)

@router.put("/me")
async def update_my_profile(
    update_data: ProfileUpdateRequest,
    current_user: User = Depends(get_current_user)
):
    """Update current user's profile"""
    updated_user = await update_user_profile(current_user, update_data)
    return {
        "message": "Profile updated successfully",
        "profile": await get_user_profile(updated_user)
    }

@router.delete("/me")
async def delete_my_account(
    current_user: User = Depends(get_current_user)
):
    """Soft delete account (deactivate instead of hard delete)"""
    current_user.is_active = False
    current_user.updated_at = datetime.utcnow()
    await current_user.save()
    return {"message": "Account deactivated successfully"}