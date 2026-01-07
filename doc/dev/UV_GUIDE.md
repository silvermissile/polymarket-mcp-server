# UV 依赖管理指南

本项目已配置使用 [uv](https://github.com/astral-sh/uv) 进行依赖管理。uv 是一个极速的 Python 包管理器，比 pip 快 10-100 倍。

## 📦 为什么使用 UV？

- ⚡ **极速安装**: 比 pip 快 10-100 倍
- 🔒 **依赖锁定**: 自动生成 `uv.lock` 确保环境一致性
- 🎯 **兼容性好**: 完全兼容 `pyproject.toml` 和 pip
- 🚀 **开箱即用**: 自动管理虚拟环境
- 💾 **缓存优化**: 智能缓存减少重复下载

## 🚀 快速开始

### 1. 安装依赖

```bash
# 安装所有依赖（包括开发依赖）
uv sync --all-extras

# 仅安装生产依赖
uv sync

# 安装特定的可选依赖组
uv sync --extra dev
```

### 2. 运行命令

```bash
# 在虚拟环境中运行命令
uv run python demo_mcp_tools.py

# 运行 pytest
uv run pytest

# 运行项目脚本
uv run polymarket-mcp
uv run polymarket-web
```

### 3. 添加新依赖

```bash
# 添加生产依赖
uv add package-name

# 添加开发依赖
uv add --dev package-name

# 添加特定版本
uv add "package-name>=1.0.0"
```

### 4. 更新依赖

```bash
# 更新所有依赖到最新兼容版本
uv lock --upgrade

# 更新特定包
uv lock --upgrade-package package-name

# 同步更新后的依赖
uv sync
```

### 5. 移除依赖

```bash
# 移除包
uv remove package-name
```

## 📋 常用命令对照表

| 操作 | pip/venv | uv |
|------|----------|-----|
| 创建虚拟环境 | `python -m venv .venv` | `uv venv` (自动) |
| 激活环境 | `source .venv/bin/activate` | 不需要 (uv run) |
| 安装依赖 | `pip install -r requirements.txt` | `uv sync` |
| 安装包 | `pip install package` | `uv add package` |
| 运行脚本 | `python script.py` | `uv run python script.py` |
| 运行测试 | `pytest` | `uv run pytest` |
| 锁定依赖 | `pip freeze > requirements.txt` | `uv lock` (自动) |

## 🔧 项目结构

```
polymarket-mcp-server/
├── pyproject.toml      # 项目配置和依赖声明
├── uv.lock            # 锁定的依赖版本（自动生成）
├── .venv/             # 虚拟环境（自动创建）
└── .python-version    # Python 版本配置
```

## 💡 最佳实践

### 1. 提交 uv.lock 到版本控制

```bash
git add uv.lock
git commit -m "chore: 更新依赖锁定文件"
```

这确保所有开发者使用相同的依赖版本。

### 2. 定期更新依赖

```bash
# 每周或每月运行一次
uv lock --upgrade
uv sync
uv run pytest  # 确保测试通过
```

### 3. 使用 uv run 运行命令

```bash
# ✅ 推荐：自动使用项目虚拟环境
uv run python script.py

# ❌ 不推荐：需要手动激活环境
source .venv/bin/activate
python script.py
```

### 4. CI/CD 集成

```yaml
# GitHub Actions 示例
- name: 安装 uv
  uses: astral-sh/setup-uv@v1

- name: 安装依赖
  run: uv sync --all-extras

- name: 运行测试
  run: uv run pytest
```

## 🔍 故障排除

### 问题：依赖冲突

```bash
# 清理并重新锁定
rm uv.lock
uv lock
uv sync
```

### 问题：缓存问题

```bash
# 清理 uv 缓存
uv cache clean

# 重新安装
uv sync --reinstall
```

### 问题：Python 版本不匹配

```bash
# 检查 Python 版本
uv python list

# 使用特定 Python 版本（本项目使用 3.14）
uv venv --python 3.14

# 如果 3.14 未安装，先安装
uv python install 3.14
```

## 📚 更多资源

- [uv 官方文档](https://docs.astral.sh/uv/)
- [uv GitHub 仓库](https://github.com/astral-sh/uv)
- [pyproject.toml 规范](https://packaging.python.org/en/latest/specifications/pyproject-toml/)

## 🔄 从 pip 迁移

如果你之前使用 pip，以下是迁移步骤：

```bash
# 1. 删除旧的虚拟环境（可选）
rm -rf venv/ env/

# 2. 使用 uv 创建新环境并安装依赖
uv sync --all-extras

# 3. 验证安装
uv run python -c "import polymarket_mcp; print('✅ 安装成功')"

# 4. 运行测试
uv run pytest
```

## ⚙️ 配置选项

在 `pyproject.toml` 中可以配置 uv 行为：

```toml
[tool.uv]
# 指定 Python 版本（本项目使用 3.14）
python = "3.14"

# 配置索引 URL（如果需要私有 PyPI）
index-url = "https://pypi.org/simple"

# 额外的索引 URL
extra-index-url = ["https://private.pypi.org/simple"]
```

**注意**: 本项目已配置为使用 Python 3.14，同时兼容 3.10+。`.python-version` 文件指定了默认版本。

## 🎯 项目特定命令

```bash
# 运行 MCP 服务器
uv run polymarket-mcp

# 启动 Web 仪表板
uv run polymarket-web

# 运行设置向导
uv run polymarket-setup

# 运行市场分析演示
uv run python demo_mcp_tools.py

# 运行交易测试
uv run python run_trading_tests.py

# 运行完整测试套件
uv run pytest tests/ -v

# 运行代码格式化
uv run black src/ tests/
uv run ruff check src/ tests/

# 运行类型检查
uv run mypy src/
```

---

**提示**: 如果你遇到任何问题，请查看 [故障排除](#-故障排除) 部分或提交 Issue。
