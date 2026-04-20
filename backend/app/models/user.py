from beanie import Document
from pydantic import EmailStr
from datetime import datetime
from typing import Optional

class User(Document):
    # Authentication fields
    email: EmailStr
    hashed_password: str
    
    # Profile fields
    full_name: str = ""
    role: str = "student"
    student_id: str = ""      # NEW: student ID number
    phone: str = ""           # NEW: phone number
    department: str = ""      # NEW: department (CS, Engineering, etc.)
    bio: str = ""             # NEW: short bio/about me
    
    # System fields
    created_at: datetime = datetime.utcnow()
    updated_at: datetime = datetime.utcnow()  # NEW: track last profile update
    is_active: bool = True

    class Settings:
        name = "users"