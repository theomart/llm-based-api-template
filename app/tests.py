from collections.abc import Generator

import pytest
from fastapi.testclient import TestClient

from app.config import settings
from app.main import app


@pytest.fixture(scope="module")
def client() -> Generator[TestClient, None, None]:
    with TestClient(app) as c:
        yield c


def test_create_item(client: TestClient) -> None:
    data = {"words_to_use": ["hello", "world"]}
    response = client.post(
        f"{settings.API_V1_STR}/create_poem/",
        json=data,
    )
    assert response.status_code == 200
    content = response.json()
    assert content["poem"] == "hello world"
