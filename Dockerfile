FROM tiangolo/uvicorn-gunicorn-fastapi:python3.10

WORKDIR /app

# Install poetry
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/opt/poetry python && \ 
    ln -s /opt/poetry/bin/poetry /usr/local/bin/poetry && \
    poetry config virtualenvs.create false

# Copy project files and install dependencies
COPY ./pyproject.toml ./poetry.lock* /app/
RUN poetry install --no-root

# Copy application code
COPY ./app /app/app
