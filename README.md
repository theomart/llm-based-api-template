# 🐣 LLM-based API Template

This is a template for building and deploying a scalable API powered by Large Language Models (LLMs). It uses **[FastAPI](https://github.com/tiangolo/fastapi)** for the backend API, **[Docker](https://github.com/docker)** for containerization, **[Google Cloud Run](https://github.com/GoogleCloudPlatform/cloud-run-samples)** for deployment, **[Terraform](https://github.com/hashicorp/terraform)** for infrastructure as code, **[GitHub Actions](https://github.com/features/actions)** for CI/CD pipeline and **[litellm](https://github.com/BerriAI/litellm)** for interacting with the LLM.

As for development, it uses **[pytest](https://github.com/pytest-dev/pytest)** for testing, **[ruff](https://github.com/astral-sh/ruff)** for linting, **[pre-commit](https://github.com/pre-commit/pre-commit)** for pre-commit hooks and **[just](https://github.com/casey/just)** (alternative to make) for running tasks.

> **Example use cases:**
> - A simple question-answering system
> - A content generation API
> - A text summarization service


### How to use locally

- Clone the repository and set up your environment variables.
    ```bash
    git clone https://github.com/theomart/llm-api-template.git
    cd llm-api-template
    cp .env.example .env
    ```
- Run the application using Docker Compose:
    ```bash
    docker-compose up --build
    ```
- Access the API at `http://localhost:8000/docs` to test endpoints.
- Send requests to the API using curl or any other HTTP client:
    ```bash
    curl -X POST "http://localhost:8000/api/v1/completion" \
         -H "Content-Type: application/json" \
         -d '{"prompt": "Tell me a joke."}'
    ```

### How to deploy on Google Cloud Run

- Search and replace the `TO_REPLACE` in the `main.tf` and the `deploy.yml` files
- Create a new repository on GitHub and push your code to it
- Create the necessary resources on GCP by running the following command:
    ```bash
    terraform init
    terraform apply -var="project=PROJECT_ID" -var="region=REGION" -var="github_repo=GITHUB_REPO"
    ```
    The command will output the Workload Identity Provider and the Service Account email, which you need to add to your Github repository secrets.
- Add the following secrets to the repository:
    - `GCP_PROJECT_ID`
    - `GCP_REGION`
    - `GCP_SERVICE_ACCOUNT_KEY`
- The workflow will automatically deploy the application to Google Cloud Run

> **Attention:** Be careful not to expose your API to the internet without proper authorization and authentication. Ensure that your API is only accessible to authorized users and services.


### Example: Building a Summarization API

Here's a quick example of how you might extend this template to create a text summarization API:

1. Add a new endpoint and models in `app/main.py`:
   ```python
   class SummarizationRequest(BaseModel):
       text: str = Field(..., description="The text to summarize")

   class SummarizationResponse(BaseModel):
       summary: str = Field(..., description="The generated summary")

   @router.post("/summarize", response_model=SummarizationResponse)
   async def summarize_text(request: SummarizationRequest):
       summary = await get_llm_completion(f"Summarize the following text: {request.text}")
       return SummarizationResponse(summary=summary)
   ```

2. Use the API:
   ```bash
   curl -X POST "http://localhost:8000/api/v1/summarize" \
        -H "Content-Type: application/json" \
        -d '{"text": "Your long text to summarize goes here..."}'
   ```

This template provides a solid foundation for building LLM-powered APIs, allowing you to focus on implementing your specific use case while handling the infrastructure and deployment complexities.


### File structure

```python
├── Dockerfile
├── LICENSE
├── README.md
├── .env # Contains the environment variables for the application, it is used to store the sensitive information such as the API keys and the database connection string
├── .gitignore
├── .justfile # Contains the tasks for the application, it is used to run the tasks such as linting, testing, formatting, etc. replaces make
├── app
│   ├── __init__.py
│   ├── config.py # Contains all the configurable parameters for the application
│   ├── main.py # Contains all the API routes and their handlers
│   ├── services
│   │   └── llm_service.py # Contains the business logic for interacting with the LLM
│   └── tests.py # Contains the tests for the application
├── docker-compose.yml 
├── main.tf # Contains the infrastructure as code, which is used to create the required resources on Google Cloud, e.g. the IAM resources used by the Github Actions workflow to deploy the application
├── pyproject.toml # Contains the project metadata and the dependencies
└── service.template.yml # Contains the template for the Google Cloud Run service, which is used to create the service on Google Cloud, used to parametrize the permissions of the application, the network configuration, the service account used by the app etc.
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
