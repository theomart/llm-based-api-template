from app.api import routes
from fastapi import APIRouter

from app.api.routes import login, users, utils

api_router = APIRouter()
api_router.include_router(routes.router, prefix="/items", tags=["items"])
