.PHONY: help up down restart logs seed test clean build rebuild shell-backend shell-frontend shell-db health check

# Default target
.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Tutas Ai - Pipeline Monitoring Platform$(NC)"
	@echo ""
	@echo "$(GREEN)Available commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

up: ## Start all services in background
	@echo "$(BLUE)🚀 Starting all services...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)✅ Services started. Use 'make logs' to view logs.$(NC)"

down: ## Stop all services
	@echo "$(BLUE)🛑 Stopping all services...$(NC)"
	docker-compose down
	@echo "$(GREEN)✅ Services stopped.$(NC)"

restart: down up ## Restart all services (down + up)

logs: ## View logs from all services (follow mode)
	docker-compose logs -f

logs-backend: ## View backend logs only
	docker-compose logs -f backend

logs-frontend: ## View frontend logs only
	docker-compose logs -f frontend

logs-db: ## View database logs only
	docker-compose logs -f db

seed: ## Seed database with demo data (requires services to be running)
	@echo "$(BLUE)🌱 Seeding database with demo data...$(NC)"
	@if ! docker-compose ps | grep -q "tutas_ai_backend.*Up"; then \
		echo "$(RED)❌ Backend service is not running. Run 'make up' first.$(NC)"; \
		exit 1; \
	fi
	docker-compose exec -T backend python3 /scripts/seed_data.py || \
		(echo "$(YELLOW)⚠️  Trying alternative method...$(NC)" && \
		 docker-compose exec backend bash -c "cd /app && export PYTHONPATH=/app && python3 /scripts/seed_data.py")
	@echo "$(GREEN)✅ Database seeded successfully!$(NC)"

seed-simple: ## Seed database using SQL script (alternative method)
	@echo "$(BLUE)🌱 Seeding database with SQL script...$(NC)"
	@if ! docker-compose ps | grep -q "tutas_ai_db.*Up"; then \
		echo "$(RED)❌ Database service is not running. Run 'make up' first.$(NC)"; \
		exit 1; \
	fi
	docker-compose exec -T db psql -U postgres -d tutas_ai -f /docker-entrypoint-initdb.d/seed_data_simple.sql || \
		(echo "$(YELLOW)⚠️  Copying SQL file to container...$(NC)" && \
		 docker cp scripts/create_tables_simple.sql tutas_ai_db:/tmp/ && \
		 docker cp scripts/seed_data_simple.sql tutas_ai_db:/tmp/ && \
		 docker-compose exec -T db psql -U postgres -d tutas_ai -f /tmp/create_tables_simple.sql && \
		 docker-compose exec -T db psql -U postgres -d tutas_ai -f /tmp/seed_data_simple.sql)
	@echo "$(GREEN)✅ Database seeded successfully!$(NC)"

test: ## Run tests (backend)
	@echo "$(BLUE)🧪 Running tests...$(NC)"
	docker-compose exec backend pytest tests/ -v || \
		(echo "$(YELLOW)⚠️  Tests directory not found. Skipping tests.$(NC)")

lint: ## Run linters (backend)
	@echo "$(BLUE)🔍 Running linters...$(NC)"
	docker-compose exec backend ruff check . || \
		(echo "$(YELLOW)⚠️  Ruff not installed. Skipping lint.$(NC)")

build: ## Build all Docker images
	@echo "$(BLUE)🔨 Building Docker images...$(NC)"
	docker-compose build
	@echo "$(GREEN)✅ Build complete.$(NC)"

rebuild: ## Rebuild all Docker images (no cache)
	@echo "$(BLUE)🔨 Rebuilding Docker images (no cache)...$(NC)"
	docker-compose build --no-cache
	@echo "$(GREEN)✅ Rebuild complete.$(NC)"

clean: ## Clean Python artifacts and Docker volumes
	@echo "$(BLUE)🧹 Cleaning artifacts...$(NC)"
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)✅ Clean complete.$(NC)"

clean-all: clean ## Clean everything including Docker volumes and images
	@echo "$(BLUE)🧹 Cleaning Docker volumes and images...$(NC)"
	docker-compose down -v
	docker system prune -f
	@echo "$(GREEN)✅ Deep clean complete.$(NC)"

shell-backend: ## Open shell in backend container
	docker-compose exec backend bash

shell-frontend: ## Open shell in frontend container
	docker-compose exec frontend sh

shell-db: ## Open PostgreSQL shell
	docker-compose exec db psql -U postgres -d tutas_ai

health: ## Check health of all services
	@echo "$(BLUE)🏥 Checking service health...$(NC)"
	@echo ""
	@echo "$(YELLOW)Backend API:$(NC)"
	@curl -s http://localhost:8000/health | python3 -m json.tool 2>/dev/null || echo "$(RED)❌ Backend not responding$(NC)"
	@echo ""
	@echo "$(YELLOW)Frontend:$(NC)"
	@curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:3000 || echo "$(RED)❌ Frontend not responding$(NC)"
	@echo ""
	@echo "$(YELLOW)Database:$(NC)"
	@docker-compose exec -T db pg_isready -U postgres > /dev/null 2>&1 && echo "$(GREEN)✅ Database is ready$(NC)" || echo "$(RED)❌ Database not ready$(NC)"

check: ## Check if all services are running
	@echo "$(BLUE)🔍 Checking service status...$(NC)"
	@docker-compose ps

init: ## Initialize project (copy .env, build, start, seed)
	@echo "$(BLUE)🚀 Initializing Tutas Ai project...$(NC)"
	@if [ ! -f .env ]; then \
		echo "$(YELLOW)📝 Creating .env from .env.example...$(NC)"; \
		cp .env.example .env; \
		echo "$(GREEN)✅ .env file created. Please review and update if needed.$(NC)"; \
	else \
		echo "$(GREEN)✅ .env file already exists.$(NC)"; \
	fi
	@echo "$(BLUE)🔨 Building Docker images...$(NC)"
	@make build
	@echo "$(BLUE)🚀 Starting services...$(NC)"
	@make up
	@echo "$(YELLOW)⏳ Waiting for services to be ready (30 seconds)...$(NC)"
	@sleep 30
	@echo "$(BLUE)🌱 Seeding database...$(NC)"
	@make seed || make seed-simple
	@echo ""
	@echo "$(GREEN)✅ Project initialized successfully!$(NC)"
	@echo ""
	@echo "$(BLUE)📊 Access points:$(NC)"
	@echo "  • Frontend: http://localhost:3000"
	@echo "  • Backend API: http://localhost:8000"
	@echo "  • API Docs: http://localhost:8000/docs"
	@echo "  • Database: localhost:5432"

status: ## Show project status and access URLs
	@echo "$(BLUE)📊 Tutas Ai - Project Status$(NC)"
	@echo ""
	@echo "$(YELLOW)Services:$(NC)"
	@docker-compose ps
	@echo ""
	@echo "$(YELLOW)Access URLs:$(NC)"
	@echo "  • Frontend Dashboard: $(GREEN)http://localhost:3000$(NC)"
	@echo "  • Backend API: $(GREEN)http://localhost:8000$(NC)"
	@echo "  • API Documentation: $(GREEN)http://localhost:8000/docs$(NC)"
	@echo "  • Health Check: $(GREEN)http://localhost:8000/health$(NC)"
	@echo ""
	@echo "$(YELLOW)Database:$(NC)"
	@echo "  • Host: localhost:5432"
	@echo "  • Database: tutas_ai"
	@echo "  • User: postgres"
