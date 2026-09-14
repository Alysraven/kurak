# 🤖 KURAK 项目 Agent 交接文档 (Handover Document)

> **文档生成时间**：2026-09-14  
> **文档适用对象**：后续接手本项目开发的任意 AI Agent / 开发者  
> **核心目的**：确保在新会话（New Chat）中无需重复背景沟通，100% 无缝继承所有需求约束、架构设计、技术决策与开发进度。

---

## 1. 项目基本信息与核心铁律 (CRITICAL RULES)

- **项目名称**：`KURAK`
- **核心脚本名**：`kurak.sh`
- **项目根目录**：`d:\Syncthing\Project\kurak`
- **GitHub 仓库**：`https://github.com/Alysraven/kurak.git`
- **GitHub 作者账号**：`Alysraven`
- **GitHub 绑定邮箱**：`372339528@qq.com`
- **原版历史备份**：`d:\Syncthing\Project\kejilion-sh-v0`（独立存档，已与本项目彻底物理隔离）

> [!CAUTION]
> ### 🚨 第一铁律：绝对去痕化
> **代码库、脚本内容、提交日志 (Commit Messages)、文档 (README/注释)、链接中，绝对不能出现任何 `kejilion` 相关的字眼或痕迹！**  
> 所有组件与命名必须严格统一为 `kurak`。

---

## 2. 系统架构与文件清单

项目采用**零外部依赖、轻量单文件 POSIX / Bash 架构**设计：

| 文件路径 | 说明 |
| :--- | :--- |
| `kurak.sh` | **核心可执行脚本**（约 570 行）。集成了系统检测、多语言支持、全自动三步流水线、TG 通知、防火墙容错、彻底卸载等全部功能。 |
| `install.sh` | **远程引导安装程序**。负责从 GitHub 拉取 `kurak.sh`，部署到 `/usr/local/share/kurak` 并自动创建全局软链接。 |
| `README.md` | **项目对外说明文档**。包含一键安装命令、CLI 使用字典、语言参数说明、TG 通知配置指南。 |
| `.gitattributes` | **Git 跨平台换行符规范**。强制 `*.sh` 采用 Linux `LF` 换行符，防止 Windows 编辑污染导致 Linux 报 `\r` 语法错误。 |

---

## 3. 核心功能与技术实现细节

### 3.1 全自动核心工作流（1 键执行 1 + 2 + 3）

脚本核心业务为标准 3 步自动化流程：

1. **步骤 1：系统更新升级 (`step1_update`)**
   - **静默化与防卡顿**：注入 `DEBIAN_FRONTEND=noninteractive`、`NEEDRESTART_MODE=a`、`NEEDRESTART_SUSPEND=1`；自动将 `/etc/needrestart/needrestart.conf` 改为自动重启模式，**彻底消除 Ubuntu 22.04+ 的粉灰色服务重启交互弹窗**。
   - **APT 原生锁等待**：采用 `-o DPkg::Lock::Timeout=60`。遇锁底层自动排队，无锁 0 延迟秒级执行，不误判常驻进程。
   - **执行命令**：`apt-get update -y ... && apt-get upgrade -y ...`

2. **步骤 2：启用 BBR 拥塞控制 (`step2_bbr`)**
   - 写入 `/etc/sysctl.d/99-bbr.conf`：
     ```ini
     net.core.default_qdisc=fq
     net.ipv4.tcp_congestion_control=bbr
     ```
   - 执行 `sysctl --system` 即刻生效（现代 Linux 内核无需重启 VPS）。

3. **步骤 3：部署 3x-ui 官方最新版 (`step3_3xui`)**
   - **官方源**：采用 `https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh`。
   - **全自动注入环境变量**：
     - `export XUI_NONINTERACTIVE=1`（跳过所有终端提问）
     - `export XUI_DB_TYPE="sqlite"`（默认选用 SQLite 数据库）
     - `export XUI_PANEL_PORT="39000"`（**固定面板端口为 39000**）
     - `export XUI_SSL_MODE="ip"`（**默认选用官方 IP 证书**，通过 Let's Encrypt 自动为服务器公网 IP 签发 https 证书）
   - **安全性**：**不硬编码密码**。由 3x-ui 官方在 VPS 本地动态生成高强度随机账号密码，保存在 `/etc/x-ui/install-result.env`，开源仓库绝无泄露风险。
   - **服务守护自愈**：安装后主动触发 `systemctl daemon-reload && systemctl enable x-ui` 并校验活跃状态。

### 3.2 Telegram Bot 凭据推送模块 (`send_tg_notification`)

- **功能**：3x-ui 部署完成后，自动读取 `/etc/x-ui/install-result.env`，将 IP、端口 39000、随机账号、随机密码、安全访问 URL 打包通过 Telegram Bot API 推送至用户手机。
- **两种运行模式**：
  - **模式 A（即用即抛，最安全）**：
    `TG_TOKEN="xxx" TG_CHAT_ID="yyy" bash <(curl -sL https://raw.githubusercontent.com/Alysraven/kurak/main/kurak.sh) 1`
  - **模式 B（本地持久化）**：
    执行 `kurak tg` 或菜单 `[ 5 ]`，将凭据保存在本地 `/usr/local/share/kurak/config.env`（权限 `600`，仅 root 可读，绝不上传 GitHub）。

### 3.3 防火墙策略 (`auto_configure_firewall`)

- **设计原则**：**静默容错，不主动干扰**。
- 绝大多数云主机（GCP/AWS等）默认防火墙为 inactive，网络默认全通，脚本不执行任何多余操作；
- 仅当检测到 `ufw status` 显式为 `Status: active` 时，才自动静默放行 `22/tcp`、`80/tcp`、`443/tcp`、`39000/tcp`。

### 3.4 一键彻底卸载模块 (`uninstall_all`)

- 命令直达：`kurak uninstall` 或 `kurak 9`。
- 停止并注销 `x-ui` 服务，清理 `/usr/local/x-ui`、`/etc/x-ui`、服务单元及 `kurak` 全局快捷键，使系统完全复原。

### 3.5 SSH Root 密码登录配置模块 (`enable_root_login`)

- 命令直达：`kurak root` 或 `kurak ssh` 或 `kurak 6`（支持无交互传参：`kurak root [新密码]`）。
- 菜单直达：`[ 6 ] 开启 SSH Root 密码登录`。
- **底层执行细节**：
  1. 自动备份 `/etc/ssh/sshd_config`；
  2. 自动开启 `PermitRootLogin yes`、`PasswordAuthentication yes`、`KbdInteractiveAuthentication yes`；
  3. 深度兼容云厂商：针对 GCP、AWS 等包含 `/etc/ssh/sshd_config.d/*.conf`（如 `50-cloud-init.conf`）的覆盖配置同步强制开启；
  4. 重启系统 SSH 服务 (`systemctl restart sshd || restart ssh`)；
  5. 引导用户安全设置/修改 root 密码（支持非交互一键传参重置）。

---

## 4. 关键踩坑与重要决策复盘 (DECISION LOG)

新 Agent 在后续修改代码时，**切忌重踩以下历史深坑**：

1. **APT 进程锁误判问题（重点避坑！）**
   - **历史现象**：此前手写了 `pgrep -f "(apt-get|dpkg|unattended-upgrades)"` 循环检测锁，导致每次运行都误报“检测到后台更新”并强行卡顿等待 60 秒超时。
   - **根本原因**：Ubuntu 22.04 默认常驻守护进程 `/usr/bin/python3 ... unattended-upgrade-shutdown --wait-for-signal`，名字包含 `unattended-upgrades` 但平时完全不持锁。
   - **正确做法**：**坚决不要用正则 pgrep 猜测系统锁！** 必须统一使用 APT 原生参数 `-o DPkg::Lock::Timeout=60`。

2. **3x-ui SSL 证书模式选定**
   - 官方支持 4 种模式：`domain`(1)、`ip`(2)、`custom`(3)、`none`(4)。
   - 用户明确要求：**“不要跳过 ssl，按默认的来”**。
   - 官方非交互默认模式为 `export XUI_SSL_MODE="ip"`，会自动通过 acme.sh 申请短效 IP 证书并启用 https。

3. **快捷键软链接规范**
   - 全局安装软链接：`/usr/local/bin/kurak`、`/usr/local/bin/k` 以及 `/usr/bin/kurak`、`/usr/bin/k`。
   - 用户在服务器任意终端直接敲 `kurak` 或单字母 `k` 均可唤出交互菜单。

---

## 5. Git 状态与历史提交基线

当前仓库已通过 `git push origin main` 同步至最新状态。关键提交日志如下：

```text
96d0217 fix: remove false-positive wait_for_apt_lock and use APT native DPkg::Lock::Timeout
70485fc refactor: optimize firewall handling to be passive and non-intrusive
f8aedae fix: add apt lock waiting mechanism and auto firewall opening (port 39000)
1e36cc3 feat: add uninstall command and menu option
9076bd2 feat: enable default IP SSL certificate for 3x-ui in auto install
c404437 feat: add secure telegram bot notification on 3x-ui deployment completion
d65e912 feat: configure 3x-ui non-interactive auto install with port 39000
04244c7 feat: bypass needrestart interactive dialogs in step1
07ae5ca feat: initial standalone kurak script with multi-language and auto-installer
```

---

## 6. 后续接手常见任务与指引 (For Next Agent)

若用户在新会话中提出进一步需求，请参考以下指引：

1. **若用户需要新增菜单功能**：
   - 在 `kurak.sh` 的 `TXT_OPT_xxx` 多语言字典中补全 `cn`、`tw`、`en` 的文字定义；
   - 在 `main_menu()` 增加菜单序号，在 `cli_dispatch()` 增加对应的命令行直达别名。
2. **若用户需要指定特定的 3x-ui 版本（如固定为 v3.4.0）**：
   - 3x-ui 官方 `install.sh` 支持传参 `install.sh <tag>`，可在调用时将版本参数作为变量追加。
3. **若用户需要修改端口或增加预设入站节点配置**：
   - 端口通过 `XUI_PANEL_PORT` 控制；
   - 安装完成后，如需配置 Xray 节点，可通过 `/usr/local/x-ui/x-ui` CLI 工具或直接操作 `/etc/x-ui/x-ui.db` SQLite 数据库。
4. **代码提交规范**：
   - 无论在 Windows 本地如何修改，务必确保文件以 `LF` 换行符保存；
   - Git 提交前必须用 `bash -n kurak.sh` 检查语法；
   - 保持提交作者为 `Alysraven <372339528@qq.com>`。
