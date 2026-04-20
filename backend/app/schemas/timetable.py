from pydantic import BaseModel, Field, field_validator
from datetime import datetime
from typing import Optional

class TimetableCreate(BaseModel):
    course_name: str = Field(..., min_length=1, max_length=100)
    teacher: str = Field(..., min_length=1)
    day: str = Field(..., min_length=1)
    start_time: str = Field(..., pattern=r"^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$")  # Changed regex to pattern
    end_time: str = Field(..., pattern=r"^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$")    # Changed regex to pattern
    room: str = Field(..., min_length=1)
    color: str = "#4CAF50"
    
    @field_validator('end_time')
    @classmethod
    def end_time_after_start_time(cls, v, info):
        start_time = info.data.get('start_time')
        if start_time and v <= start_time:
            raise ValueError('end_time must be after start_time')
        return v
    
    @field_validator('day')
    @classmethod
    def valid_day(cls, v):
        valid_days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
        if v not in valid_days:
            raise ValueError(f'day must be one of {valid_days}')
        return v

class TimetableUpdate(BaseModel):
    course_name: Optional[str] = Field(None, min_length=1, max_length=100)
    teacher: Optional[str] = None
    day: Optional[str] = None
    start_time: Optional[str] = Field(None, pattern=r"^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$")  # Changed
    end_time: Optional[str] = Field(None, pattern=r"^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$")    # Changed
    room: Optional[str] = None
    color: Optional[str] = None
    
    @field_validator('day')
    @classmethod
    def valid_day(cls, v):
        if v:
            valid_days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
            if v not in valid_days:
                raise ValueError(f'day must be one of {valid_days}')
        return v

class TimetableResponse(BaseModel):
    id: str
    course_name: str
    teacher: str
    day: str
    start_time: str
    end_time: str
    room: str
    color: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True