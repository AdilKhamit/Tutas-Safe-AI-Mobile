# Contributing to Tutas AI Platform

Thank you for your interest in contributing to Tutas AI Platform! This document provides guidelines and instructions for contributing.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)

---

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect different viewpoints and experiences

### Reporting Issues

If you experience or witness unacceptable behavior, please report it to the project maintainers.

---

## Getting Started

### Prerequisites

- Docker & Docker Compose 2.0+
- Python 3.11+ (for backend)
- Node.js 18+ (for frontend)
- Flutter 3.0+ (for mobile)
- Git

### Initial Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd "Tutas Ai"
   ```

2. **Set up environment**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start services**
   ```bash
   make build
   make up
   make seed
   ```

4. **Verify installation**
   ```bash
   make health
   ```

---

## Development Workflow

### Branch Strategy

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - Feature branches
- `bugfix/*` - Bug fix branches
- `hotfix/*` - Critical production fixes

### Creating a Branch

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Or bugfix branch
git checkout -b bugfix/issue-description
```

### Commit Messages

Follow conventional commit format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(backend): add user authentication endpoint

fix(mobile): resolve QR scanner crash on iOS

docs(readme): update installation instructions
```

---

## Coding Standards

### Backend (Python)

- Follow PEP 8 style guide
- Use type hints
- Maximum line length: 100 characters
- Use async/await for I/O operations
- Write docstrings for all functions and classes

**Tools:**
```bash
# Format code
black app/

# Sort imports
isort app/

# Type check
mypy app/

# Lint
pylint app/
```

### Frontend (TypeScript/React)

- Follow ESLint rules
- Use TypeScript for type safety
- Use functional components with hooks
- Follow React best practices
- Maximum line length: 100 characters

**Tools:**
```bash
# Format code
npm run format

# Lint
npm run lint

# Type check
npm run type-check
```

### Mobile (Dart/Flutter)

- Follow Dart style guide
- Use meaningful variable names
- Keep widgets small and focused
- Use const constructors where possible
- Follow Flutter best practices

**Tools:**
```bash
# Format code
dart format lib/

# Analyze
flutter analyze
```

---

## Testing

### Backend Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test
pytest tests/test_pipes.py
```

**Coverage Target:** Minimum 60% code coverage

### Frontend Tests

```bash
# Run tests
npm test

# Run with coverage
npm test -- --coverage
```

**Coverage Target:** Minimum 40% code coverage

### Mobile Tests

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget/

# Run integration tests
flutter test integration_test/
```

**Coverage Target:** Minimum 70% code coverage

---

## Documentation

### Code Documentation

- Write clear docstrings for all public functions and classes
- Add comments for complex logic
- Keep comments up-to-date with code changes

### API Documentation

- Update OpenAPI/Swagger documentation for API changes
- Include request/response examples
- Document error codes and responses

### README Files

- Keep README files up-to-date
- Include setup instructions
- Document configuration options
- Add troubleshooting sections

---

## Submitting Changes

### Pull Request Process

1. **Update your branch**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout feature/your-feature
   git rebase develop
   ```

2. **Run tests and checks**
   ```bash
   # Backend
   pytest
   black --check app/
   mypy app/

   # Frontend
   npm test
   npm run lint

   # Mobile
   flutter test
   flutter analyze
   ```

3. **Create Pull Request**
   - Use clear, descriptive title
   - Provide detailed description
   - Link related issues
   - Include screenshots for UI changes

4. **Review Process**
   - Address review comments
   - Keep PR focused and small
   - Update documentation as needed

### PR Checklist

- [ ] Code follows style guidelines
- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] Commit messages follow convention
- [ ] PR description is clear and complete

---

## Project-Specific Guidelines

### Backend

- Use async SQLAlchemy for database operations
- Validate input with Pydantic schemas
- Handle errors gracefully with proper HTTP status codes
- Use dependency injection for services

### Frontend

- Use Redux Toolkit for state management
- Use RTK Query for API calls
- Keep components small and reusable
- Use TypeScript for type safety

### Mobile

- Follow offline-first architecture
- Use Riverpod for state management
- Handle network errors gracefully
- Test on both Android and iOS

---

## Getting Help

- Check existing documentation
- Review closed issues and PRs
- Ask questions in discussions
- Contact maintainers for urgent issues

---

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (Proprietary).

---

Thank you for contributing to Tutas AI Platform! 🚀
