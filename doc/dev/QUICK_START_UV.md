# 🚀 UV 快速开始指南

> 使用 UV 进行极速 Python 依赖管理 - 比 pip 快 100 倍！

## ⚡ 一分钟快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/silvermissile/polymarket-mcp-server.git
cd polymarket-mcp-server

# 2. 安装依赖（自动）
make uv-sync

# 3. 验证安装
make verify

# 4. 运行项目
make uv-run
```

## 📋 常用命令速查表

### 依赖管理

| 命令 | 说明 |
|------|------|
| `make uv-sync` | 安装所有依赖 |
| `make uv-update` | 更新所有依赖 |
| `make uv-add PACKAGE=xxx` | 添加新依赖 |
| `make uv-add-dev PACKAGE=xxx` | 添加开发依赖 |
| `make uv-remove PACKAGE=xxx` | 移除依赖 |
| `make uv-list` | 查看已安装的包 |

### 运行项目

| 命令 | 说明 |
|------|------|
| `make uv-run` | 启动 MCP 服务器 |
| `make uv-web` | 启动 Web 仪表板 |
| `make demo` | 运行演示脚本 |
| `make verify` | 验证项目配置 |

### 测试和质量

| 命令 | 说明 |
|------|------|
| `make uv-test` | 运行测试 |
| `make uv-test-cov` | 运行测试（含覆盖率） |
| `make uv-format` | 格式化代码 |
| `make uv-lint` | 代码检查 |
| `make uv-lint-fix` | 自动修复问题 |
| `make all-tests` | 运行所有测试 |

### 维护

| 命令 | 说明 |
|------|------|
| `make uv-clean` | 清理环境 |
| `make uv-reinstall` | 重新安装 |
| `make uv-python` | 查看 Python 版本 |
| `make dev` | 设置开发环境 |

## 🎯 直接使用 UV 命令

如果你更喜欢直接使用 UV：

```bash
# 安装依赖
uv sync --all-extras

# 运行命令
uv run python script.py
uv run pytest
uv run polymarket-mcp

# 添加依赖
uv add package-name
uv add --dev package-name

# 更新依赖
uv lock --upgrade
uv sync
```

## 📚 项目信息

- **Python 版本**: 3.14.0 (兼容 3.10+)
- **UV 版本**: 0.9.10
- **已安装包**: 105 个
- **配置文件**: `pyproject.toml`, `uv.lock`

## 🔗 相关文档

- 📖 [UV_GUIDE.md](UV_GUIDE.md) - 完整的 UV 使用指南
- 📖 [MIGRATION_SUMMARY.md](MIGRATION_SUMMARY.md) - 迁移详细总结
- 📖 [README.md](README.md) - 项目主文档

## 💡 提示

1. **首次使用**: 运行 `make dev` 设置开发环境
2. **验证安装**: 运行 `make verify` 检查所有配置
3. **查看帮助**: 运行 `make help` 查看所有命令
4. **遇到问题**: 查看 [UV_GUIDE.md](UV_GUIDE.md) 的故障排除部分

## ⚡ 性能对比

| 操作 | pip + venv | UV | 提升 |
|------|-----------|-----|------|
| 首次安装 | ~120秒 | <1秒 | **100x+** |
| 缓存安装 | ~60秒 | <1秒 | **60x+** |
| 添加包 | ~10秒 | <1秒 | **10x+** |

---

**开始使用**: `make dev` 🚀
