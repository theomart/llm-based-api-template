from pydantic_settings import BaseSettings, SettingsConfigDict


# Settings class loads its variable from the environment variables and the .env file when specified
class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env", env_ignore_empty=True, extra="ignore"
    )
    api_v1_str: str = "/api/v1"
    project_name: str = "LLM based API"
    openai_api_key: str


# Ignoring type error cause it expects openai_api_key at instantiation while it is loaded from the environment variable
settings = Settings()  # type: ignore
