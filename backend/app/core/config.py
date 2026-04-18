from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    MONGO_URI: str
    JWT_SECRET: str
    JWT_EXPIRE_MINUTES: int = 60

    class Config:
        env_file = ".env"

settings = Settings()