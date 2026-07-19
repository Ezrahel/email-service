# Email Service - Makefile
# Usage: make <target>

.PHONY: help install dev test test-coverage lint typecheck build db-migrate db-seed docker-up docker-down clean

# Default target
help:
	@echo "Email Service - Available commands:"
	@echo ""
	@echo "  install       - Install all dependencies"
	@echo "  dev           - Start development servers"
	@echo "  test          - Run all tests"
	@echo "  test-coverage - Run tests with coverage"
	@echo "  lint          - Run linter"
	@echo "  typecheck     - Run TypeScript type checking"
	@echo "  build         - Build all packages"
	@echo "  db-migrate    - Run database migrations"
	@echo "  db-seed       - Seed development database"
	@echo "  docker-up     - Start Docker infrastructure"
	@echo "  docker-down   - Stop Docker infrastructure"
	@echo "  clean         - Clean build artifacts"
	@echo ""

install:
	pnpm install

dev:
	pnpm dev

test:
	pnpm test

test-coverage:
	pnpm test:coverage

lint:
	pnpm lint

typecheck:
	pnpm typecheck

build:
	pnpm build

db-migrate:
	pnpm db:migrate

db-seed:
	pnpm db:seed

docker-up:
	pnpm docker:up

docker-down:
	pnpm docker:down

clean:
	rm -rf node_modules dist .turbo coverage .nyc_output
	find . -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.tsbuildinfo" -delete 2>/dev/null || true