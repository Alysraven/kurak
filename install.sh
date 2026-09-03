#!/usr/bin/env bash
# ==============================================================================
# KURAK 一键远程安装引导脚本 (Bootstrap Loader)
# GitHub: https://github.com/Alysraven/kurak
# ==============================================================================

set -e

REPO_RAW_BASE="https://raw.githubusercontent.com/Alysraven/kurak/main"
TARGET_DIR="/usr/local/share/kurak"
SCRIPT_TARGET="${TARGET_DIR}/kurak.sh"
ALIAS_NAME="kurak"

if [ "$(id -u)" -ne 0 ]; then
    echo -e "\033[31m[ERROR] 安装需要 root 权限，请使用 sudo 或切换至 root 用户执行！\033[0m" >&2
    exit 1
fi

mkdir -p "$TARGET_DIR"

echo -e "\033[36m>>> 正在下载并配置 KURAK...\033[0m"

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
if [ -n "$CURRENT_DIR" ] && [ -f "${CURRENT_DIR}/kurak.sh" ]; then
    cp -f "${CURRENT_DIR}/kurak.sh" "$SCRIPT_TARGET"
else
    if ! command -v curl >/dev/null 2>&1; then
        apt update -y && apt install -y curl
    fi
    curl -fsSL "${REPO_RAW_BASE}/kurak.sh" -o "$SCRIPT_TARGET" || {
        curl -fsSL "https://ghproxy.net/${REPO_RAW_BASE}/kurak.sh" -o "$SCRIPT_TARGET"
    }
fi

chmod +x "$SCRIPT_TARGET"

# 创建全局快捷软链接
cat << EOF > "/usr/local/bin/${ALIAS_NAME}"
#!/usr/bin/env bash
exec bash "${SCRIPT_TARGET}" "\$@"
EOF
chmod +x "/usr/local/bin/${ALIAS_NAME}"
ln -sf "/usr/local/bin/${ALIAS_NAME}" "/usr/bin/${ALIAS_NAME}" 2>/dev/null || true

# 快捷别名 k
ln -sf "/usr/local/bin/${ALIAS_NAME}" "/usr/local/bin/k" 2>/dev/null || true
ln -sf "/usr/local/bin/${ALIAS_NAME}" "/usr/bin/k" 2>/dev/null || true

echo -e "\033[32m[OK] 安装成功！快捷命令 'kurak' (或 'k') 已生效。\033[0m"

# 立即启动并透传参数
exec bash "$SCRIPT_TARGET" "$@"
