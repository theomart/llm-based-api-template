import logging
from collections.abc import Generator
import os
from unittest.mock import Mock, patch

import pytest
from fastapi.testclient import TestClient

# Set openai_api_key to a dummy key
os.environ["OPENAI_API_KEY"] = "test"

from app.config import settings
from app.main import app

# Create a logger and configure it so it shows logger.info logs
logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)


@pytest.fixture(scope="module")
def client() -> Generator[TestClient, None, None]:
    with TestClient(app) as c:
        yield c


@patch("litellm.completion")  # Mock the litellm.completion function
def test_get_completion(mock_completion: Mock, client: TestClient) -> None:
    # Define the mock return value with positional arguments in mind
    mock_completion.return_value = Mock(
        choices=[Mock(message=Mock(content="Mocked response"))]
    )

    response = client.post(
        f"{settings.api_v1_str}/completion",
        json={"prompt": "Hello, world!"},
    )

    logger.info(f"Response content: {response.json()}")
    assert response.status_code == 200
    content = response.json()
    assert (
        content["completion"] == "Mocked response"
    )  # Check against the mocked response
