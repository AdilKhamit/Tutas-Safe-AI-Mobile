# Backend Tests

Comprehensive test suite for QR code functionality.

## Test Files

- `test_qr_code_api.py` - API endpoint tests
- `test_qr_code_validation.py` - QR code format validation tests
- `conftest.py` - Pytest fixtures and configuration

## Running Tests

### Prerequisites

Install test dependencies:

```bash
cd backend
poetry install --with dev
# or
pip install pytest pytest-asyncio httpx
```

### Run All Tests

```bash
pytest tests/ -v
```

### Run Specific Test File

```bash
pytest tests/test_qr_code_api.py -v
pytest tests/test_qr_code_validation.py -v
```

### Run with Coverage

```bash
pytest tests/ --cov=app --cov-report=html
```

## Test Structure

### API Tests (`test_qr_code_api.py`)

Tests for:
- GET `/api/v1/pipes/qr/{qr_code}` - Retrieve pipe by QR code
- GET `/api/v1/pipes/qr-code/{qr_code}/image` - Generate QR code image
- GET `/api/v1/pipes/{pipe_id}/qr-code` - Get QR code image by pipe ID
- POST `/api/v1/pipes` - Create pipe with QR code

### Validation Tests (`test_qr_code_validation.py`)

Tests for:
- QR code format validation
- Company name extraction
- UUID extraction
- QR code structure parsing

## Test Database

Tests use an in-memory SQLite database that is created and destroyed for each test session. This ensures:
- Tests are isolated
- No database setup required
- Fast test execution

## Notes

- Tests require `pytest-asyncio` for async test support
- Tests use `httpx.AsyncClient` for API testing
- Database fixtures are automatically set up and torn down
