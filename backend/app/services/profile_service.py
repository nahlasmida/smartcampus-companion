from app.models.user import User
from app.schemas.profile import ProfileUpdateRequest
from datetime import datetime

async def get_user_profile(user: User) -> dict:
    """Get full profile data for current user"""
    return {
        "email": user.email,
        "full_name": user.full_name,
        "role": user.role,
        "student_id": user.student_id,
        "phone": user.phone,
        "department": user.department,
        "bio": user.bio,
        "created_at": user.created_at,
        "is_active": user.is_active
    }

async def update_user_profile(user: User, update_data: ProfileUpdateRequest) -> User:
    """Update user profile fields"""
    
    if update_data.full_name is not None:
        user.full_name = update_data.full_name
    if update_data.student_id is not None:
        user.student_id = update_data.student_id
    if update_data.phone is not None:
        user.phone = update_data.phone
    if update_data.department is not None:
        user.department = update_data.department
    if update_data.bio is not None:
        user.bio = update_data.bio
    
    user.updated_at = datetime.utcnow()
    await user.save()
    return user