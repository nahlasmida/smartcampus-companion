from pydantic import BaseModel, EmailStr, field_validator
import re

class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    
    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str):
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must contain an uppercase letter")
        if not re.search(r"[0-9]", v):
            raise ValueError("Password must contain a number")
        return v

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_email: str
    user_name: str

class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    # NEW profile fields (optional during registration)
    student_id: str = ""
    phone: str = ""
    department: str = ""
    bio: str = ""
    
    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str):
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must contain an uppercase letter")
        if not re.search(r"[0-9]", v):
            raise ValueError("Password must contain a number")
        if not re.search(r"[!@#$%^&*]", v):
            raise ValueError("Password must contain a special character (!@#$%^&*)")
        return v
    
    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str):
        if v and not re.match(r"^\+?[0-9]{10,15}$", v):
            raise ValueError("Phone must be 10-15 digits, optional + prefix")
        return v