from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class AnnouncementOut(BaseModel):
    id: str
    title: str
    body: str
    image_url: str
    category: str
    is_pinned: bool
    created_at: datetime