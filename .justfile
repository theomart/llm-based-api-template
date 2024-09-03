# Format the codebase using ruff
format:
    set -e
    set -x
    ruff check app --fix
    ruff format app

# Lint the codebase using mypy and ruff
lint:
    set -e
    set -x
    mypy app
    ruff check app --fix
    ruff format app --check

# Run tests with coverage
test:
    set -e
    set -x
    cd app
    poetry run pytest app/tests.py

# Combine linting and testing
lint-and-test: lint test
