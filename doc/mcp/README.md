# Cursor MCP 配置说明

## 📁 文件说明

此目录包含 Cursor IDE 的 MCP (Model Context Protocol) 服务器配置。

### 文件列表

- `mcp.json` - Cursor MCP 服务器配置文件

---

## 🔧 配置文件说明

### mcp.json

这是 Polymarket MCP Server 的 Cursor 配置文件。

**配置内容：**

```json
{
  "mcpServers": {
    "polymarket": {
      "command": "/data/github/polymarket-mcp-server/.venv/bin/python",
      "args": ["-m", "polymarket_mcp.server"],
      "cwd": "/data/github/polymarket-mcp-server",
      "env": {
        "DEMO_MODE": "true",
        "LOG_LEVEL": "INFO"
      }
    }
  }
}
```

**字段说明：**

| 字段 | 说明 | 值 |
|------|------|-----|
| `command` | Python 解释器路径 | UV 虚拟环境中的 Python 3.14 |
| `args` | 启动参数 | `-m polymarket_mcp.server` |
| `cwd` | 工作目录 | 项目根目录 |
| `env.DEMO_MODE` | 运行模式 | `true` (DEMO 模式，只读) |
| `env.LOG_LEVEL` | 日志级别 | `INFO` |

---

## 🎯 当前配置模式

### DEMO 模式（只读）

**特点：**
- ✅ 无需钱包凭证
- ✅ 完全安全
- ✅ 25 个可用工具

**可用功能：**
- 市场发现和搜索（8 个工具）
- 市场分析（10 个工具）
- 实时数据监控（7 个工具）

**不可用功能：**
- 交易功能（12 个工具）
- 投资组合管理（8 个工具）

---

## 🔄 切换到完整交易模式

如需启用交易功能，修改 `mcp.json` 中的 `env` 部分：

```json
{
  "mcpServers": {
    "polymarket": {
      "command": "/data/github/polymarket-mcp-server/.venv/bin/python",
      "args": ["-m", "polymarket_mcp.server"],
      "cwd": "/data/github/polymarket-mcp-server",
      "env": {
        "DEMO_MODE": "false",
        "POLYGON_PRIVATE_KEY": "你的64位私钥不带0x",
        "POLYGON_ADDRESS": "0x你的42位地址",
        "LOG_LEVEL": "INFO",
        "MAX_ORDER_SIZE_USD": "1000",
        "MAX_TOTAL_EXPOSURE_USD": "5000"
      }
    }
  }
}
```

**或者使用 .env 文件（推荐）：**

1. 编辑项目根目录的 `.env` 文件
2. 设置 `DEMO_MODE=false`
3. 添加钱包凭证
4. 在 `mcp.json` 中移除 `env` 字段（会自动读取 .env）

```json
{
  "mcpServers": {
    "polymarket": {
      "command": "/data/github/polymarket-mcp-server/.venv/bin/python",
      "args": ["-m", "polymarket_mcp.server"],
      "cwd": "/data/github/polymarket-mcp-server"
    }
  }
}
```

---

## 🚀 使用方法

### 在 Cursor 中使用

1. **确保配置文件存在**
   ```bash
   ls -la .cursor/mcp.json
   ```

2. **Cursor 会自动检测此配置**
   - Cursor 会在项目根目录查找 `.cursor/mcp.json`
   - 自动加载 MCP 服务器

3. **在 Cursor 中使用 AI 助手**
   - 打开 Cursor AI 面板
   - AI 助手可以调用 Polymarket MCP 工具
   - 例如："查询 Polymarket 上的热门市场"

### 手动测试配置

```bash
# 测试 MCP 服务器是否正常启动
cd /data/github/polymarket-mcp-server
uv run polymarket-mcp

# 或使用虚拟环境
.venv/bin/python -m polymarket_mcp.server
```

---

## 🔍 故障排除

### 问题 1: Python 路径不正确

**错误：** `command not found` 或 `No such file or directory`

**解决方案：**
```bash
# 检查虚拟环境
ls -la .venv/bin/python

# 如果不存在，重新创建
uv sync --all-extras

# 更新 mcp.json 中的 command 路径
```

### 问题 2: 模块导入失败

**错误：** `ModuleNotFoundError: No module named 'polymarket_mcp'`

**解决方案：**
```bash
# 确保在项目目录
cd /data/github/polymarket-mcp-server

# 重新安装
uv sync --all-extras

# 验证安装
uv run python -c "import polymarket_mcp; print('OK')"
```

### 问题 3: 环境变量未生效

**错误：** 配置的环境变量没有生效

**解决方案：**
- 检查 `mcp.json` 中的 `env` 字段格式
- 确保 `.env` 文件存在且格式正确
- 重启 Cursor IDE

### 问题 4: 权限问题

**错误：** `Permission denied`

**解决方案：**
```bash
# 给 Python 可执行权限
chmod +x .venv/bin/python

# 检查 .env 文件权限
chmod 600 .env
```

---

## 📚 相关文档

- [配置指南](../doc/CONFIGURATION_GUIDE.md) - 完整的配置说明
- [UV 使用指南](../doc/dev/UV_GUIDE.md) - UV 依赖管理
- [安全审计报告](../doc/security_audit.md) - 安全性说明
- [README](../README.md) - 项目主文档

---

## 🔗 有用的命令

```bash
# 查看当前配置
cat .cursor/mcp.json | jq

# 验证 JSON 格式
cat .cursor/mcp.json | python -m json.tool

# 测试 MCP 服务器
make uv-run

# 查看日志
tail -f logs/polymarket-mcp.log  # 如果有日志文件

# 验证环境
make verify
```

---

## 💡 提示

1. **DEMO 模式是默认配置** - 最安全，无需任何凭证
2. **使用 .env 文件管理凭证** - 比在 mcp.json 中硬编码更安全
3. **定期更新依赖** - `uv lock --upgrade && uv sync`
4. **查看日志排查问题** - 设置 `LOG_LEVEL=DEBUG` 获取详细日志

---

## 🔄 配置版本

- **创建时间**: 2026-01-07
- **Python 版本**: 3.14.0
- **UV 版本**: 0.9.10
- **项目版本**: 0.1.0
- **配置模式**: DEMO (只读)

---

**需要帮助？** 查看 [doc/CONFIGURATION_GUIDE.md](../doc/CONFIGURATION_GUIDE.md)
