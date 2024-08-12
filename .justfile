# Format the codebase using ruff
format:
    set -e
    set -x
    ruff check app scripts --fix
    ruff format app scripts

# Lint the codebase using mypy and ruff
lint:
    set -e
    set -x
    mypy app
    ruff check app
    ruff format app --check

# Run tests with coverage
test:
    set -e
    set -x
    coverage run --source=app -m pytest
    coverage report --show-missing
    coverage html --title "${@-coverage}"

# Combine linting and testing
lint-and-test: lint test
