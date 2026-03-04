from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    APP_NAME: str = "PM Hub"
    DATABASE_URL: str = "postgresql://pmhub:pmhub_secret@db:5432/pmhub"
    SECRET_KEY: str = "change-me-in-production-use-a-long-random-string"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 480
    ALGORITHM: str = "HS256"

    class Config:
        env_file = ".env"


settings = Settings()
