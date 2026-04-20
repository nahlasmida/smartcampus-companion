from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class AnnouncementCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    content: str = Field(..., min_length=1)
    author: str = "Admin"
    image_url: str = ""
    is_pinned: bool = False

class AnnouncementUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    content: Optional[str] = Field(None, min_length=1)
    author: Optional[str] = None
    image_url: Optional[str] = None
    is_pinned: Optional[bool] = None

class AnnouncementResponse(BaseModel):
    id: str
    title: str
    content: str
    author: str
    image_url: str
    created_at: datetime
    updated_at: datetime
    is_pinned: bool
    
    class Config:
        from_attributes = True