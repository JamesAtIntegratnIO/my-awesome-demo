# my-awesome-demo Development Makefile
.PHONY: help dev build test clean deploy   score-generate score-up score-down score-restart score-build score-logs

# Default target
.DEFAULT_GOAL := help

# Project Configuration
PROJECT_NAME=my-awesome-demo

# Score.dev Configuration
SCORE_BACKEND=score-backend.yaml
SCORE_FRONTEND=score-frontend.yaml

# Check if we're in Nix environment
define check_nix_env
	@if [ -z "$$IN_NIX_SHELL" ] && [ -z "$$NIX_PATH" ]; then \
		echo "⚠️  Not in Nix environment. Entering nix develop..."; \
		if command -v nix >/dev/null 2>&1; then \
			nix develop --command make $(1); \
		else \
			echo "❌ Nix is not installed or not in PATH"; \
			echo "   Please install Nix or run the command manually"; \
			exit 1; \
		fi; \
	else \
		echo "✅ Already in Nix environment or Nix available"; \
		make $(1); \
	fi
endef

help: ## Show this help message
	@echo "🚀 my-awesome-demo Development Commands"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "💡 Most commands auto-detect Nix environment and will run 'nix develop' if needed"
	@echo ""
	@echo "📦 Score.dev Commands (Recommended):"
	@echo "  score-up       Start full-stack app using Score.dev + Docker Compose"
	@echo "  score-down     Stop Score.dev services"
	@echo "  score-restart  Restart Score.dev services"
	@echo "  score-generate Generate compose.yaml from Score files"
	@echo ""
	@echo "🔧 Development Commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

check-nix: ## Check if we're in a Nix environment
	@if [ -n "$$IN_NIX_SHELL" ]; then \
		echo "✅ In Nix shell environment"; \
	elif [ -n "$$NIX_PATH" ]; then \
		echo "✅ Nix is available in PATH"; \
	else \
		echo "❌ Nix environment not detected"; \
		echo "   Run 'nix develop' first or use 'make dev' to enter Nix environment"; \
	fi

nix-shell: ## Enter Nix development environment
	@echo "🐚 Entering Nix development environment..."
	@nix develop

# Development targets
dev: ## Start development environment
	@$(call check_nix_env,dev-inner)

dev-inner:
	@echo "🔧 Starting development environment..."
	@echo "📦 Installing Go dependencies..."
	go mod download
	@echo "🚀 Starting development server..."
	go run cmd/main.go

# Build targets
build: ## Build the application
	@$(call check_nix_env,build-inner)

build-inner:
	@echo "🏗️  Building application..."
	@echo "🏗️  Building Go binary..."
	go build -o bin/my-awesome-demo cmd/main.go

# Test targets
test: ## Run tests
	@$(call check_nix_env,test-inner)

test-inner:
	@echo "🧪 Running tests..."
	go test -v ./...

# Clean target
clean: ## Clean build artifacts
	@echo "🧹 Cleaning build artifacts..."
	rm -rf bin/
	go clean

# Score.dev Commands (Recommended)
score-build: ## Build Docker images for Score.dev
	@echo "🐳 Building Docker images for Score.dev..."
	@docker build -t my-awesome-demo/backend:latest .
	@echo "✅ Docker images built successfully"

score-generate: ## Generate compose.yaml from Score files
	@echo "📋 Generating compose.yaml from Score files..."
	@score-compose init --no-sample || true
	@score-compose generate $(SCORE_BACKEND) --publish 8080:8080
	@echo "✅ Generated compose.yaml from Score files"

score-up: ## Start full-stack app using Score.dev + Docker Compose
	@echo "🚀 Starting my-awesome-demo with Score.dev..."
	@make score-build
	@make score-generate
	@docker compose up -d
	@echo ""
	@echo "✅ my-awesome-demo is running!"
	@echo "🔧 Backend:  http://localhost:8080"
	@echo "📊 Health:   http://localhost:8080/health"

score-down: ## Stop Score.dev services
	@echo "🛑 Stopping Score.dev services..."
	@docker compose down
	@echo "✅ Services stopped"

score-restart: ## Restart Score.dev services
	@echo "🔄 Restarting Score.dev services..."
	@make score-down
	@make score-up

score-logs: ## View logs from Score.dev services
	@echo "📋 Viewing service logs..."
	@docker compose logs -f

# Legacy Score.dev targets (deprecated)
score-generate-legacy: ## Generate deployment manifests using Score (deprecated)
	@echo "📊 Generating deployment manifests..."
	@if [ -f "score.yaml" ]; then \
		echo "🎯 Generating Docker Compose from score.yaml..."; \
		score-compose generate score.yaml; \
		echo "🎯 Generating Kubernetes from score.yaml..."; \
		score-k8s generate score.yaml; \
	fi
	@if [ -f "score-backend.yaml" ]; then \
		echo "🎯 Generating Docker Compose from score-backend.yaml..."; \
		score-compose generate score-backend.yaml; \
		echo "🎯 Generating Kubernetes from score-backend.yaml..."; \
		score-k8s generate score-backend.yaml; \
	fi
	@if [ -f "score-frontend.yaml" ]; then \
		echo "🎯 Generating Docker Compose from score-frontend.yaml..."; \
		score-compose generate score-frontend.yaml; \
		echo "🎯 Generating Kubernetes from score-frontend.yaml..."; \
		score-k8s generate score-frontend.yaml; \
	fi
	@echo "✅ Deployment manifests generated"

# Docker targets (legacy)
docker-build: ## Build Docker images (legacy)
	@echo "🐳 Building Docker images..."
	docker build -t my-awesome-demo:latest .
	@echo "✅ Docker images built"

docker-up: ## Start application with Docker Compose (legacy)
	@echo "🐳 Starting application with Docker Compose..."
	@$(MAKE) score-generate-legacy
	docker-compose up -d
	@echo "✅ Application started"

docker-down: ## Stop Docker Compose (legacy)
	@echo "🐳 Stopping Docker Compose..."
	docker-compose down
	@echo "✅ Application stopped"

# Deploy target
deploy: ## Deploy application
	@echo "🚀 Deploying application..."
	@$(MAKE) build
	@$(MAKE) score-generate
	@echo "✅ Application deployed"
