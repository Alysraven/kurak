#!/usr/bin/env bash
# ==============================================================================
# KURAK (v1.0.0) - Linux 自动化运维与 3x-ui 部署工具
# GitHub: https://github.com/Alysraven/kurak
# ==============================================================================

set -e

APP_NAME="KURAK"
APP_VERSION="1.0.0"
DEFAULT_ALIAS="kurak"
INSTALL_DIR="/usr/local/share/kurak"
SCRIPT_PATH="${INSTALL_DIR}/kurak.sh"
CONFIG_FILE="${INSTALL_DIR}/config.env"

# 终端 ANSI 颜色定义
CLR_RESET='\033[0m'
CLR_RED='\033[31m'
CLR_GREEN='\033[32m'
CLR_YELLOW='\033[33m'
CLR_BLUE='\033[34m'
CLR_CYAN='\033[36m'
CLR_BOLD='\033[1m'
CLR_DIM='\033[2m'

# 默认语言 (cn: 简体中文, tw: 繁體中文, en: English)
LANG_MODE="cn"

# 读取持久化配置
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
fi

# 解析命令行中的语言参数
if [ "${1:-}" = "tw" ] || [ "${1:-}" = "TW" ]; then
    LANG_MODE="tw"
    shift
elif [ "${1:-}" = "en" ] || [ "${1:-}" = "EN" ]; then
    LANG_MODE="en"
    shift
elif [ "${1:-}" = "cn" ] || [ "${1:-}" = "CN" ]; then
    LANG_MODE="cn"
    shift
fi

# 多语言界面适配
set_language_strings() {
    case "$LANG_MODE" in
        tw)
            TXT_TITLE="KURAK - Linux 自動化維運與 3x-ui 部署工具"
            TXT_OS="作業系統"
            TXT_KERNEL="核心"
            TXT_IP="外網 IP"
            TXT_MEM="記憶體"
            TXT_UPTIME="運行時間"
            TXT_ALIAS="快捷指令"
            TXT_MENU_HEADER="核心自動化部署"
            TXT_OPT_ALL="一鍵全自動執行 (步驟 1 + 2 + 3)"
            TXT_OPT_ALL_DESC="自動依序完成系統更新、啟用 BBR 與安裝 3x-ui"
            TXT_OPT_STEP1="第一步：系統與軟體包更新"
            TXT_OPT_STEP1_DESC="apt update && apt upgrade -y"
            TXT_OPT_STEP2="第二步：配置並啟用 BBR"
            TXT_OPT_STEP2_DESC="寫入 99-bbr.conf 並立即套用驗證"
            TXT_OPT_STEP3="第三步：一鍵安裝 3x-ui 面板"
            TXT_OPT_STEP3_DESC="執行官方 3x-ui 安裝程式"
            TXT_OPT_EXIT="退出腳本"
            TXT_PROMPT="請輸入選項數字 [0-4]: "
            TXT_STEP1_START="第一步：正在執行系統與軟體包更新..."
            TXT_STEP1_OK="第一步：系統更新完成！"
            TXT_STEP2_START="第二步：配置並應用 BBR 擁塞控制..."
            TXT_STEP2_VERIFY="當前 BBR 狀態驗證："
            TXT_STEP2_OK="第二步：BBR 配置已寫入並生效！"
            TXT_STEP3_START="第三步：正在下載並安裝 3x-ui 面板..."
            TXT_STEP3_OK="第三步：3x-ui 面板安裝腳本執行完畢！"
            TXT_ALL_OK="所有步驟已全部全自動執行完畢！"
            TXT_BYE="感謝使用 KURAK，再見！"
            TXT_PAUSE="按 [Enter] 鍵返回選單..."
            TXT_SHORTCUT_CREATED="快捷命令已安裝：在終端輸入 %s 即可隨時開啟選單！"
            ;;
        en)
            TXT_TITLE="KURAK - Linux Automation & 3x-ui Deployment Tool"
            TXT_OS="OS"
            TXT_KERNEL="Kernel"
            TXT_IP="Public IP"
            TXT_MEM="Memory"
            TXT_UPTIME="Uptime"
            TXT_ALIAS="Shortcut"
            TXT_MENU_HEADER="Core Automated Workflow"
            TXT_OPT_ALL="One-Click Full Automation (Steps 1 + 2 + 3)"
            TXT_OPT_ALL_DESC="Auto run update, enable BBR, and install 3x-ui"
            TXT_OPT_STEP1="Step 1: System & Package Upgrade"
            TXT_OPT_STEP1_DESC="apt update && apt upgrade -y"
            TXT_OPT_STEP2="Step 2: Enable BBR Congestion Control"
            TXT_OPT_STEP2_DESC="Write 99-bbr.conf and verify status"
            TXT_OPT_STEP3="Step 3: Install 3x-ui Panel"
            TXT_OPT_STEP3_DESC="Execute official 3x-ui installer"
            TXT_OPT_EXIT="Exit"
            TXT_PROMPT="Please select an option [0-4]: "
            TXT_STEP1_START="Step 1: Updating and upgrading system packages..."
            TXT_STEP1_OK="Step 1: System upgrade completed!"
            TXT_STEP2_START="Step 2: Configuring and enabling BBR..."
            TXT_STEP2_VERIFY="Current BBR status:"
            TXT_STEP2_OK="Step 2: BBR enabled and verified!"
            TXT_STEP3_START="Step 3: Downloading and installing 3x-ui panel..."
            TXT_STEP3_OK="Step 3: 3x-ui installation completed!"
            TXT_ALL_OK="All steps executed successfully!"
            TXT_BYE="Thank you for using KURAK. Goodbye!"
            TXT_PAUSE="Press [Enter] to return to menu..."
            TXT_SHORTCUT_CREATED="Shortcut installed: type %s anytime to launch!"
            ;;
        cn|*)
            TXT_TITLE="KURAK - Linux 自动化运维与 3x-ui 部署工具"
            TXT_OS="操作系统"
            TXT_KERNEL="内核"
            TXT_IP="外网 IP"
            TXT_MEM="内存"
            TXT_UPTIME="运行时间"
            TXT_ALIAS="快捷指令"
            TXT_MENU_HEADER="核心自动化部署"
            TXT_OPT_ALL="一键全自动执行 (步骤 1 + 2 + 3)"
            TXT_OPT_ALL_DESC="自动依次完成系统升级、开启 BBR 与安装 3x-ui"
            TXT_OPT_STEP1="第一步：系统与软件包更新"
            TXT_OPT_STEP1_DESC="apt update && apt upgrade -y"
            TXT_OPT_STEP2="第二步：配置并启用 BBR"
            TXT_OPT_STEP2_DESC="写入 99-bbr.conf 并立即应用验证"
            TXT_OPT_STEP3="第三步：一键安装 3x-ui 面板"
            TXT_OPT_STEP3_DESC="执行官方 3x-ui 安装脚本"
            TXT_OPT_EXIT="退出脚本"
            TXT_PROMPT="请输入选项数字 [0-4]: "
            TXT_STEP1_START="第一步：正在执行系统与软件包更新..."
            TXT_STEP1_OK="第一步：系统更新完成！"
            TXT_STEP2_START="第二步：配置并应用 BBR 拥塞控制..."
            TXT_STEP2_VERIFY="当前 BBR 状态验证："
            TXT_STEP2_OK="第二步：BBR 配置已写入并生效！"
            TXT_STEP3_START="第三步：正在下载并安装 3x-ui 面板..."
            TXT_STEP3_OK="第三步：3x-ui 面板安装脚本执行完毕！"
            TXT_ALL_OK="所有步骤已全部全自动执行完毕！"
            TXT_BYE="感谢使用 KURAK，再见！"
            TXT_PAUSE="按 [Enter] 键返回主菜单..."
            TXT_SHORTCUT_CREATED="快捷命令已建立：在终端输入 %s 即可随时开启！"
            ;;
    esac
}
set_language_strings

# 权限校验
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${CLR_RED}[ERROR] 该脚本需要 root 权限，请使用 sudo 或切换至 root 用户执行！${CLR_RESET}" >&2
        exit 1
    fi
}

# 自动安装与快捷方式配置
ensure_installed() {
    mkdir -p "$INSTALL_DIR"
    echo "LANG_MODE=\"${LANG_MODE}\"" > "$CONFIG_FILE"

    local current_script=""
    if [ -f "$0" ] && [[ "$0" != *"/dev/fd/"* ]]; then
        current_script="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
    fi

    if [ "$current_script" != "$SCRIPT_PATH" ]; then
        if [ -n "$current_script" ] && [ -f "$current_script" ]; then
            cp -f "$current_script" "$SCRIPT_PATH" 2>/dev/null || true
        fi

        chmod +x "$SCRIPT_PATH" 2>/dev/null || true

        cat << EOF > /usr/local/bin/${DEFAULT_ALIAS}
#!/usr/bin/env bash
exec bash "${SCRIPT_PATH}" "\$@"
EOF
        chmod +x /usr/local/bin/${DEFAULT_ALIAS}
        ln -sf /usr/local/bin/${DEFAULT_ALIAS} /usr/bin/${DEFAULT_ALIAS} 2>/dev/null || true

        # 兼容单字母快捷键 k
        ln -sf /usr/local/bin/${DEFAULT_ALIAS} /usr/local/bin/k 2>/dev/null || true
        ln -sf /usr/local/bin/${DEFAULT_ALIAS} /usr/bin/k 2>/dev/null || true

        printf "${CLR_GREEN}[OK] ${TXT_SHORTCUT_CREATED}${CLR_RESET}\n" "${DEFAULT_ALIAS} (或 k)"
    fi
}

# 系统与网络信息获取
sys_get_os_info() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$PRETTY_NAME"
    else
        echo "Linux"
    fi
}

sys_get_mem_usage() {
    if command -v free >/dev/null 2>&1; then
        local mem_used=$(free -m | awk '/Mem:/ {print $3}')
        local mem_total=$(free -m | awk '/Mem:/ {print $2}')
        if [ -n "$mem_used" ] && [ -n "$mem_total" ]; then
            echo "${mem_used}MB / ${mem_total}MB"
            return
        fi
    fi
    echo "N/A"
}

sys_get_ip() {
    local ip=""
    ip=$(curl -s4m 2 ip.sb 2>/dev/null)
    [ -z "$ip" ] && ip=$(curl -s4m 2 ifconfig.me 2>/dev/null)
    [ -z "$ip" ] && ip=$(curl -s4m 2 icanhazip.com 2>/dev/null)
    [ -z "$ip" ] && ip="Unknown"
    echo "$ip"
}

# 顶部 Banner
ui_banner() {
    clear
    local sys_os=$(sys_get_os_info)
    local sys_kernel=$(uname -r)
    local sys_arch=$(uname -m)
    local sys_ip=$(sys_get_ip)
    local sys_mem=$(sys_get_mem_usage)
    local sys_uptime=$(uptime -p 2>/dev/null || uptime | awk -F'( |,|:)+' '{print $6,$7",",$8,"hours"}')

    echo -e "${CLR_CYAN}======================================================================${CLR_RESET}"
    echo -e "${CLR_BOLD}${CLR_CYAN}       _  ___   _ ____      _    _  __                                ${CLR_RESET}"
    echo -e "${CLR_BOLD}${CLR_CYAN}      | |/ / | | |  _ \    / \  | |/ /                                ${CLR_RESET}"
    echo -e "${CLR_BOLD}${CLR_CYAN}      | ' /| | | | |_) |  / _ \ | ' /                                 ${CLR_RESET}"
    echo -e "${CLR_BOLD}${CLR_CYAN}      | . \| |_| |  _ <  / ___ \| . \                                 ${CLR_RESET}"
    echo -e "${CLR_BOLD}${CLR_CYAN}      |_|\_\\___/|_| \_\/_/   \_\_|\_\                                ${CLR_RESET}"
    echo -e "${CLR_CYAN}======================================================================${CLR_RESET}"
    echo -e "  ${CLR_BOLD}${TXT_OS}${CLR_RESET}: ${CLR_GREEN}${sys_os}${CLR_RESET} (${sys_arch})  |  ${CLR_BOLD}${TXT_KERNEL}${CLR_RESET}: ${sys_kernel}"
    echo -e "  ${CLR_BOLD}${TXT_IP}${CLR_RESET}: ${CLR_YELLOW}${sys_ip}${CLR_RESET}  |  ${CLR_BOLD}${TXT_MEM}${CLR_RESET}: ${sys_mem}"
    echo -e "  ${CLR_BOLD}${TXT_UPTIME}${CLR_RESET}: ${sys_uptime}  |  ${CLR_BOLD}${TXT_ALIAS}${CLR_RESET}: ${CLR_GREEN}${DEFAULT_ALIAS}${CLR_RESET} (k)"
    echo -e "${CLR_CYAN}======================================================================${CLR_RESET}"
}

# 菜单项输出
ui_menu_item() {
    local key="$1"
    local title="$2"
    local desc="$3"
    if [ -n "$desc" ]; then
        printf "  ${CLR_CYAN}[%2s]${CLR_RESET} %-36b ${CLR_DIM}%s${CLR_RESET}\n" "$key" "$title" "$desc"
    else
        printf "  ${CLR_CYAN}[%2s]${CLR_RESET} %b\n" "$key" "$title"
    fi
}

ui_pause() {
    echo ""
    read -rp "$TXT_PAUSE" dummy
}

# 步骤 1：系统更新 (完全自动化静默模式，自动跳过 needrestart 弹窗)
step1_update() {
    echo -e "${CLR_BLUE}[INFO] ${TXT_STEP1_START}${CLR_RESET}"

    # 禁用任何交互式弹窗
    export DEBIAN_FRONTEND=noninteractive
    export NEEDRESTART_MODE=a
    export NEEDRESTART_SUSPEND=1

    # 如果系统安装了 needrestart，配置其自动重启服务而不弹出 UI 窗口
    if [ -f /etc/needrestart/needrestart.conf ]; then
        sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf 2>/dev/null || true
        sed -i "s/\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf 2>/dev/null || true
    fi

    apt update && apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade -y
    echo -e "${CLR_GREEN}[OK] ${TXT_STEP1_OK}${CLR_RESET}"
}

# 步骤 2：启用 BBR
step2_bbr() {
    echo -e "${CLR_BLUE}[INFO] ${TXT_STEP2_START}${CLR_RESET}"
    cat >/etc/sysctl.d/99-bbr.conf <<'EOF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
    sysctl --system
    echo -e "${CLR_GREEN}${TXT_STEP2_VERIFY}${CLR_RESET}"
    sysctl net.ipv4.tcp_congestion_control
    echo -e "${CLR_GREEN}[OK] ${TXT_STEP2_OK}${CLR_RESET}"
}

# 步骤 3：安装 3x-ui (指定端口 39000，其余配置全自动静默默认)
step3_3xui() {
    echo -e "${CLR_BLUE}[INFO] ${TXT_STEP3_START}${CLR_RESET}"
    if ! command -v curl >/dev/null 2>&1; then
        apt update -y && apt install -y curl
    fi

    # 注入全自动环境变量：指定端口 39000，其余全自动采用官方默认值
    export XUI_NONINTERACTIVE=1
    export XUI_DB_TYPE="sqlite"
    export XUI_PANEL_PORT="39000"
    export XUI_SSL_MODE="none"

    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
    echo -e "${CLR_GREEN}[OK] ${TXT_STEP3_OK}${CLR_RESET}"
}

# 一键全自动执行 1 + 2 + 3
run_all_steps() {
    echo -e "${CLR_CYAN}======================================================================${CLR_RESET}"
    echo -e "                   ${CLR_BOLD}${TXT_OPT_ALL}${CLR_RESET}"
    echo -e "${CLR_CYAN}======================================================================${CLR_RESET}"
    step1_update
    echo ""
    step2_bbr
    echo ""
    step3_3xui
    echo ""
    echo -e "${CLR_GREEN}======================================================================${CLR_RESET}"
    echo -e "   ${CLR_BOLD}[OK] ${TXT_ALL_OK}${CLR_RESET}"
    echo -e "${CLR_GREEN}======================================================================${CLR_RESET}"
}

# 交互式主菜单
main_menu() {
    while true; do
        ui_banner
        echo -e "${CLR_CYAN}---------------------------- [ ${TXT_MENU_HEADER} ] ------------------------${CLR_RESET}"
        ui_menu_item "1" "${TXT_OPT_ALL}" "${TXT_OPT_ALL_DESC}"
        echo -e "${CLR_CYAN}---------------------------- [ 分步操作 ] ----------------------------${CLR_RESET}"
        ui_menu_item "2" "${TXT_OPT_STEP1}" "${TXT_OPT_STEP1_DESC}"
        ui_menu_item "3" "${TXT_OPT_STEP2}" "${TXT_OPT_STEP2_DESC}"
        ui_menu_item "4" "${TXT_OPT_STEP3}" "${TXT_OPT_STEP3_DESC}"
        echo -e "${CLR_CYAN}----------------------------------------------------------------------${CLR_RESET}"
        ui_menu_item "0" "${TXT_OPT_EXIT}" ""
        echo -e "${CLR_CYAN}======================================================================${CLR_RESET}"
        read -rp "$TXT_PROMPT" choice

        case "$choice" in
            1) run_all_steps; ui_pause ;;
            2) step1_update; ui_pause ;;
            3) step2_bbr; ui_pause ;;
            4) step3_3xui; ui_pause ;;
            0)
                echo -e "${CLR_GREEN}${TXT_BYE}${CLR_RESET}"
                exit 0
                ;;
            *)
                echo -e "${CLR_YELLOW}Invalid choice.${CLR_RESET}"
                sleep 1
                ;;
        esac
    done
}

# CLI 命令行快捷分发
cli_dispatch() {
    case "$1" in
        1|auto|all)
            run_all_steps
            ;;
        update|upgrade|2)
            step1_update
            ;;
        bbr|3)
            step2_bbr
            ;;
        3x-ui|3xui|ui|4)
            step3_3xui
            ;;
        -v|--version)
            echo "${APP_NAME} v${APP_VERSION}"
            ;;
        -h|--help|help)
            echo "Usage: ${DEFAULT_ALIAS} [tw|cn|en] [1|2|3|4|update|bbr|3x-ui]"
            echo ""
            echo "Options:"
            echo "  ${DEFAULT_ALIAS} 1 (or auto)     Run all 3 steps automatically"
            echo "  ${DEFAULT_ALIAS} update          Step 1: apt update && apt upgrade -y"
            echo "  ${DEFAULT_ALIAS} bbr             Step 2: Enable BBR congestion control"
            echo "  ${DEFAULT_ALIAS} 3x-ui           Step 3: Install 3x-ui panel"
            echo "  ${DEFAULT_ALIAS} tw              Run in Traditional Chinese (繁體中文)"
            echo "  ${DEFAULT_ALIAS} en              Run in English"
            echo ""
            echo "Run without parameters to open interactive menu."
            ;;
        *)
            main_menu
            ;;
    esac
}

# 快速帮助与版本判断 (无需 root 权限)
if [ "${1:-}" = "-v" ] || [ "${1:-}" = "--version" ]; then
    echo "${APP_NAME} v${APP_VERSION}"
    exit 0
elif [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] || [ "${1:-}" = "help" ]; then
    echo "Usage: ${DEFAULT_ALIAS} [tw|cn|en] [1|2|3|4|update|bbr|3x-ui]"
    echo ""
    echo "Options:"
    echo "  ${DEFAULT_ALIAS} 1 (or auto)     Run all 3 steps automatically"
    echo "  ${DEFAULT_ALIAS} update          Step 1: apt update && apt upgrade -y"
    echo "  ${DEFAULT_ALIAS} bbr             Step 2: Enable BBR congestion control"
    echo "  ${DEFAULT_ALIAS} 3x-ui           Step 3: Install 3x-ui panel"
    echo "  ${DEFAULT_ALIAS} tw              Run in Traditional Chinese (繁體中文)"
    echo "  ${DEFAULT_ALIAS} en              Run in English"
    echo ""
    echo "Run without parameters to open interactive menu."
    exit 0
fi

# 程序入口
check_root
ensure_installed

if [ $# -gt 0 ]; then
    cli_dispatch "$@"
else
    main_menu
fi
