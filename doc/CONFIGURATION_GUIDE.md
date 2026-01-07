# 🔑 Polymarket MCP Server - 配置指南

## 📊 配置要求总览

| 配置项 | 是否必需 | 用途 | 获取方式 |
|--------|---------|------|---------|
| **POLYGON_PRIVATE_KEY** | ⚠️ 看模式 | 钱包私钥 | MetaMask 或创建新钱包 |
| **POLYGON_ADDRESS** | ⚠️ 看模式 | 钱包地址 | 对应私钥的地址 |
| **POLYMARKET_API_KEY** | ❌ 非必需 | L2 API 认证 | **自动生成** |
| **POLYMARKET_PASSPHRASE** | ❌ 非必需 | API 密码 | **自动生成** |

---

## 🎯 两种运行模式

### 1️⃣ DEMO 模式（推荐新手）- ❌ 不需要任何真实凭证

**特点：**
- 完全无需钱包和私钥
- 安全的只读模式
- 适合学习和测试

**配置方法：**
```bash
# 创建配置文件
cp .env.example .env

# 编辑 .env
nano .env
```

**只需设置：**
```env
DEMO_MODE=true
LOG_LEVEL=INFO
```

**可用功能：**
- ✅ 市场发现和搜索（8 个工具）
  - 搜索市场
  - 获取热门市场
  - 按类别筛选
  - 查看即将结束的市场
  
- ✅ 市场分析（10 个工具）
  - 获取市场详情
  - 实时价格查询
  - 订单簿分析
  - 流动性和交易量
  - AI 驱动的机会分析
  
- ✅ 实时数据监控（7 个工具）
  - WebSocket 价格订阅
  - 订单簿更新
  - 市场解决通知

**不可用功能：**
- ❌ 交易功能（12 个工具）
- ❌ 投资组合管理（8 个工具）

**适合场景：**
- 🎓 学习 Polymarket 市场机制
- 🔍 市场研究和数据分析
- 🧪 测试 MCP 服务器功能
- 📊 开发和调试

---

### 2️⃣ 完整交易模式 - ✅ 需要 Polygon 钱包

**必需配置：**
```env
# 钱包配置（必需）
POLYGON_PRIVATE_KEY=你的64位私钥不带0x前缀
POLYGON_ADDRESS=0x你的42位钱包地址
POLYMARKET_CHAIN_ID=137  # 137=主网, 80002=测试网
```

**可选配置（会自动生成）：**
```env
# API Key（留空，系统会自动创建）
POLYMARKET_API_KEY=
POLYMARKET_PASSPHRASE=
```

**安全限制配置（强烈推荐）：**
```env
# 风险管理
MAX_ORDER_SIZE_USD=1000              # 单笔订单最大金额
MAX_TOTAL_EXPOSURE_USD=5000          # 总敞口限制
MAX_POSITION_SIZE_PER_MARKET=2000    # 单市场最大持仓
MIN_LIQUIDITY_REQUIRED=10000         # 最低流动性要求
MAX_SPREAD_TOLERANCE=0.05            # 最大价差容忍度 (5%)

# 交易控制
ENABLE_AUTONOMOUS_TRADING=true       # 启用自主交易
REQUIRE_CONFIRMATION_ABOVE_USD=500   # 超过此金额需要确认
AUTO_CANCEL_ON_LARGE_SPREAD=true     # 价差过大自动取消

# 日志
LOG_LEVEL=INFO
```

**可用功能：**
- ✅ 所有 DEMO 模式功能（25 个工具）
- ✅ 交易功能（12 个工具）
  - 限价单和市价单
  - 批量下单
  - 智能交易执行
  - 订单管理和取消
  - 持仓再平衡
  
- ✅ 投资组合管理（8 个工具）
  - 实时持仓查询
  - 盈亏分析
  - 风险评估
  - 交易历史
  - AI 驱动的投资组合优化

**总计：45 个工具**

---

## 🔐 如何获取钱包凭证？

### 方法 1: 使用现有 MetaMask 钱包

**步骤：**
1. 打开 MetaMask 浏览器扩展
2. 切换到 **Polygon 网络**
3. 点击账户菜单 → **账户详情**
4. 点击 **导出私钥**
5. 输入 MetaMask 密码
6. 复制私钥（64位十六进制字符串）

**获取地址：**
- 在 MetaMask 主界面直接复制
- 格式：`0x` 开头的 42 位字符串

**⚠️ 安全警告：**
- 私钥 = 完全控制权
- 私钥泄露 = 资金全部丢失
- 绝不分享私钥
- 绝不提交到 Git
- 建议使用专用测试钱包

---

### 方法 2: 创建新钱包（推荐用于测试）

**使用 Python 脚本创建：**

```bash
cd /data/github/polymarket-mcp-server

# 创建新钱包
python3 << 'EOF'
from eth_account import Account
import secrets

# 生成随机私钥
private_key = secrets.token_hex(32)
account = Account.from_key(private_key)

print('=' * 70)
print('🔑 新 Polygon 钱包已创建')
print('=' * 70)
print(f'Private Key (私钥): {private_key}')
print(f'Address (地址):     {account.address}')
print('=' * 70)
print('')
print('⚠️  重要提示：')
print('   1. 立即保存这些信息到安全的地方（如密码管理器）')
print('   2. 私钥泄露 = 资金全部丢失')
print('   3. 绝不分享给任何人')
print('   4. 绝不提交到 Git 或公开平台')
print('   5. 建议先用小额测试（$50-100）')
print('')
print('📝 配置到 .env 文件：')
print(f'   POLYGON_PRIVATE_KEY={private_key}')
print(f'   POLYGON_ADDRESS={account.address}')
print('=' * 70)
EOF
```

**或使用 UV：**
```bash
uv run python -c "
from eth_account import Account
import secrets
priv = secrets.token_hex(32)
account = Account.from_key(priv)
print(f'Private Key: {priv}')
print(f'Address: {account.address}')
"
```

---

### 方法 3: 使用在线钱包生成器

**注意：** 仅用于测试，不推荐用于生产环境

1. 访问 MyEtherWallet (MEW) 或类似工具
2. 选择 "创建新钱包"
3. 下载 Keystore 文件或记录助记词
4. 导出私钥

---

## 🤖 API Key 自动生成机制

### 重要：Polymarket API Key 会自动创建！

**工作原理：**

根据代码 `src/polymarket_mcp/server.py`，系统会自动处理 API 凭证：

```python
# 如果没有提供 API credentials，系统会自动创建
if not polymarket_client.has_api_credentials():
    logger.info("No API credentials found. Attempting to create...")
    try:
        await polymarket_client.create_api_credentials()
        logger.info("API credentials created successfully!")
        # 会在日志中显示生成的 API Key
        logger.info(f"POLYMARKET_API_KEY={api_key}")
        logger.info(f"POLYMARKET_PASSPHRASE={passphrase}")
    except Exception as e:
        # 如果创建失败，会降级到只读模式
        logger.info("Continuing in READ-ONLY mode")
```

**这意味着：**

1. ✅ 你只需提供 `POLYGON_PRIVATE_KEY` 和 `POLYGON_ADDRESS`
2. ✅ API Key 会在首次运行时自动生成
3. ✅ 生成后的 API Key 会显示在日志中
4. ✅ 你可以把它们保存到 `.env` 文件中以便下次使用
5. ✅ 如果创建失败（如钱包没有资金），会自动切换到只读模式

**查看自动生成的 API Key：**

```bash
# 启动服务器
make uv-run

# 或
uv run polymarket-mcp

# 在日志中查找类似输出：
# API credentials created successfully!
# POLYMARKET_API_KEY=abc123...
# POLYMARKET_PASSPHRASE=xyz789...
```

**保存到配置文件（可选）：**

```bash
# 将日志中的 API Key 添加到 .env
echo "POLYMARKET_API_KEY=你的API_KEY" >> .env
echo "POLYMARKET_PASSPHRASE=你的PASSPHRASE" >> .env
```

---

## 💰 资金要求

### 完整交易模式需要：

#### 1. USDC 代币（在 Polygon 网络）

**用途：** 用于在 Polymarket 上交易

**建议金额：**
- 测试：$50 - $100
- 小规模交易：$500 - $1,000
- 中等规模：$5,000 - $10,000

**如何获取：**
- 从中心化交易所（Binance、OKX、Coinbase）直接提现到 Polygon 网络
- 使用 Polygon Bridge 从以太坊主网桥接
- 使用跨链桥（如 Hop Protocol、Synapse）

#### 2. MATIC 代币（少量）

**用途：** 支付 Polygon 网络的 Gas 费

**建议金额：**
- $5 - $10 的 MATIC 通常足够数百笔交易

**如何获取：**
- 从交易所购买并提现到 Polygon 网络
- 使用 Polygon Faucet（测试网）

---

### 充值步骤示例（Binance）

```
1. 登录 Binance
2. 进入钱包 → 现货账户
3. 找到 USDC → 提现
4. 选择网络：Polygon (MATIC)
5. 输入你的钱包地址（0x...）
6. 输入金额
7. 确认提现

⚠️ 注意：
- 确保选择 Polygon 网络，不是以太坊主网
- 小额测试后再大额转账
- 保存交易哈希以便追踪
```

---

## 🛡️ 安全最佳实践

### 必须遵守的安全规则

| 规则 | 重要性 | 说明 |
|------|--------|------|
| 🔒 使用 DEMO 模式测试 | ⭐⭐⭐⭐⭐ | 先熟悉所有功能再用真钱 |
| 🔑 创建专用钱包 | ⭐⭐⭐⭐⭐ | 不要用主钱包，避免全部资金风险 |
| 💵 小额测试 | ⭐⭐⭐⭐⭐ | 先用 $50-100 测试所有功能 |
| 🚫 私钥安全 | ⭐⭐⭐⭐⭐ | 绝不分享、绝不提交到 Git |
| ⚙️ 设置安全限制 | ⭐⭐⭐⭐ | 配置 MAX_ORDER_SIZE_USD 等参数 |
| 👀 定期检查 | ⭐⭐⭐⭐ | 监控交易和持仓状态 |
| 📝 保存日志 | ⭐⭐⭐ | 记录所有重要操作 |
| 🔄 定期备份 | ⭐⭐⭐ | 备份配置和重要数据 |

### 私钥存储建议

**✅ 推荐方式：**
- 使用密码管理器（1Password、Bitwarden）
- 硬件钱包（Ledger、Trezor）
- 加密的离线存储
- `.env` 文件（确保在 `.gitignore` 中）

**❌ 禁止方式：**
- 明文存储在代码中
- 提交到 Git 仓库
- 发送到聊天软件
- 存储在云笔记（未加密）
- 截图或拍照

### 配置文件安全检查

```bash
# 检查 .env 是否在 .gitignore 中
grep -q "^\.env$" .gitignore && echo "✅ .env 已忽略" || echo "❌ 警告：.env 未忽略！"

# 检查是否意外提交了 .env
git ls-files | grep -q "^\.env$" && echo "❌ 危险：.env 已提交到 Git！" || echo "✅ .env 未提交"

# 检查私钥格式
if grep -q "POLYGON_PRIVATE_KEY=0x" .env; then
    echo "⚠️  警告：私钥包含 0x 前缀，应该移除"
fi
```

---

## 📝 快速配置示例

### 场景 1: DEMO 模式（最简单，无需凭证）

```bash
# 1. 创建配置文件
cat > .env << 'EOF'
# ============================================
# Polymarket MCP Server - DEMO 模式配置
# ============================================

# 运行模式
DEMO_MODE=true

# 日志级别
LOG_LEVEL=INFO

# 安全限制（DEMO 模式下不生效，但保留配置）
MAX_ORDER_SIZE_USD=100
MAX_TOTAL_EXPOSURE_USD=500
ENABLE_AUTONOMOUS_TRADING=false
EOF

# 2. 验证配置
cat .env

# 3. 启动服务器
make uv-run

# 或使用 UV 直接运行
uv run polymarket-mcp
```

---

### 场景 2: 完整交易模式（需要钱包）

```bash
# 1. 创建配置文件
cat > .env << 'EOF'
# ============================================
# Polymarket MCP Server - 完整交易模式配置
# ============================================

# 钱包配置（必需）
POLYGON_PRIVATE_KEY=你的64位私钥不带0x前缀
POLYGON_ADDRESS=0x你的42位钱包地址
POLYMARKET_CHAIN_ID=137

# API Key（可选，会自动生成）
# POLYMARKET_API_KEY=
# POLYMARKET_PASSPHRASE=

# 安全限制（强烈推荐）
MAX_ORDER_SIZE_USD=1000
MAX_TOTAL_EXPOSURE_USD=5000
MAX_POSITION_SIZE_PER_MARKET=2000
MIN_LIQUIDITY_REQUIRED=10000
MAX_SPREAD_TOLERANCE=0.05

# 交易控制
ENABLE_AUTONOMOUS_TRADING=true
REQUIRE_CONFIRMATION_ABOVE_USD=500
AUTO_CANCEL_ON_LARGE_SPREAD=true

# 日志
LOG_LEVEL=INFO
EOF

# 2. 编辑配置文件，填入真实凭证
nano .env

# 3. 验证配置
make verify

# 4. 启动服务器
make uv-run
```

---

### 场景 3: 保守交易模式（小额测试）

```bash
cat > .env << 'EOF'
# ============================================
# Polymarket MCP Server - 保守交易模式
# ============================================

# 钱包配置
POLYGON_PRIVATE_KEY=你的私钥
POLYGON_ADDRESS=0x你的地址
POLYMARKET_CHAIN_ID=137

# 保守的安全限制
MAX_ORDER_SIZE_USD=100           # 单笔最多 $100
MAX_TOTAL_EXPOSURE_USD=500       # 总敞口 $500
MAX_POSITION_SIZE_PER_MARKET=200 # 单市场 $200
MIN_LIQUIDITY_REQUIRED=50000     # 要求高流动性
MAX_SPREAD_TOLERANCE=0.02        # 仅 2% 价差

# 严格的交易控制
ENABLE_AUTONOMOUS_TRADING=false  # 禁用自主交易
REQUIRE_CONFIRMATION_ABOVE_USD=50 # 超过 $50 需确认
AUTO_CANCEL_ON_LARGE_SPREAD=true

LOG_LEVEL=INFO
EOF
```

---

## 🔧 配置验证

### 使用验证脚本

```bash
# 运行完整验证
make verify

# 或直接运行
uv run python doc/dev/verify_setup.py
```

**验证内容：**
- ✅ Python 版本（3.10+）
- ✅ UV 安装状态
- ✅ 项目文件完整性
- ✅ 虚拟环境配置
- ✅ 模块导入测试
- ✅ Git 配置检查

### 手动验证配置

```bash
# 检查配置文件是否存在
test -f .env && echo "✅ .env 存在" || echo "❌ .env 不存在"

# 检查必需的配置项（DEMO 模式）
grep -q "DEMO_MODE=true" .env && echo "✅ DEMO 模式已启用"

# 检查必需的配置项（完整模式）
grep -q "POLYGON_PRIVATE_KEY=" .env && echo "✅ 私钥已配置"
grep -q "POLYGON_ADDRESS=" .env && echo "✅ 地址已配置"

# 检查私钥格式（应该是 64 位十六进制）
PRIVATE_KEY=$(grep "POLYGON_PRIVATE_KEY=" .env | cut -d= -f2)
if [[ ${#PRIVATE_KEY} -eq 64 ]]; then
    echo "✅ 私钥长度正确"
else
    echo "❌ 私钥长度错误：${#PRIVATE_KEY} (应该是 64)"
fi

# 检查地址格式（应该是 0x 开头的 42 位）
ADDRESS=$(grep "POLYGON_ADDRESS=" .env | cut -d= -f2)
if [[ $ADDRESS =~ ^0x[0-9a-fA-F]{40}$ ]]; then
    echo "✅ 地址格式正确"
else
    echo "❌ 地址格式错误"
fi
```

---

## 🚀 启动服务器

### 使用 Makefile（推荐）

```bash
# DEMO 模式
make uv-run

# 查看所有可用命令
make help

# 运行测试
make uv-test

# 验证配置
make verify
```

### 直接使用 UV

```bash
# 启动 MCP 服务器
uv run polymarket-mcp

# 启动 Web 仪表板
uv run polymarket-web

# 运行演示脚本
uv run python demo_mcp_tools.py
```

### 使用 Docker

```bash
# 构建镜像
docker build -t polymarket-mcp .

# 运行容器（DEMO 模式）
docker run -e DEMO_MODE=true polymarket-mcp

# 运行容器（完整模式）
docker run --env-file .env polymarket-mcp
```

---

## 🐛 故障排除

### 问题 1: 配置文件未找到

```bash
# 错误：FileNotFoundError: .env file not found

# 解决方案：
cp .env.example .env
nano .env
```

### 问题 2: 私钥格式错误

```bash
# 错误：POLYGON_PRIVATE_KEY must be 64 hex characters

# 检查：
# ❌ 错误格式：0x1234... (包含 0x)
# ❌ 错误格式：1234 (太短)
# ✅ 正确格式：1234567890abcdef... (64位十六进制)

# 解决方案：
# 1. 移除 0x 前缀
# 2. 确保是 64 位字符
# 3. 只包含 0-9 和 a-f
```

### 问题 3: API 凭证创建失败

```bash
# 错误：Could not create API credentials

# 可能原因：
# 1. 钱包没有资金（需要少量 MATIC 作为 Gas）
# 2. 网络连接问题
# 3. Polymarket API 暂时不可用

# 解决方案：
# 1. 充值少量 MATIC 到钱包
# 2. 检查网络连接
# 3. 服务器会自动降级到只读模式，仍可使用市场分析功能
```

### 问题 4: 权限被拒绝

```bash
# 错误：Permission denied: .env

# 解决方案：
chmod 600 .env  # 设置为仅所有者可读写
```

---

## 📚 相关文档

- 📖 [README.md](../README.md) - 项目主文档
- 📖 [UV_GUIDE.md](dev/UV_GUIDE.md) - UV 使用指南
- 📖 [MIGRATION_SUMMARY.md](dev/MIGRATION_SUMMARY.md) - 迁移总结
- 📖 [QUICK_START_UV.md](dev/QUICK_START_UV.md) - 快速开始
- 🔒 [security_audit.md](security_audit.md) - 安全审计报告

---

## 🎯 总结

### 最简单的方式（推荐新手）

```bash
# 1. 设置 DEMO 模式
echo "DEMO_MODE=true" > .env

# 2. 启动服务器
make uv-run

# 3. 开始使用（无需任何凭证）
```

### 需要交易功能

```bash
# 1. 只需提供钱包凭证
cat > .env << EOF
POLYGON_PRIVATE_KEY=你的私钥
POLYGON_ADDRESS=0x你的地址
EOF

# 2. API Key 会自动生成
make uv-run

# 3. 查看日志中的 API Key（可选保存）
```

### 关键要点

- ✅ **DEMO 模式无需任何凭证** - 最安全的测试方式
- ✅ **API Key 自动生成** - 无需手动获取
- ✅ **只需钱包私钥** - 用于完整交易功能
- ✅ **安全限制可配置** - 保护你的资金
- ✅ **支持只读降级** - 即使配置失败也能使用部分功能

---

**最后提醒：** 

🔒 **安全第一！** 先用 DEMO 模式熟悉功能，再用小额测试，最后才进行正式交易。

💡 **不需要手动获取 Polymarket API Key** - 系统会自动处理！

🎉 **开始使用：** `make uv-run`
