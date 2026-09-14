# 📜 KURAK 项目历史对话与开发决策全景记录 (Conversation & Decision History)

> **项目名称**：KURAK (`kurak.sh`)  
> **所属仓库**：`https://github.com/Alysraven/kurak.git`  
> **项目作者**：`Alysraven <372339528@qq.com>`  
> **时间跨度**：2026-09-03 ~ 2026-09-14  

---

## 目录
1. [阶段一：项目立项、彻底去痕与全新独立架构](#阶段一项目立项彻底去痕与全新独立架构)
2. [阶段二：Git 仓库重构、身份纠偏与首次发布](#阶段二git-仓库重构身份纠偏与首次发布)
3. [阶段三：Debian/Ubuntu needrestart 交互弹窗完全绕过](#阶段三debianubuntu-needrestart-交互弹窗完全绕过)
4. [阶段四：3x-ui 官方无人值守集成与端口 39000 定制](#阶段四3x-ui-官方无人值守集成与端口-39000-定制)
5. [阶段五：开源安全性论证与 Telegram Bot 凭据推送](#阶段五开源安全性论证与-telegram-bot-凭据推送)
6. [阶段六：代码私有化保护与极简安装权衡探讨](#阶段六代码私有化保护与极简安装权衡探讨)
7. [阶段七：恢复官方默认 IP SSL 证书加密模式](#阶段七恢复官方默认-ip-ssl-证书加密模式)
8. [阶段八：增加一键彻底卸载与环境清理能力](#阶段八增加一键彻底卸载与环境清理能力)
9. [阶段九：Google Cloud 云主机 APT 锁误报 Bug 彻底根除](#阶段九google-cloud-云主机-apt-锁误报-bug-彻底根除)

---

## 阶段一：项目立项、彻底去痕与全新独立架构

### 用户诉求：
1. 新建脚本命名为 `kurak.sh`。
2. **严正要求**：整个代码库、注释、提交历史、文档中，**绝对不要有任何原版项目（kejilion）相关的字眼和信息**。
3. 核心功能精简为一键全自动顺序执行 3 个步骤：
   - 步骤 1：系统更新升级 (`apt update && apt upgrade -y`)
   - 步骤 2：启用 BBR 拥塞控制 (`net.ipv4.tcp_congestion_control=bbr`)
   - 步骤 3：安装 3x-ui 官方控制面板
4. 支持多语言（`tw` 繁体中文、`en` 英文、默认简体中文），并支持简短获取链接。

### 开发与决策：
- 将原版完整备份至隔离目录 `d:\Syncthing\Project\kejilion-sh-v0`。
- 在 `d:\Syncthing\Project\kurak` 全新手工编写纯净的单文件 `kurak.sh`，实现内置多语言字典、CLI 命令行参数分发（`kurak 1`、`kurak bbr` 等）、以及自动创建全局软链接（`kurak` 与 `k`）。
- 编写 `install.sh` 远程引导安装程序与 `.gitattributes`（强制 Linux `LF` 换行符）。

---

## 阶段二：Git 仓库重构、身份纠偏与首次发布

### 发现问题：
- 用户反馈首次提交作者显示为 `root <root@localhost>`（"这个人不是我"）。
- 用户提供真实 GitHub 账号信息：`Alysraven`，邮箱：`372339528@qq.com`。

### 解决方案：
- 使用 `git rebase` / `filter-branch` 彻底重写提交历史，将 Author 与 Committer 修正为 `Alysraven <372339528@qq.com>`。
- 用户重置远程仓库后，强制推送 `main` 分支及标签 `v1.0.0` 至 `https://github.com/Alysraven/kurak.git`。
- 为用户解释了 Git 推送鉴权原理（Git Credential Manager 与 Personal Access Token 的保护机制）。

---

## 阶段三：Debian/Ubuntu needrestart 交互弹窗完全绕过

### 现场问题：
- 用户在 Ubuntu 22.04+ 服务器上运行 `kurak.sh` 第一步时，终端弹出了粉灰色的 ncurses 交互界面：
  `Daemons using outdated libraries - Which services should be restarted?`
  阻塞了全自动流水线。
- 用户询问：“这个界面有办法自动化确认或跳过吗？第二步是勾选所有然后重启吗？”

### 答疑与技术攻关：
1. **即时指导**：
   - 当前弹窗无需全选，全选可能因重启 `dbus` / `systemd-logind` 导致 SSH 会话强行掉线。直接回车确认 `<Ok>` 即可。
   - BBR 配置写在 `/etc/sysctl.d/99-bbr.conf`，通过 `sysctl --system` 即刻在内存生效，现代内核**完全无需重启服务器**。
2. **代码级自动化消除**：
   在 `step1_update()` 中注入非交互环境变量与 needrestart 静默重写：
   ```bash
   export DEBIAN_FRONTEND=noninteractive
   export NEEDRESTART_MODE=a
   export NEEDRESTART_SUSPEND=1
   if [ -f /etc/needrestart/needrestart.conf ]; then
       sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf 2>/dev/null || true
   fi
   ```
   **效果**：`apt upgrade` 以后遇到服务重启提问一律全自动静默通过，0 弹窗打扰。

---

## 阶段四：3x-ui 官方无人值守集成与端口 39000 定制

### 用户诉求：
- 用户在运行第三步安装 3x-ui 时，官方脚本弹出了交互提问：
  - 数据库选择 (SQLite / PostgreSQL)
  - 是否自定义面板端口
  - 用户名、密码、路径设置
- 用户提出：“这里有办法让他也自动吗？只有端口指定 39000，其他默认。”

### 技术实现：
- 深入挖掘 [MHSanaei/3x-ui](https://github.com/MHSanaei/3x-ui) 的 `install.sh` 源码，发现其官方原生支持环境变量无人值守模式：
  ```bash
  export XUI_NONINTERACTIVE=1
  export XUI_DB_TYPE="sqlite"
  export XUI_PANEL_PORT="39000"
  ```
- 当未传递 `XUI_USERNAME` 和 `XUI_PASSWORD` 时，3x-ui 会在 VPS 本地调用随机算法生成高熵 10 位安全账号密码，并写入 `/etc/x-ui/install-result.env`。
- **效果**：第三步在几秒内完全静默安装完毕，面板端口严格固定为 `39000`。

---

## 阶段五：开源安全性论证与 Telegram Bot 凭据推送

### 用户疑问：
- “如果把账号密码也写进去，我的代码是开源的岂不是很危险？”
- “我如何安全地设置这个自动化，完成后给我的 tgbot 发送 3xui 的链接以及账号密码？”

### 架构设计与安全性保障：
1. **密码安全性论证**：
   - 肯定用户的敏锐安全意识。我们在代码中**绝对没有硬编码任何密码**，账号密码是 VPS 随机生成的，仅保存在用户自己的服务器上，GitHub 没有任何记录。
2. **Telegram 凭据推送模块 (`send_tg_notification`)**：
   - 脚本安装完后，自动从 `/etc/x-ui/install-result.env` 提取凭据。
   - **安全调用方式（环境变量注入，不入库）**：
     ```bash
     TG_TOKEN="你的BotToken" TG_CHAT_ID="你的ChatID" bash <(curl -sL ...) 1
     ```
   - 脚本执行完成瞬间，Telegram Bot 发送精美卡片消息（包含公网 IP、端口 39000、随机账号密码、安全入口 URL），手机立即“叮咚”收到。

---

## 阶段六：代码私有化保护与极简安装权衡探讨

### 用户探讨：
- “我不想别人看到我的代码，我又想一键安装该如何操作？”
- “方案二（Cloudflare Worker）是不是后缀要保密？”

### 方案分析对比：
1. **方案一（GitHub Private + Token）**：最原生正统。在 curl 中增加 `-H "Authorization: token ghp_xxx"`。
2. **方案二（Cloudflare Worker 代理）**：最优雅短小。将 GitHub 设为 Private，Token 存放在 Cloudflare 后台，对外暴露带暗号的短链（如 `https://xxx.workers.dev/mysecret`）。
   - **确认**：后缀就是访问密码。未带暗号或暗号错误一律返回 404，外人完全无法扫描或看到代码。
3. **方案三（GitHub Secret Gist）**：利用 32 位无序 Hash 隐身免 Token 访问。

---

## 阶段七：恢复官方默认 IP SSL 证书加密模式

### 用户诉求：
- 用户注意到终端出现黄色警告：`SSL Certificate: Skipped - panel is HTTP-only`。
- 用户指令：“不要跳过 ssl，按默认的来”。

### 技术调整：
- 原配置中 `XUI_SSL_MODE="none"` 会跳过 SSL。
- 3x-ui 官方默认推荐为 `2) IP certificate`（基于 Let's Encrypt 申请短效 IP 证书）。
- 将环境变量调整为：
  ```bash
  export XUI_SSL_MODE="ip"
  ```
- **效果**：全自动通过 acme.sh 为服务器公网 IP 签发免费 SSL 证书，面板访问协议全面升级为 `https://`，浏览器显示安全绿锁。

---

## 阶段八：增加一键彻底卸载与环境清理能力

### 用户诉求：
- “如何卸载脚本然后重新安装？”

### 功能实现：
- 在 `kurak.sh` 中新增一键卸载模块 `uninstall_all()`，并接入命令行直达与菜单交互：
  - 命令行：`kurak uninstall` / `kurak 9`
  - 菜单：`[ 9 ] 彻底卸载 3x-ui 与本脚本`
- **执行动作**：停止并注销 systemd `x-ui.service`，清空 `/usr/local/x-ui`、`/etc/x-ui`，删除 `/usr/local/bin` 和 `/usr/bin` 下的快捷链接（`kurak`、`k`），使系统干干净净复原。

---

## 阶段九：Google Cloud 云主机 APT 锁误报 Bug 彻底根除

### 故障重现与排查：
- 用户反馈：“搭建好的 3xui 面板连不上，手动安装了一遍才好了”。
- 伴随日志分析：
  1. 日志中显示 Google Cloud 镜像后台运行了 `unattended-upgrades`（PID 1374, PID 1995），占用 dpkg 锁；
  2. 3x-ui 在安装 `fail2ban` 时被锁卡住，终端停留在 `Setting up systemd unit...`；
  3. 用户误以为卡死按了 `^C`（Ctrl+C），导致服务未正常启动；
  4. 用户随后手动执行了 `ufw allow` 和手动重新安装 3x-ui。
- 用户关键反思：“防火墙是我自己手动加的，因为打不开我以为是防火墙的问题，其实不用加，默认是通的”。

### 再次出现的致命误判（False Positive）：
- 此前尝试用 `pgrep -f "(apt-get|dpkg|unattended-upgrades)"` 循环检测锁；
- 用户反馈：“我觉得是目前的脚本有问题，每次都是先检测后超时，我手动更新的话就没问题”。
- **根本原因排查**：Ubuntu 22.04 默认常驻守护进程 `/usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal`，名字含有 `unattended-upgrades` 但**根本不持有锁**！手写的 pgrep 导致每次都误判锁存在，硬生生在原地卡顿死等整整 60 秒！

### 终极根治方案：
- **彻底废弃手写 pgrep 循环**，采用 APT 官方原生锁机制：
  ```bash
  apt-get update -y -o DPkg::Lock::Timeout=60 && \
  apt-get -o DPkg::Lock::Timeout=60 -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade -y
  ```
- **效果**：平时无锁时 **0 毫秒秒级响应**，立即开始执行；万一发生真实冲突时由 APT 底层原生安全排队，彻底根治 60 秒超时假死现象。
- 将防火墙策略调整为纯静默容错（仅在检测到 UFW active 时放行，默认绝不干预系统）。

---

## 提交记录汇总 (Git History)

| Commit Hash | 提交信息 | 核心改动 |
| :--- | :--- | :--- |
| `07ae5ca` | feat: initial standalone kurak script with multi-language and auto-installer | 建立纯净独立 kurak 框架，去痕化 |
| `04244c7` | feat: bypass needrestart interactive dialogs in step1 | 静默配置消除 needrestart 服务重启粉色弹窗 |
| `d65e912` | feat: configure 3x-ui non-interactive auto install with port 39000 | 3x-ui 非交互静默安装，固定端口 39000 |
| `c404437` | feat: add secure telegram bot notification on 3x-ui deployment completion | 增加 Telegram 部署结果自动推送模块 |
| `9076bd2` | feat: enable default IP SSL certificate for 3x-ui in auto install | 开启官方默认 IP Let's Encrypt SSL 证书 |
| `1e36cc3` | feat: add uninstall command and menu option | 内置 `kurak uninstall` 彻底卸载指令 |
| `f8aedae` | fix: add apt lock waiting mechanism and auto firewall opening (port 39000) | 初步增加锁等待与端口开放 |
| `70485fc` | refactor: optimize firewall handling to be passive and non-intrusive | 将防火墙逻辑优化为被动静默触发 |
| `96d0217` | fix: remove false-positive wait_for_apt_lock and use APT native DPkg::Lock::Timeout | 彻底消除 pgrep 误报，改用 APT 原生超时 |

---
*本文档由 Antigravity 导出生成，作为项目完整的上下文与技术档案永久保存。*
