from pydantic import BaseModel, EmailStr, field_validator
import re
from datetime import datetime
class ProfileResponse(BaseModel):
    """What the client sees when viewing profile"""
    email: EmailStr
    full_name: str
    role: str
    student_id: str
    phone: str
    department: str
    bio: str
    created_at: datetime
    is_active: bool

class ProfileUpdateRequest(BaseModel):
    """What client can update"""
    full_name: str | None = None
    student_id: str | None = None
    phone: str | None = None
    department: str | None = None
    bio: str | None = None
    
    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str):
        if v and not re.match(r"^\+?[0-9]{10,15}$", v):
            raise ValueError("Phone must be 10-15 digits, optional + prefix")
        return v
    
    @field_validator("student_id")
    @classmethod
    def validate_student_id(cls, v: str):
        if v and not re.match(r"^[0-9]{6,10}$", v):
            raise ValueError("Student ID must be 6-10 digits")
        return v

# Import datetime at top
from datetime import datetime