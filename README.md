# KURAK

面向 Linux 服务器的极简自动化初始化与 3x-ui 部署工具箱。

支持通过参数快速切换语言（`tw` 繁體中文、`en` 英文、`cn` 簡體中文），一键自动配置全局快捷指令 `kurak`。

---

## ⚡ 一键安装与运行

在任意 Linux 服务器（root 用户）终端直接复制执行以下命令：

### 1. 繁體中文版 (`tw`)
```bash
bash <(curl -sL https://raw.githubusercontent.com/Alysraven/kurak/main/kurak.sh) tw
```

### 2. 简体中文版 (默认)
```bash
bash <(curl -sL https://raw.githubusercontent.com/Alysraven/kurak/main/kurak.sh)
```

### 3. English Version (`en`)
```bash
bash <(curl -sL https://raw.githubusercontent.com/Alysraven/kurak/main/kurak.sh) en
```

### 4. 一键全自动执行 (自动安装 + 自动发 TG 通知)
```bash
TG_TOKEN="你的BotToken" TG_CHAT_ID="你的ChatID" bash <(curl -sL https://raw.githubusercontent.com/Alysraven/kurak/main/kurak.sh) 1
```
*执行完毕后，Telegram 机器人会第一时间将面板链接、账号与密码直接推送到你的手机！*

---

## 🛠️ 快捷命令使用

运行一次后，会自动在系统中生成全局软链接，后续在终端任何目录输入：

```bash
kurak               # 调出交互式操作菜单
# 或者输入单字母快捷键：
k                   # 同样可直接唤出菜单
```

### 命令行直达模式 (CLI)
无需进入菜单，直接带参数秒速执行：

| 命令 | 说明 |
| :--- | :--- |
| `kurak 1` 或 `kurak auto` | **一键全自动顺序执行全部 3 个步骤** |
| `kurak tg` (或 `kurak 5`) | 配置 Telegram 机器人推送凭据 (安全保存在本地) |
| `kurak update` (或 `kurak 2`) | 仅执行第 1 步：系统更新升级 (`apt update && apt upgrade -y`) |
| `kurak bbr` (或 `kurak 3`) | 仅执行第 2 步：配置并启用 BBR 拥塞控制 (`99-bbr.conf`) |
| `kurak 3x-ui` (或 `kurak 4`) | 仅执行第 3 步：下载并安装官方 3x-ui 面板 |
| `kurak tw` | 以繁體中文模式啟動選單 |
| `kurak en` | Launch menu in English |

---

## 📋 核心自动化步骤

1. **第一步：系统与软件包更新**
   ```bash
   apt update && apt upgrade -y
   ```

2. **第二步：配置并启用 BBR 网络加速**
   ```bash
   cat >/etc/sysctl.d/99-bbr.conf <<'EOF'
   net.core.default_qdisc=fq
   net.ipv4.tcp_congestion_control=bbr
   EOF
   sysctl --system
   sysctl net.ipv4.tcp_congestion_control
   ```

3. **第三步：一键安装 3x-ui 面板**
   ```bash
   bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
   ```
