from fastapi import APIRouter, HTTPException, status, Depends
from app.schemas.auth import LoginRequest, TokenResponse, RegisterRequest  # ← add RegisterRequest
from app.services.auth_service import login_user, register_user            # ← add register_user
from app.dependencies.auth import get_current_user

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest):
    result = await login_user(body.email, body.password)
    if not result:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password"
        )
    return result

@router.get("/me")
async def get_me(user=Depends(get_current_user)):
    return {
        "email": user.email,
        "full_name": user.full_name,
        "role": user.role
    }

@router.post("/logout")
async def logout(user=Depends(get_current_user)):
    return {"message": "Logged out successfully"}

@router.post("/register")
async def register(data: RegisterRequest):
    success = await register_user(data)   # ← use the service, don't rewrite logic here
    if not success:
        raise HTTPException(400, "Email already registered")
    return {"message": "Account created successfully"}