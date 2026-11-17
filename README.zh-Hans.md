<div align="center">

# tmux-extract-revamped

<strong>用 fzf 从屏幕上选取 URL、路径、哈希或其他任何片段，并输入到光标处，纯 shell 实现。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; 简体中文 &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-extract-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-extract-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-extract-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-extract-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-extract-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-extract-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-extract-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#快速开始"><strong>快速开始</strong></a> &nbsp;|&nbsp;
  <a href="#用法">用法</a> &nbsp;|&nbsp;
  <a href="#模式">模式</a> &nbsp;|&nbsp;
  <a href="#界面">界面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="extract-revamped 用 fzf 从构建日志中选取 URL 并输入到提示符" width="800">
</p>

```console
$ EXTRACT_REVAMPED_OPEN_KEY=o extract-revamped list
bind-key M-x display-popup -E -w 80% -h 60% '/home/user/.tmux/plugins/tmux-extract-revamped/bin/extract-revamped' insert '#{pane_id}'
bind-key o display-popup -E -w 80% -h 60% '/home/user/.tmux/plugins/tmux-extract-revamped/bin/extract-revamped' open '#{pane_id}'
```

按下 `prefix M-x`，弹出窗口会在 fzf 中列出屏幕上的所有 URL、路径和单词。选中一个，它就会作为字面文本输入到原窗格的光标处。其他按键可以打开片段、复制片段，或在复制模式中查找它。

---

## 快速开始

### 前提条件

| 工具 | 版本 | 用途 |
|:-----|:--------|:---------|
| tmux | 3.2 或更高 | 弹出窗口 |
| fzf | 任意版本 | 选择器；缺少时 `doctor` 会报告 |
| 打开工具 | 可选 | 用于 URL：macOS 上的 `open`，Linux 上的 `xdg-open` |
| 剪贴板工具 | 可选 | macOS 上的 `pbcopy`，Linux 上的 `wl-copy`、`xclip` 或 `xsel`，或通过 `base64` 的 OSC 52 |
| gum | 可选 | `extract-revamped` 的菜单、表格和颜色；没有它，所有命令都输出纯文本 |

### 安装

```tmux
set -g @plugin 'tmux-revamped/tmux-extract-revamped'
```

然后按 `prefix + I`。不用 TPM 时，克隆仓库，并在 `~/.tmux.conf` 中运行它的入口文件：

```bash
git clone https://github.com/tmux-revamped/tmux-extract-revamped ~/.tmux/plugins/tmux-extract-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-extract-revamped/extract-revamped.tmux
```

在克隆的目录中运行 `make install`，还会把 `extract-revamped` 放进 `~/.local/bin`，把它的 man 手册和补全放在 `~/.local/share` 下。

### 验证

```bash
~/.tmux/plugins/tmux-extract-revamped/bin/extract-revamped doctor
```

## 用法

| 按键 | 作用 | 默认 |
|:----|:-------|:--------|
| `prefix M-x` | 选取片段并输入到光标处 | 已绑定 |
| `@extract_revamped_navigate_key` | 选取片段并在复制模式中查找 | 未绑定 |
| `@extract_revamped_open_key` | 选取片段并打开：URL 在浏览器中，路径在新窗口的 `$EDITOR` 中，其他内容直接输入 | 未绑定 |
| `@extract_revamped_copy_key` | 选取片段并复制 | 未绑定 |
| `@extract_revamped_chooser_key` | 在选择器中选取：`Enter` 输入，`C-o` 打开，`C-y` 复制，`C-n` 切换到下一个模式 | 未绑定 |
| `@extract_revamped_doctor_key` | 在弹出窗口中显示 doctor 报告 | 未绑定 |

`M-x` 是本插件在家族按键分配中的位置。如果你已经自己绑定了 `prefix M-x`，插件会保留它，并由 `doctor` 说明；可把 `@extract_revamped_key` 设为其他按键，或设为 `none` 表示不绑定。

| 命令 | 作用 |
|:--------|:-------------|
| `extract-revamped apply` | 立即绑定按键；插件加载时入口点会运行它 |
| `extract-revamped list` | 打印 apply 会做的每个绑定；`--json` 输出一个对象 |
| `extract-revamped insert`, `navigate`, `open`, `copy`, `choose` `PANE` | 在窗格上运行选择器；按键会在弹出窗口中运行这些命令 |
| `extract-revamped doctor` | 每个依赖一行，包括被他人占用的默认按键 |
| `extract-revamped version` | 版本，然后是 tmux 版本 |
| `extract-revamped help` | 帮助页；`man extract-revamped` 记录相同的命令和设置 |
| `extract-revamped` | 在终端上显示菜单 |

| tmux 选项 | 默认值 | 含义 |
|:------------|:--------|:--------|
| `@extract_revamped_key` | `M-x` | 插入选择器的前缀键；`none` 表示不绑定 |
| `@extract_revamped_mode` | `all` | 要选取的内容，取下面的模式之一 |
| `@extract_revamped_modes` | `all urls paths words lines` | 选择器中 `C-n` 循环的模式 |
| `@extract_revamped_scope` | `pane` | 要读取的文本：`pane`、窗口的 `all-panes`，或日志文件夹中最新文件的 `last-log` |
| `@extract_revamped_log_dir` | `~/.tmux/logging-revamped` | `last-log` 读取的文件夹 |
| `@extract_revamped_custom_regex` | 无 | `custom` 模式的扩展正则表达式 |
| `@extract_revamped_min_length` | `0` | 去掉比这更短的片段 |
| `@extract_revamped_reverse` | `0` | `1` 时把屏幕上最后的匹配放在最前 |
| `@extract_revamped_multi` | `0` | `1` 时可在 fzf 中用 `Tab` 标记多个片段；insert 用空格连接输入 |
| `@extract_revamped_osc52` | `0` | `1` 时用 OSC 52 序列代替剪贴板工具复制 |
| `@extract_revamped_frecency` | `0` | `1` 时把最近选取的放在最前，并在 `@extract_revamped_recent` 中保留最后 20 个 |
| `@extract_revamped_lines` | `200` | 在屏幕上方读取的滚动回溯行数 |
| `@extract_revamped_popup_width` | `80%` | 弹出窗口宽度 |
| `@extract_revamped_popup_height` | `60%` | 弹出窗口高度 |

以 tmux 选项给出的设置在按键运行时读取，所以修改从下一次选取起生效；通过命令行或环境变量传给 `extract-revamped apply` 的设置会带到它绑定的按键上；按键本身在 `extract-revamped apply` 或重新加载配置后生效。每个选项也可以写成用短横线连接的命令选项，例如 `--min-length 4`，以及环境变量，例如 `EXTRACT_REVAMPED_MIN_LENGTH`；命令行优先于环境变量，环境变量优先于 tmux 选项。空的 tmux 选项表示使用默认值。

<a id="模式"></a>

## 模式

| 模式 | 选取 |
|:-----|:------|
| `all` | URL、路径和单词，不重复 |
| `urls` | `http`、`https`、`ftp` 和 `file` URL 以及电子邮件地址，去掉末尾标点 |
| `paths` | 绝对路径、主目录、`./` 和 `../` 路径，以及任何含斜杠的词 |
| `words` | 空白分隔的每个词 |
| `lines` | 每个非空行，去掉首尾空白 |
| `shas` | 含字母的 7 到 40 位十六进制对象名 |
| `ipv4`, `ipv6` | 地址，去掉超出范围的 IPv4 段 |
| `hex` | 十六进制颜色，例如 `#a1b2c3` |
| `uuids` | 标准格式的 UUID |
| `numbers` | 带符号的整数和小数 |
| `quoted` | 双引号、单引号或反引号中的文本 |
| `bracketed` | 圆括号、方括号、花括号或尖括号中的文本 |
| `custom` | `@extract_revamped_custom_regex` 的匹配 |

选取的片段用 `send-keys -l` 输入，所以像 `Enter` 这样的片段会作为文本输入，而不会被按下。打开时会从按下按键的窗格所在文件夹启动编辑器，并把路径作为一个参数传入。

<a id="界面"></a>

## 界面

<details>
<summary>所有界面，在真实的 tmux 中用 <code>make screens</code> 录制，每个按键显示在状态栏上</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/picker.png" alt="extract-revamped：prefix M-x 列出屏幕上的所有片段"><br><sub><code>prefix M-x</code> 列出屏幕上的所有片段，来自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/inserted.png" alt="extract-revamped：选取的 URL 输入到提示符"><br><sub>选取的 URL 输入到提示符，来自 <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/urls.png" alt="extract-revamped：@extract_revamped_mode urls 只列出 URL"><br><sub><code>@extract_revamped_mode urls</code> 只列出 URL，来自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/navigate.png" alt="extract-revamped：navigate 键在复制模式中查找片段"><br><sub>navigate 键在复制模式中查找片段，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/open.png" alt="extract-revamped：open 键在编辑器中显示路径"><br><sub>open 键在编辑器中显示路径，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/copy.png" alt="extract-revamped：copy 键把片段放进剪贴板"><br><sub>copy 键把片段放进剪贴板，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/chooser.png" alt="extract-revamped：按 C-n 后的选择器，在 60% 的弹出窗口中"><br><sub>按 <code>C-n</code> 后的选择器，在 60% 的弹出窗口中，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/filters.png" alt="extract-revamped：最小长度、倒序和两个已标记的片段"><br><sub>最小长度、倒序和两个已标记的片段，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/all-panes.png" alt="extract-revamped：@extract_revamped_scope all-panes 读取另一个窗格"><br><sub><code>@extract_revamped_scope all-panes</code> 读取另一个窗格，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/doctor-popup.png" alt="extract-revamped：doctor 键"><br><sub>doctor 键，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu.png" alt="extract-revamped：菜单"><br><sub>菜单，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="extract-revamped：doctor"><br><sub><code>doctor</code>，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/list.png" alt="extract-revamped：list"><br><sub><code>list</code>，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/json.png" alt="extract-revamped：list --json"><br><sub><code>list --json</code>，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="extract-revamped：没有 gum 的菜单"><br><sub>没有 gum 的菜单，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-apply.png" alt="extract-revamped：从菜单运行 apply"><br><sub>从菜单运行 <code>apply</code>，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/version.png" alt="extract-revamped：版本"><br><sub>版本，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/error.png" alt="extract-revamped：未知命令"><br><sub>未知命令，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/themes.png" alt="extract-revamped：六种主题下的标题"><br><sub>六种主题下的标题，来自 <code>themes.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/help.png" alt="extract-revamped：帮助页"><br><sub>帮助页，来自 <code>help.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/accent.png" alt="extract-revamped：来自 EXTRACT_REVAMPED_ACCENT 的强调色"><br><sub>来自 <code>EXTRACT_REVAMPED_ACCENT</code> 的强调色，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"></td>
</tr>
</table>

</details>

## 可移植性

插件是 POSIX `sh`。CI 在下面每一行上运行全部测试。

| Shell | 状态 |
|:------|:-------|
| `dash`、macOS 上的 `/bin/sh` | 支持 |
| `bash` 3.2 和 5.x、系统自带的 `zsh` 和 Homebrew 的 `zsh` | 支持 |

| 系统 | 状态 |
|:-------|:-------|
| macOS | Apple Silicon 和 Intel 上的 Tahoe，使用系统自带的工具、Homebrew 的 GNU 工具和 Homebrew 的 uutils |
| Linux | x86_64 和 arm64 上的 Ubuntu 26.04，使用 GNU coreutils、uutils 和 BusyBox |

## 开发

| 命令 | 运行内容 |
|:--------|:-------------|
| `make fmt` | 对每个脚本运行 shfmt `-i 2` |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint 和 actionlint，零告警 |
| `make test` | 在系统 `sh` 下运行 bats 测试 |
| `make test-all` | 在每个已安装的 shell 下运行测试，macOS 上包括 bash 和 zsh 的两种构建 |
| `make test-linux` | 在 Ubuntu 容器中运行测试 |
| `make coverage` | 在这台 Mac 和 Ubuntu 容器中运行 bashcov，合并后以 100% 为门槛 |
| `make screens` | 用 VHS 在 tmux 中从真实插件录制上面的界面，在 macOS 上运行 |
| `make install` | 把命令、man 手册和补全安装到 `PREFIX` 下 |

提交遵循 Conventional Commits 格式，直接进入 `main`。`main` 上的 `ci` 通过后，`release.yml` 运行 semantic-release：自上一个标签以来的每个 `feat` 或 `fix` 都会发布新版本，更新版本常量，并把说明写进 [`CHANGELOG.md`](CHANGELOG.md)。

## 许可证

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

这个插件是 tmux-revamped 插件家族的一员。每个成员都带有 [`FAMILY.md`](FAMILY.md) 中相同的约定和相同的共享库，并且设计为一起安装：没有成员占用另一个成员占用的按键或 tmux 选项。

在一个成员中发现的缺陷，要在全部成员中排查之后才算修复完成。

| 成员 | 功能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | 编辑并保存 tmux 配置后，它会自动重新加载，无需按键，也无需命令 |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | 在 tmux 状态栏显示电池状态，从不阻塞状态栏渲染 |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 在 tmux 状态栏显示每个已连接的蓝牙设备及其电量，不阻塞渲染 |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | 在 tmux 状态栏显示 CPU 负载、温度和频率，从不阻塞渲染 |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | 在 tmux 状态栏显示磁盘用量，从不阻塞状态栏渲染 |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | **本插件**，用 fzf 从屏幕上挑选 URL、路径、哈希或任意其他词元，并输入到光标处，全部用纯 shell 实现 |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | 在弹出窗口中的 fzf 选择器里切换、关闭、重命名或创建 tmux 会话、窗口和窗格 |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | 在 tmux 状态栏中显示活动窗格的 git 分支、改动和托管平台计数，且不阻塞渲染 |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | 在 tmux 状态栏中显示 NVIDIA、AMD、Intel 和 Apple GPU 的负载、温度、频率、功耗和显存 |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 在 tmux 状态栏中显示当前的 Kubernetes 上下文和命名空间，不依赖 kubectl，直接解析 kubeconfig |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 在弹出窗口或新窗口中启动任意 TUI 应用，从当前窗格的目录开始，每个应用可配置一个按键 |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 将任意窗格保存到文件：实时日志、完整回滚缓冲区或一次性截图 |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 在 tmux 状态栏显示正在播放的曲目，从不阻塞状态栏渲染 |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | 在 tmux 状态栏显示网络吞吐量，从不阻塞渲染 |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux 的窗格和窗口管理按键，适配 tmux 版本，兼容 vim，每个 prefix 按键都可禁用 |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | 保存 tmux 的所有会话、窗口和窗格，按定时器自动保存，并在重启后全部恢复 |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起点：共享库、bats 测试框架和 CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 状态栏中的番茄钟计时器，所有状态都保存在 tmux 选项中，不使用临时文件 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 状态栏显示内存、交换空间和内存压力，在后台采样，渲染从不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用鼠标在 tmux 状态栏上拖动窗口标签来移动该窗口 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 将鼠标滚轮交给能自行滚动的应用，其他情况下进入 tmux 复制模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和终端区分的合理默认设置，不改动你自己设置的选项 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平铺窗口管理：八种布局，包括 BSP dwindle 和 spiral，并支持撤销布局 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 状态栏中的本地时钟和世界时钟，按一天中的时段着色，并提供倒计时和夏令时提醒 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在后台从 wttr.in 获取天气并显示在状态栏，状态栏无需等待 |

<!-- family:end -->
