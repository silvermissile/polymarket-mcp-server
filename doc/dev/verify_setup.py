#!/usr/bin/env python3
"""
验证项目设置和依赖安装
Verify project setup and dependency installation
"""

import sys
import subprocess
from pathlib import Path


def print_section(title: str):
    """打印章节标题"""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def check_python_version():
    """检查 Python 版本"""
    print_section("🐍 Python 版本检查")
    version = sys.version_info
    print(f"Python 版本: {version.major}.{version.minor}.{version.micro}")
    
    if version.major == 3 and version.minor >= 10:
        print("✅ Python 版本符合要求 (>= 3.10)")
        if version.minor == 14:
            print("🎯 使用推荐版本 Python 3.14")
        return True
    else:
        print(f"❌ Python 版本过低，需要 >= 3.10，当前: {version.major}.{version.minor}")
        return False


def check_uv_installation():
    """检查 uv 是否安装"""
    print_section("📦 UV 安装检查")
    try:
        result = subprocess.run(
            ["uv", "--version"],
            capture_output=True,
            text=True,
            check=True
        )
        version = result.stdout.strip()
        print(f"UV 版本: {version}")
        print("✅ UV 已正确安装")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ UV 未安装或不在 PATH 中")
        print("安装命令: curl -LsSf https://astral.sh/uv/install.sh | sh")
        return False


def check_project_files():
    """检查项目关键文件"""
    print_section("📁 项目文件检查")
    
    required_files = [
        "pyproject.toml",
        "uv.lock",
        ".python-version",
        "UV_GUIDE.md",
        "README.md",
    ]
    
    all_exist = True
    for file in required_files:
        path = Path(file)
        if path.exists():
            size = path.stat().st_size
            print(f"✅ {file:<25} ({size:,} bytes)")
        else:
            print(f"❌ {file:<25} (缺失)")
            all_exist = False
    
    return all_exist


def check_imports():
    """检查关键模块导入"""
    print_section("📚 模块导入检查")
    
    modules = [
        ("polymarket_mcp", "Polymarket MCP"),
        ("mcp", "MCP Protocol"),
        ("py_clob_client", "Polymarket CLOB Client"),
        ("websockets", "WebSockets"),
        ("eth_account", "Ethereum Account"),
        ("fastapi", "FastAPI"),
        ("pydantic", "Pydantic"),
    ]
    
    all_imported = True
    for module_name, display_name in modules:
        try:
            __import__(module_name)
            print(f"✅ {display_name:<30} 导入成功")
        except ImportError as e:
            print(f"❌ {display_name:<30} 导入失败: {e}")
            all_imported = False
    
    return all_imported


def check_git_remote():
    """检查 Git remote 配置"""
    print_section("🔧 Git Remote 配置检查")
    
    try:
        result = subprocess.run(
            ["git", "remote", "-v"],
            capture_output=True,
            text=True,
            check=True
        )
        
        remotes = result.stdout.strip()
        print(remotes)
        
        has_origin = "origin" in remotes and "silvermissile" in remotes
        has_upstream = "upstream" in remotes and "caiovicentino" in remotes
        
        if has_origin and has_upstream:
            print("\n✅ Git remote 配置正确")
            print("   - origin: silvermissile/polymarket-mcp-server")
            print("   - upstream: caiovicentino/polymarket-mcp-server")
            return True
        elif has_origin:
            print("\n⚠️  仅配置了 origin，缺少 upstream")
            return False
        else:
            print("\n❌ Git remote 配置不正确")
            return False
            
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ 无法检查 Git 配置（可能不在 Git 仓库中）")
        return False


def check_venv():
    """检查虚拟环境"""
    print_section("🌐 虚拟环境检查")
    
    venv_path = Path(".venv")
    if venv_path.exists() and venv_path.is_dir():
        print(f"✅ 虚拟环境存在: {venv_path.absolute()}")
        
        # 检查是否在虚拟环境中运行
        in_venv = sys.prefix != sys.base_prefix
        if in_venv:
            print(f"✅ 当前运行在虚拟环境中: {sys.prefix}")
        else:
            print(f"⚠️  未在虚拟环境中运行")
            print("   建议使用: uv run python verify_setup.py")
        
        return True
    else:
        print("❌ 虚拟环境不存在")
        print("   运行: uv sync --all-extras")
        return False


def main():
    """主函数"""
    print("\n" + "="*60)
    print("  🔍 Polymarket MCP Server - 环境验证工具")
    print("="*60)
    
    checks = [
        ("Python 版本", check_python_version),
        ("UV 安装", check_uv_installation),
        ("项目文件", check_project_files),
        ("虚拟环境", check_venv),
        ("模块导入", check_imports),
        ("Git 配置", check_git_remote),
    ]
    
    results = {}
    for name, check_func in checks:
        try:
            results[name] = check_func()
        except Exception as e:
            print(f"❌ 检查 {name} 时出错: {e}")
            results[name] = False
    
    # 总结
    print_section("📊 验证总结")
    
    passed = sum(1 for v in results.values() if v)
    total = len(results)
    
    for name, result in results.items():
        status = "✅ 通过" if result else "❌ 失败"
        print(f"{status:<10} {name}")
    
    print(f"\n总计: {passed}/{total} 项检查通过")
    
    if passed == total:
        print("\n🎉 所有检查通过！项目配置完美！")
        print("\n下一步:")
        print("  1. 配置 .env 文件（复制 .env.example）")
        print("  2. 运行: uv run polymarket-mcp")
        print("  3. 查看文档: UV_GUIDE.md")
        return 0
    else:
        print("\n⚠️  部分检查未通过，请查看上述错误信息")
        print("\n建议:")
        print("  1. 运行: uv sync --all-extras")
        print("  2. 查看: MIGRATION_SUMMARY.md")
        print("  3. 查看: UV_GUIDE.md")
        return 1


if __name__ == "__main__":
    sys.exit(main())
