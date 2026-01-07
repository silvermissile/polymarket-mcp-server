# 🔒 Polymarket MCP Server - 安全审计报告

## 审计日期
2026年1月7日

## 审计范围
- 所有 Python 源代码 (42 个文件)
- Shell 脚本 (7 个文件)
- 配置文件和依赖声明
- Docker 和 Kubernetes 配置

---

## 🎯 审计结果总结

**✅ 未发现明显的恶意代码或后门**

经过全面扫描，该项目是一个合法的 Polymarket 交易 MCP 服务器项目，代码质量良好，安全实践符合标准。

---

## 📋 详细审计发现

### 1. 网络外联与数据渗漏 ✅ 通过

| 风险等级 | 文件路径 | 代码片段 | 风险描述与分析 |
| -------- | -------- | -------- | -------------- |
| **低** | `src/polymarket_mcp/config.py` | `CLOB_API_URL = "https://clob.polymarket.com"`<br>`GAMMA_API_URL = "https://gamma-api.polymarket.com"` | **合法 API 端点** - 这些是 Polymarket 官方 API 地址，用于市场数据和交易功能。可在 Polymarket 官方文档中验证。 |
| **低** | `src/polymarket_mcp/tools/portfolio.py` | `https://data-api.polymarket.com/positions`<br>`https://data-api.polymarket.com/trades` | **合法 API 端点** - Polymarket 官方数据 API，用于获取用户持仓和交易历史。 |
| **低** | `src/polymarket_mcp/web/templates/monitoring.html` | `<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>` | **合法 CDN 资源** - Chart.js 是知名的开源图表库，从 jsDelivr CDN 加载（业界标准做法）。 |
| **低** | `install.sh` 第394行 | `curl -s --max-time 5 https://gamma-api.polymarket.com/markets` | **连接测试** - 仅用于验证 Polymarket API 可访问性，不发送任何用户数据。 |

**结论**: 所有网络请求都指向 Polymarket 官方 API 或知名 CDN，未发现可疑的外部连接或数据泄露行为。

---

### 2. 敏感文件与环境访问 ✅ 通过

| 风险等级 | 文件路径 | 代码片段 | 风险描述与分析 |
| -------- | -------- | -------- | -------------- |
| **无风险** | 多个文件 | `.env` 文件读写 | **标准配置管理** - 项目使用 `.env` 文件存储配置（行业标准做法）。`.env` 已在 `.gitignore` 中，不会提交到版本控制。所有 `.env` 操作都在项目目录内，不访问系统敏感路径。 |
| **无风险** | `setup_wizard.py` 第688行 | `Path.home() / "Library/Application Support/Claude/"` | **合法配置路径** - 仅访问 Claude Desktop 的官方配置目录，用于 MCP 服务器集成（这是 MCP 协议的标准做法）。 |

**结论**: 未发现访问 `~/.ssh`、`~/.aws`、`/etc/passwd` 等敏感系统文件的行为。所有文件操作都限制在项目目录和 Claude Desktop 配置目录内。

---

### 3. 代码混淆与执行 ✅ 通过

| 风险等级 | 文件路径 | 代码片段 | 风险描述与分析 |
| -------- | -------- | -------- | -------------- |
| **无风险** | `k8s/secret.yaml.template` | `base64` 编码示例 | **配置模板** - 仅是 Kubernetes Secret 的示例模板，使用 Base64 是 K8s 的标准做法。包含明确注释说明用途。 |
| **无风险** | `verify_setup.py` | `subprocess.run(["uv", "--version"])` | **环境验证** - 仅用于检查 UV 和 Git 是否安装，参数硬编码，无动态执行风险。 |
| **无风险** | `tests/test_e2e.py` | `subprocess` 用于测试 | **测试代码** - 仅在测试中使用，用于验证 CLI 命令，不在生产代码中。 |

**未发现**:
- ❌ `eval()` 或 `exec()` 的使用
- ❌ 混淆的 Base64/Hex 字符串
- ❌ 动态代码执行
- ❌ 可疑的 `system()` 调用

**结论**: 代码清晰透明，无混淆或恶意执行逻辑。所有 `subprocess` 使用都是合法的工具调用（git、uv 等）。

---

### 4. 恶意依赖 ✅ 通过

**依赖分析** (`pyproject.toml`):

| 包名 | 版本 | 用途 | 安全性 |
| ---- | ---- | ---- | ------ |
| `mcp` | >=1.0.0 | MCP 协议支持 | ✅ Anthropic 官方包 |
| `py-clob-client` | >=0.28.0 | Polymarket 官方 SDK | ✅ Polymarket 官方包 |
| `websockets` | >=12.0 | WebSocket 通信 | ✅ 主流包 (aaugustin) |
| `eth-account` | >=0.11.0 | 以太坊钱包 | ✅ ethereum 官方包 |
| `fastapi` | >=0.104.0 | Web 框架 | ✅ 主流框架 |
| `pydantic` | >=2.0.0 | 数据验证 | ✅ 主流包 |
| `httpx` | >=0.27.0 | HTTP 客户端 | ✅ 主流包 |
| `bandit` | >=1.7.0 | 安全扫描工具 | ✅ PyCQA 官方 |
| `safety` | >=3.0.0 | 依赖安全检查 | ✅ pyup.io 官方 |

**结论**: 
- ✅ 所有依赖都是知名的、经过验证的包
- ✅ 未发现拼写错误的可疑包（Typosquatting）
- ✅ 项目甚至包含安全扫描工具（bandit、safety）作为开发依赖
- ✅ 使用 `uv.lock` 锁定依赖版本，防止供应链攻击

---

### 5. 安装脚本审查 ✅ 通过

**审查的脚本**:
- `install.sh` - 自动化安装脚本
- `quickstart.sh` - 快速开始脚本
- `docker-start.sh` - Docker 启动脚本
- `Makefile` - 构建和管理命令

| 风险等级 | 发现 | 分析 |
| -------- | ---- | ---- |
| **低** | `curl ... \| bash` 模式 | README 中建议使用 `curl ... \| bash` 安装。虽然这是常见做法，但建议用户先下载脚本检查后再执行。 |
| **无风险** | 所有脚本操作透明 | 脚本逻辑清晰，仅执行：Python 环境创建、依赖安装、配置文件生成。无隐藏操作。 |
| **无风险** | 错误处理完善 | 包含 `rollback()` 函数，安装失败会清理环境，不留垃圾文件。 |

---

### 6. 私钥和凭证处理 ✅ 良好

**安全实践**:

| 实践 | 实现 | 评价 |
| ---- | ---- | ---- |
| 环境变量存储 | ✅ 使用 `.env` 文件 | 标准做法 |
| Git 忽略 | ✅ `.env` 在 `.gitignore` | 防止泄露 |
| 日志脱敏 | ✅ `config.to_dict()` 隐藏敏感字段 | 良好实践 |
| 验证逻辑 | ✅ 私钥和地址格式验证 | 防止配置错误 |
| Demo 模式 | ✅ 支持无钱包的只读模式 | 安全的测试选项 |
| 用户提示 | ✅ 多处警告用户保护私钥 | 安全意识教育 |

**示例** (`config.py` 第204-210行):
```python
def to_dict(self) -> dict:
    """Convert config to dictionary (hiding sensitive data)"""
    data = self.model_dump()
    # Mask sensitive fields
    if data.get("POLYGON_PRIVATE_KEY"):
        data["POLYGON_PRIVATE_KEY"] = "***HIDDEN***"
```

---

### 7. Docker 安全 ✅ 良好

**Dockerfile 安全实践**:

| 实践 | 实现 | 评价 |
| ---- | ---- | ---- |
| 非 root 用户 | ✅ 创建 `polymarket` 用户运行 | 最佳实践 |
| 多阶段构建 | ✅ Builder + Runtime 分离 | 减小镜像体积 |
| 最小化镜像 | ✅ 使用 `python:3.12-slim` | 减少攻击面 |
| 清理缓存 | ✅ `pip cache purge` | 减小镜像大小 |
| 健康检查 | ✅ `HEALTHCHECK` 指令 | 容器监控 |

---

## 🔍 建议改进项（非安全风险）

虽然未发现安全问题，但有以下建议：

| 优先级 | 建议 | 理由 |
| ------ | ---- | ---- |
| **中** | 在 README 中添加"不要直接 curl \| bash"的警告 | 教育用户先检查脚本内容 |
| **低** | 考虑添加代码签名 | 增强用户信任 |
| **低** | 添加 SECURITY.md 文件 | 说明安全漏洞报告流程 |
| **低** | 定期运行 `safety check` 和 `bandit` | 项目已包含这些工具，建议在 CI 中自动化 |

---

## ✅ 安全优点

该项目展现了良好的安全实践：

1. **透明度高** - 代码清晰，无混淆
2. **依赖管理** - 使用 `uv.lock` 锁定版本
3. **安全工具** - 集成 bandit 和 safety
4. **最小权限** - Docker 使用非 root 用户
5. **凭证保护** - 日志中隐藏敏感信息
6. **Demo 模式** - 支持无钱包测试
7. **输入验证** - 私钥和地址格式验证
8. **错误处理** - 完善的异常处理和回滚机制

---

## 📊 最终评分

| 类别 | 评分 | 说明 |
| ---- | ---- | ---- |
| 网络安全 | ✅ 9/10 | 所有请求指向合法 API |
| 文件访问 | ✅ 10/10 | 无敏感文件访问 |
| 代码执行 | ✅ 10/10 | 无动态执行或混淆 |
| 依赖安全 | ✅ 10/10 | 所有依赖合法且锁定 |
| 凭证管理 | ✅ 9/10 | 良好的安全实践 |
| **总体评分** | **✅ 9.6/10** | **安全可靠** |

---

## 🎯 结论

**经过全面的安全审计，该项目未发现明显的恶意网络连接、文件窃取行为或后门代码。**

这是一个合法的、开源的 Polymarket MCP 服务器项目，代码质量良好，安全实践符合行业标准。项目甚至主动集成了安全扫描工具（bandit、safety），显示出开发者对安全的重视。

**建议**: 
- ✅ 可以安全使用
- ⚠️ 使用前建议审查 `.env` 配置，确保私钥安全
- ⚠️ 从官方仓库克隆，不要使用第三方修改版本
- ⚠️ 定期更新依赖以获取安全补丁

---

**审计完成时间**: 2026年1月7日  
**审计工具**: 手动代码审查 + 模式匹配扫描  
**审计覆盖率**: 100% (所有源代码和脚本)