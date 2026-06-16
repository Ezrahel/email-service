.PHONY: help setup dev test lint clean build docker-up docker-down db-prepare db-reset

.DEFAULT_GOAL := help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Full project setup
	@echo "==> Setting up project..."
	cp -n .env.example .env || true
	bundle install
	bundle exec rails db:prepare
	bundle exec rails db:seed
	@echo "==> Done! Run 'make dev' to start."

dev: ## Start development environment
	@echo "==> Starting dev server..."
	@foreman start -f Procfile.dev

docker-build: ## Build Docker images
	docker compose build

docker-up: ## Start all Docker services
	docker compose up -d --remove-orphans

docker-down: ## Stop all Docker services
	docker compose down

docker-logs: ## Tail Docker logs
	docker compose logs -f

db-prepare: ## Prepare database (create, migrate, seed)
	bundle exec rails db:create db:migrate db:seed

db-reset: ## Reset database
	bundle exec rails db:drop db:create db:migrate db:seed

db-migrate: ## Run migrations
	bundle exec rails db:migrate

test: ## Run all tests
	bundle exec rspec

test-coverage: ## Run tests with coverage
	COVERAGE=true bundle exec rspec

test-load: ## Run load tests
	@echo "==> Running load tests..."
	@bundle exec ruby lib/tasks/load_test.rb

lint: ## Run linters
	bundle exec rubocop -A

lint-check: ## Check linting without auto-fix
	bundle exec rubocop

console: ## Open Rails console
	bundle exec rails console

sidekiq: ## Start Sidekiq
	bundle exec sidekiq -C config/sidekiq.yml

ci: lint-check test ## Run CI pipeline

clean: ## Clean temporary files
	rm -rf tmp/*
	rm -rf log/*
	rm -rf coverage/
	rm -rf vendor/bundle

openapi: ## Generate OpenAPI spec
	bundle exec rails rswag:specs:swaggerize

seed: ## Seed database
	bundle exec rails db:seed

annotate: ## Annotate models
	bundle exec annotate
