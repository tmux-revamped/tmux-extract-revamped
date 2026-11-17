<div align="center">

# tmux-extract-revamped

<strong>用 fzf 從畫面上選取 URL、路徑、雜湊值或其他任何片段，並輸入到游標處，純 shell 實現。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; 繁體中文（香港）

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-extract-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-extract-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-extract-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-extract-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-extract-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-extract-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-extract-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#快速開始"><strong>快速開始</strong></a> &nbsp;|&nbsp;
  <a href="#用法">用法</a> &nbsp;|&nbsp;
  <a href="#模式">模式</a> &nbsp;|&nbsp;
  <a href="#畫面">畫面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="extract-revamped 用 fzf 從建置記錄中選取 URL 並輸入到提示字元" width="800">
</p>

```console
$ EXTRACT_REVAMPED_OPEN_KEY=o extract-revamped list
bind-key M-x display-popup -E -w 80% -h 60% '/home/user/.tmux/plugins/tmux-extract-revamped/bin/extract-revamped' insert '#{pane_id}'
bind-key o display-popup -E -w 80% -h 60% '/home/user/.tmux/plugins/tmux-extract-revamped/bin/extract-revamped' open '#{pane_id}'
```

按下 `prefix M-x`，彈出視窗會在 fzf 中列出畫面上所有 URL、路徑和字詞。選取一個，它就會以字面文字輸入到原窗格的游標處。其他按鍵可以開啟片段、複製片段，或在複製模式中尋找它。

---

## 快速開始

### 前提條件

| 工具 | 版本 | 用途 |
|:-----|:--------|:---------|
| tmux | 3.2 或以上 | 彈出視窗 |
| fzf | 任何版本 | 選擇器；缺少時 `doctor` 會報告 |
| 開啟工具 | 可選 | 用於 URL：macOS 上的 `open`，Linux 上的 `xdg-open` |
| 剪貼簿工具 | 可選 | macOS 上的 `pbcopy`，Linux 上的 `wl-copy`、`xclip` 或 `xsel`，或透過 `base64` 的 OSC 52 |
| gum | 可選 | `extract-revamped` 的選單、表格和顏色；沒有它，所有命令都輸出純文字 |

### 安裝

```tmux
set -g @plugin 'tmux-revamped/tmux-extract-revamped'
```

然後按 `prefix + I`。不使用 TPM 時，複製儲存庫，並在 `~/.tmux.conf` 中執行它的入口腳本：

```bash
git clone https://github.com/tmux-revamped/tmux-extract-revamped ~/.tmux/plugins/tmux-extract-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-extract-revamped/extract-revamped.tmux
```

在複製的目錄中執行 `make install`，亦會把 `extract-revamped` 放入 `~/.local/bin`，並把它的 man 手冊和自動完成放在 `~/.local/share` 下。

### 驗證

```bash
~/.tmux/plugins/tmux-extract-revamped/bin/extract-revamped doctor
```

## 用法

| 按鍵 | 作用 | 預設 |
|:----|:-------|:--------|
| `prefix M-x` | 選取片段並輸入到游標處 | 已綁定 |
| `@extract_revamped_navigate_key` | 選取片段並在複製模式中尋找 | 未綁定 |
| `@extract_revamped_open_key` | 選取片段並開啟：URL 在瀏覽器中，路徑在新視窗的 `$EDITOR` 中，其他內容直接輸入 | 未綁定 |
| `@extract_revamped_copy_key` | 選取片段並複製 | 未綁定 |
| `@extract_revamped_chooser_key` | 在選擇器中選取：`Enter` 輸入，`C-o` 開啟，`C-y` 複製，`C-n` 切換到下一個模式 | 未綁定 |
| `@extract_revamped_doctor_key` | 在彈出視窗中顯示 doctor 報告 | 未綁定 |

`M-x` 是本插件在系列按鍵分配中的位置。如果你已自行綁定 `prefix M-x`，插件會保留它，並由 `doctor` 說明；可把 `@extract_revamped_key` 設為其他按鍵，或設為 `none` 表示不綁定。

| 命令 | 作用 |
|:--------|:-------------|
| `extract-revamped apply` | 立即綁定按鍵；插件載入時入口點會執行它 |
| `extract-revamped list` | 列出 apply 會做的每個綁定；`--json` 輸出一個物件 |
| `extract-revamped insert`, `navigate`, `open`, `copy`, `choose` `PANE` | 在窗格上執行選擇器；按鍵會在彈出視窗中執行這些命令 |
| `extract-revamped doctor` | 每個依賴一行，包括被他人佔用的預設按鍵 |
| `extract-revamped version` | 版本，然後是 tmux 版本 |
| `extract-revamped help` | 說明頁；`man extract-revamped` 記錄相同的命令和設定 |
| `extract-revamped` | 在終端機上顯示選單 |

| tmux 選項 | 預設值 | 含義 |
|:------------|:--------|:--------|
| `@extract_revamped_key` | `M-x` | 插入選擇器的前置鍵；`none` 表示不綁定 |
| `@extract_revamped_mode` | `all` | 要選取的內容，取下面的模式之一 |
| `@extract_revamped_modes` | `all urls paths words lines` | 選擇器中 `C-n` 循環的模式 |
| `@extract_revamped_scope` | `pane` | 要讀取的文字：`pane`、視窗的 `all-panes`，或記錄資料夾中最新檔案的 `last-log` |
| `@extract_revamped_log_dir` | `~/.tmux/logging-revamped` | `last-log` 讀取的資料夾 |
| `@extract_revamped_custom_regex` | 無 | `custom` 模式的延伸正規表示式 |
| `@extract_revamped_min_length` | `0` | 去掉比這更短的片段 |
| `@extract_revamped_reverse` | `0` | `1` 時把畫面上最後的相符項放在最前 |
| `@extract_revamped_multi` | `0` | `1` 時可在 fzf 中用 `Tab` 標記多個片段；insert 以空格連接輸入 |
| `@extract_revamped_osc52` | `0` | `1` 時用 OSC 52 序列代替剪貼簿工具複製 |
| `@extract_revamped_frecency` | `0` | `1` 時把最近選取的放在最前，並在 `@extract_revamped_recent` 中保留最後 20 個 |
| `@extract_revamped_lines` | `200` | 在畫面上方讀取的捲動記錄行數 |
| `@extract_revamped_popup_width` | `80%` | 彈出視窗寬度 |
| `@extract_revamped_popup_height` | `60%` | 彈出視窗高度 |

以 tmux 選項給出的設定在按鍵執行時讀取，所以修改由下一次選取起生效；透過命令列或環境變數傳給 `extract-revamped apply` 的設定會帶到它綁定的按鍵上；按鍵本身在 `extract-revamped apply` 或重新載入設定後生效。每個選項亦可寫成以短橫線連接的命令選項，例如 `--min-length 4`，以及環境變數，例如 `EXTRACT_REVAMPED_MIN_LENGTH`；命令列優先於環境變數，環境變數優先於 tmux 選項。空的 tmux 選項表示使用預設值。

<a id="模式"></a>

## 模式

| 模式 | 選取 |
|:-----|:------|
| `all` | URL、路徑和字詞，不重複 |
| `urls` | `http`、`https`、`ftp` 和 `file` URL 以及電郵地址，去掉末尾標點 |
| `paths` | 絕對路徑、主目錄、`./` 和 `../` 路徑，以及任何含斜線的字詞 |
| `words` | 空白分隔的每個字詞 |
| `lines` | 每個非空行，去掉首尾空白 |
| `shas` | 含字母的 7 至 40 位十六進位物件名稱 |
| `ipv4`, `ipv6` | 位址，去掉超出範圍的 IPv4 段 |
| `hex` | 十六進位顏色，例如 `#a1b2c3` |
| `uuids` | 標準格式的 UUID |
| `numbers` | 帶正負號的整數和小數 |
| `quoted` | 雙引號、單引號或反引號中的文字 |
| `bracketed` | 圓括號、方括號、大括號或角括號中的文字 |
| `custom` | `@extract_revamped_custom_regex` 的相符項 |

選取的片段用 `send-keys -l` 輸入，所以像 `Enter` 這樣的片段會以文字輸入，而不會被按下。開啟時會由按下按鍵的窗格所在資料夾啟動編輯器，並把路徑作為一個參數傳入。

<a id="畫面"></a>

## 畫面

<details>
<summary>所有畫面，在真實的 tmux 中用 <code>make screens</code> 錄製，每個按鍵顯示在狀態列上</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/picker.png" alt="extract-revamped：prefix M-x 列出畫面上所有片段"><br><sub><code>prefix M-x</code> 列出畫面上所有片段，來自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/inserted.png" alt="extract-revamped：選取的 URL 輸入到提示字元"><br><sub>選取的 URL 輸入到提示字元，來自 <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/urls.png" alt="extract-revamped：@extract_revamped_mode urls 只列出 URL"><br><sub><code>@extract_revamped_mode urls</code> 只列出 URL，來自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/navigate.png" alt="extract-revamped：navigate 鍵在複製模式中尋找片段"><br><sub>navigate 鍵在複製模式中尋找片段，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/open.png" alt="extract-revamped：open 鍵在編輯器中顯示路徑"><br><sub>open 鍵在編輯器中顯示路徑，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/copy.png" alt="extract-revamped：copy 鍵把片段放進剪貼簿"><br><sub>copy 鍵把片段放進剪貼簿，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/chooser.png" alt="extract-revamped：按 C-n 後的選擇器，在 60% 的彈出視窗中"><br><sub>按 <code>C-n</code> 後的選擇器，在 60% 的彈出視窗中，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/filters.png" alt="extract-revamped：最小長度、倒序和兩個已標記的片段"><br><sub>最小長度、倒序和兩個已標記的片段，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/all-panes.png" alt="extract-revamped：@extract_revamped_scope all-panes 讀取另一個窗格"><br><sub><code>@extract_revamped_scope all-panes</code> 讀取另一個窗格，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/doctor-popup.png" alt="extract-revamped：doctor 鍵"><br><sub>doctor 鍵，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu.png" alt="extract-revamped：選單"><br><sub>選單，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="extract-revamped：doctor"><br><sub><code>doctor</code>，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/list.png" alt="extract-revamped：list"><br><sub><code>list</code>，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/json.png" alt="extract-revamped：list --json"><br><sub><code>list --json</code>，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="extract-revamped：沒有 gum 的選單"><br><sub>沒有 gum 的選單，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-apply.png" alt="extract-revamped：從選單執行 apply"><br><sub>從選單執行 <code>apply</code>，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/version.png" alt="extract-revamped：版本"><br><sub>版本，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/error.png" alt="extract-revamped：不明命令"><br><sub>不明命令，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/themes.png" alt="extract-revamped：六種主題下的標題"><br><sub>六種主題下的標題，來自 <code>themes.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/help.png" alt="extract-revamped：說明頁"><br><sub>說明頁，來自 <code>help.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/accent.png" alt="extract-revamped：來自 EXTRACT_REVAMPED_ACCENT 的強調色"><br><sub>來自 <code>EXTRACT_REVAMPED_ACCENT</code> 的強調色，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"></td>
</tr>
</table>

</details>

## 可攜性

插件是 POSIX `sh`。CI 在下列每一行上執行全部測試。

| Shell | 狀態 |
|:------|:-------|
| `dash`、macOS 上的 `/bin/sh` | 支援 |
| `bash` 3.2 和 5.x、系統內建的 `zsh` 和 Homebrew 的 `zsh` | 支援 |

| 系統 | 狀態 |
|:-------|:-------|
| macOS | Apple Silicon 和 Intel 上的 Tahoe，使用內建的工具、Homebrew 的 GNU 工具和 Homebrew 的 uutils |
| Linux | x86_64 和 arm64 上的 Ubuntu 26.04，使用 GNU coreutils、uutils 和 BusyBox |

## 開發

| 指令 | 執行內容 |
|:--------|:-------------|
| `make fmt` | 對每個腳本執行 shfmt `-i 2` |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint 和 actionlint，零警告 |
| `make test` | 在系統 `sh` 下執行 bats 測試 |
| `make test-all` | 在每個已安裝的 shell 下執行測試，macOS 上包括 bash 和 zsh 的兩種版本 |
| `make test-linux` | 在 Ubuntu 容器中執行測試 |
| `make coverage` | 在這部 Mac 和 Ubuntu 容器中執行 bashcov，合併後以 100% 為門檻 |
| `make screens` | 以 VHS 在 tmux 中從真實插件錄製上述畫面，在 macOS 上執行 |
| `make install` | 把指令、man 手冊和自動完成安裝到 `PREFIX` 下 |

提交遵循 Conventional Commits 格式，直接進入 `main`。`main` 上的 `ci` 通過後，`release.yml` 會執行 semantic-release：自上一個標籤以來的每個 `feat` 或 `fix` 都會發佈新版本，更新版本常數，並把說明寫入 [`CHANGELOG.md`](CHANGELOG.md)。

## 授權

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

這個插件是 tmux-revamped 插件家族的一員。每個成員都帶有 [`FAMILY.md`](FAMILY.md) 中相同的約定和相同的共用程式庫，並且設計為一起安裝：沒有成員佔用另一個成員佔用的按鍵或 tmux 選項。

在一個成員中發現的缺陷，要在全部成員中排查後才算修正完成。

| 成員 | 功能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | 編輯並儲存 tmux 設定後，它會自動重新載入，毋須按鍵，也毋須指令 |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | 在 tmux 狀態列顯示電池狀態，從不阻塞狀態列繪製 |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 在 tmux 狀態列顯示每部已連接的藍牙裝置及其電量，不阻塞繪製 |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | 在 tmux 狀態列顯示 CPU 負載、溫度及頻率，從不阻塞繪製 |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | 在 tmux 狀態列顯示磁碟用量，從不阻塞狀態列繪製 |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | **本插件**，用 fzf 從畫面上揀選 URL、路徑、雜湊值或任何其他字詞，並輸入到游標位置，全部以純 shell 實現 |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | 在彈出視窗的 fzf 選擇器中切換、關閉、重新命名或建立 tmux 工作階段、視窗和窗格 |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | 在 tmux 狀態列顯示當前窗格的 git 分支、改動和託管平台數目，而不會阻塞顯示 |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | 在 tmux 狀態列顯示 NVIDIA、AMD、Intel 及 Apple GPU 的負載、溫度、時脈、功耗及記憶體 |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 在 tmux 狀態列顯示目前的 Kubernetes 上下文及命名空間，毋須 kubectl，直接解析 kubeconfig |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 在彈出視窗或新視窗中啟動任何 TUI 應用程式，從目前窗格的目錄開始，每個應用程式可設定一個按鍵 |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 將任何窗格儲存到檔案：即時記錄、完整捲動緩衝區或一次性截圖 |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 在 tmux 狀態列顯示正在播放的歌曲，從不阻塞狀態列的繪製 |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | 在 tmux 狀態列顯示網絡傳輸量，從不阻塞繪製 |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux 的窗格和視窗管理按鍵，配合 tmux 版本，與 vim 相容，每個 prefix 按鍵都可停用 |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | 儲存 tmux 的所有工作階段、視窗及窗格，按計時器自動儲存，並在重新開機後全部還原 |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起點：共用程式庫、bats 測試框架和 CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 狀態列中的番茄鐘計時器，所有狀態都儲存在 tmux 選項中，不使用暫存檔 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 狀態列顯示記憶體、交換空間及記憶體壓力，在背景取樣，繪製從不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用滑鼠在 tmux 狀態列上拖動視窗標籤來移動該視窗 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 將滑鼠滾輪交給能自行捲動的應用程式，其他情況下進入 tmux 複製模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和終端機區分的合理預設設定，不會改動你自己設定的選項 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平鋪視窗管理：八種版面，包括 BSP dwindle 和 spiral，並支援復原版面 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 狀態列中的本地時鐘和世界時鐘，按一天中的時段著色，並提供倒數和夏令時間提示 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在背景從 wttr.in 取得天氣並顯示在狀態列，狀態列毋須等待 |

<!-- family:end -->
