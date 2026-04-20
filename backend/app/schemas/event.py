from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class EventCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    description: str = Field(..., min_length=1)
    location: str = Field(..., min_length=1)
    start_time: datetime
    end_time: datetime
    organizer: str = "Student Union"
    image_url: str = ""

class EventUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = None
    location: Optional[str] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    organizer: Optional[str] = None
    image_url: Optional[str] = None

class EventResponse(BaseModel):
    id: str
    title: str
    description: str
    location: str
    start_time: datetime
    end_time: datetime
    organizer: str
    image_url: str
    created_at: datetime
    updated_at: datetime