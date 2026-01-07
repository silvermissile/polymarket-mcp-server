# Polymarket MCP Server - Makefile
# Convenient commands for Docker operations and UV management

.PHONY: help build up down restart logs shell test clean uv-install uv-sync uv-test uv-run verify

# Default target
.DEFAULT_GOAL := help

# Variables
DOCKER_COMPOSE := docker compose
SERVICE_NAME := polymarket-mcp
IMAGE_NAME := polymarket-mcp
VERSION := 0.1.0

## help: Show this help message
help:
	@echo "Polymarket MCP Server - Docker Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk '/^##/ {desc = substr($$0, 4); getline; printf "  \033[36m%-15s\033[0m %s\n", $$1, desc}' $(MAKEFILE_LIST)

## build: Build Docker image
build:
	@echo "Building Docker image..."
	$(DOCKER_COMPOSE) build

## up: Start services
up:
	@echo "Starting services..."
	$(DOCKER_COMPOSE) up -d

## down: Stop services
down:
	@echo "Stopping services..."
	$(DOCKER_COMPOSE) down

## restart: Restart services
restart:
	@echo "Restarting services..."
	$(DOCKER_COMPOSE) restart

## logs: View logs (follow mode)
logs:
	$(DOCKER_COMPOSE) logs -f

## logs-tail: View last 50 lines of logs
logs-tail:
	$(DOCKER_COMPOSE) logs --tail=50

## shell: Open shell in container
shell:
	$(DOCKER_COMPOSE) exec $(SERVICE_NAME) /bin/bash

## ps: Show running containers
ps:
	$(DOCKER_COMPOSE) ps

## stats: Show resource usage
stats:
	docker stats $(SERVICE_NAME) --no-stream

## test: Run Docker infrastructure tests
test:
	./test-docker.sh

## clean: Remove containers and volumes
clean:
	@echo "Cleaning up..."
	$(DOCKER_COMPOSE) down -v
	docker rmi $(IMAGE_NAME):latest || true

## clean-all: Remove everything including images
clean-all: clean
	docker system prune -af

## start: Quick start with environment check
start:
	./docker-start.sh

## build-multi: Build multi-architecture image
build-multi:
	docker buildx build --platform linux/amd64,linux/arm64 \
		-t $(IMAGE_NAME):$(VERSION) \
		-t $(IMAGE_NAME):latest .

## push: Push image to registry (set REGISTRY variable)
push:
	@if [ -z "$(REGISTRY)" ]; then \
		echo "Error: REGISTRY not set. Use: make push REGISTRY=your-registry/polymarket-mcp"; \
		exit 1; \
	fi
	docker tag $(IMAGE_NAME):latest $(REGISTRY):latest
	docker tag $(IMAGE_NAME):latest $(REGISTRY):$(VERSION)
	docker push $(REGISTRY):latest
	docker push $(REGISTRY):$(VERSION)

## deploy-k8s: Deploy to Kubernetes
deploy-k8s:
	@echo "Deploying to Kubernetes..."
	kubectl apply -f k8s/configmap.yaml
	kubectl apply -f k8s/deployment.yaml
	kubectl apply -f k8s/service.yaml

## undeploy-k8s: Remove from Kubernetes
undeploy-k8s:
	kubectl delete -f k8s/

## validate: Validate configuration files
validate:
	@echo "Validating docker-compose.yml..."
	$(DOCKER_COMPOSE) config > /dev/null
	@echo "✓ docker-compose.yml is valid"
	@if command -v kubectl > /dev/null; then \
		echo "Validating Kubernetes manifests..."; \
		kubectl apply --dry-run=client -f k8s/ > /dev/null; \
		echo "✓ Kubernetes manifests are valid"; \
	fi

## env: Create .env from template
env:
	@if [ -f .env ]; then \
		echo ".env already exists"; \
	else \
		cp .env.example .env; \
		echo "Created .env from template. Please edit with your credentials."; \
	fi

## health: Check container health
health:
	@docker inspect --format='{{.State.Health.Status}}' $(SERVICE_NAME) 2>/dev/null || echo "Container not running"

## update: Pull latest code and rebuild
update:
	@echo "Updating..."
	git pull
	$(DOCKER_COMPOSE) build
	$(DOCKER_COMPOSE) up -d

## backup: Backup volumes
backup:
	@echo "Backing up volumes..."
	docker run --rm -v polymarket-mcp_polymarket-data:/data -v $(PWD)/backups:/backup alpine tar czf /backup/data-backup-$$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
	@echo "Backup complete"

## restore: Restore volumes from latest backup
restore:
	@if [ ! -d backups ] || [ -z "$$(ls -A backups)" ]; then \
		echo "No backups found"; \
		exit 1; \
	fi
	@LATEST=$$(ls -t backups/*.tar.gz | head -1); \
	echo "Restoring from $$LATEST..."; \
	docker run --rm -v polymarket-mcp_polymarket-data:/data -v $(PWD)/backups:/backup alpine tar xzf /backup/$$(basename $$LATEST) -C /data
	@echo "Restore complete"

# ============================================================================
# UV 依赖管理命令 (Python 3.14)
# ============================================================================

## uv-install: 安装 UV 包管理器
uv-install:
	@echo "安装 UV..."
	curl -LsSf https://astral.sh/uv/install.sh | sh

## uv-sync: 同步并安装所有依赖
uv-sync:
	@echo "同步依赖（Python 3.14）..."
	uv sync --all-extras

## uv-update: 更新所有依赖到最新版本
uv-update:
	@echo "更新依赖..."
	uv lock --upgrade
	uv sync

## uv-add: 添加新依赖 (用法: make uv-add PACKAGE=package-name)
uv-add:
	@if [ -z "$(PACKAGE)" ]; then \
		echo "错误: 请指定包名. 用法: make uv-add PACKAGE=package-name"; \
		exit 1; \
	fi
	uv add $(PACKAGE)

## uv-add-dev: 添加开发依赖 (用法: make uv-add-dev PACKAGE=package-name)
uv-add-dev:
	@if [ -z "$(PACKAGE)" ]; then \
		echo "错误: 请指定包名. 用法: make uv-add-dev PACKAGE=package-name"; \
		exit 1; \
	fi
	uv add --dev $(PACKAGE)

## uv-remove: 移除依赖 (用法: make uv-remove PACKAGE=package-name)
uv-remove:
	@if [ -z "$(PACKAGE)" ]; then \
		echo "错误: 请指定包名. 用法: make uv-remove PACKAGE=package-name"; \
		exit 1; \
	fi
	uv remove $(PACKAGE)

## uv-run: 运行 MCP 服务器
uv-run:
	@echo "启动 Polymarket MCP 服务器..."
	uv run polymarket-mcp

## uv-web: 启动 Web 仪表板
uv-web:
	@echo "启动 Web 仪表板..."
	uv run polymarket-web

## uv-test: 运行测试套件
uv-test:
	@echo "运行测试..."
	uv run pytest tests/ -v

## uv-test-cov: 运行测试并生成覆盖率报告
uv-test-cov:
	@echo "运行测试（含覆盖率）..."
	uv run pytest tests/ -v --cov=polymarket_mcp --cov-report=html
	@echo "覆盖率报告: htmlcov/index.html"

## uv-format: 格式化代码
uv-format:
	@echo "格式化代码..."
	uv run black src/ tests/
	uv run isort src/ tests/

## uv-lint: 代码检查
uv-lint:
	@echo "代码检查..."
	uv run ruff check src/ tests/
	uv run mypy src/

## uv-lint-fix: 自动修复代码问题
uv-lint-fix:
	@echo "自动修复代码问题..."
	uv run ruff check --fix src/ tests/

## verify: 验证项目配置
verify:
	@echo "验证项目配置..."
	uv run python verify_setup.py

## uv-clean: 清理虚拟环境和缓存
uv-clean:
	@echo "清理虚拟环境和缓存..."
	rm -rf .venv
	uv cache clean

## uv-reinstall: 重新安装所有依赖
uv-reinstall: uv-clean
	@echo "重新安装依赖..."
	uv sync --all-extras

## uv-shell: 进入虚拟环境 shell
uv-shell:
	@echo "进入虚拟环境..."
	@bash -c "source .venv/bin/activate && exec bash"

## uv-python: 显示 Python 版本信息
uv-python:
	@echo "Python 版本信息:"
	uv run python --version
	@echo ""
	@echo "可用的 Python 版本:"
	uv python list

## uv-list: 显示已安装的包
uv-list:
	@echo "已安装的包:"
	uv pip list

## demo: 运行演示脚本
demo:
	@echo "运行市场分析演示..."
	uv run python demo_mcp_tools.py

## smoke-test: 运行冒烟测试
smoke-test:
	@echo "运行冒烟测试..."
	uv run python smoke_test.py

## all-tests: 运行所有测试
all-tests: verify uv-test smoke-test
	@echo "✅ 所有测试完成！"

## dev: 开发模式 - 安装依赖并验证
dev: uv-sync verify
	@echo "✅ 开发环境准备就绪！"
	@echo ""
	@echo "快速命令:"
	@echo "  make uv-run       - 启动 MCP 服务器"
	@echo "  make uv-web       - 启动 Web 仪表板"
	@echo "  make uv-test      - 运行测试"
	@echo "  make demo         - 运行演示"
