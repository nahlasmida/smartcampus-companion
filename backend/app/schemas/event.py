from pydantic import BaseModel
from datetime import datetime
from typing import List

class EventOut(BaseModel):
    id: str
    title: str
    description: str
    location: str
    start_time: datetime
    end_time: datetime
    image_url: str
    tags: List[str]