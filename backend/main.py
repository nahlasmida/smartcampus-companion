from fastapi import FastAPI
from contextlib import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
from app.core.database import init_db
from app.routers import auth, announcements, events, timetable, profile

@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    print("Database connected")
    yield
    print("Shutting down")

app = FastAPI(
    title="SmartCampus API",
    description="Backend for SmartCampus Companion mobile app",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include all routers
app.include_router(auth.router)
app.include_router(profile.router)
app.include_router(announcements.router)
app.include_router(events.router)
app.include_router(timetable.router)

@app.get("/")
async def root():
    return {"message": "SmartCampus API is running", "docs": "/docs"}