from app.models.user import User
from app.core.security import verify_password, create_access_token, hash_password
from app.schemas.auth import RegisterRequest
from datetime import datetime

async def login_user(email: str, password: str) -> dict | None:
    user = await User.find_one(User.email == email)
    if not user or not verify_password(password, user.hashed_password):
        return None
    
    access_token = create_access_token(data={"sub": user.email})
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_email": user.email,
        "user_name": user.full_name
    }

async def register_user(data: RegisterRequest) -> bool:
    existing = await User.find_one(User.email == data.email)
    if existing:
        return False
    
    user = User(
        email=data.email,
        hashed_password=hash_password(data.password),
        full_name=data.full_name,
        student_id=data.student_id,
        phone=data.phone,
        department=data.department,
        bio=data.bio,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    await user.insert()
    return True