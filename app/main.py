import logging
from typing import Any

from fastapi import APIRouter, FastAPI
from pydantic import BaseModel

from app.config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
)

router = APIRouter()


class PoemPrompt(BaseModel):
    words_to_use: list[str] = ["hello", "world"]


class CreatePoemResponse(BaseModel):
    poem: str


@router.post("/create_poem", response_model=CreatePoemResponse)
def create_item(*, poem_prompt: PoemPrompt) -> Any:
    """
    Create new item.
    """

    return {"poem": "hello world"}


app.include_router(router, prefix=settings.API_V1_STR)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
