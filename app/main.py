import logging

from fastapi import APIRouter, FastAPI
from pydantic import BaseModel, Field

from app.config import settings
from app.services.llm_service import get_llm_completion

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title=settings.project_name,
    description="LLM based API",
    version="0.1.0",
    openapi_url=f"{settings.api_v1_str}/openapi.json",
)

router = APIRouter()


class CompletionRequest(BaseModel):
    prompt: str = Field(..., description="The prompt to generate a completion for")


class CompletionResponse(BaseModel):
    completion: str = Field(
        ..., description="The generated completion text from the LLM"
    )


@router.post(
    "/completion",
    response_model=CompletionResponse,
    summary="Get completion from the LLM",
    description="Generate a completion based on the provided prompt",
    tags=["LLM"],
)
async def completion(request: CompletionRequest) -> CompletionResponse:
    completion_text = await get_llm_completion(request.prompt)
    return CompletionResponse(completion=completion_text)


app.include_router(router, prefix=settings.api_v1_str)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
