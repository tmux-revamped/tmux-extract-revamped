<div align="center">

# tmux-extract-revamped

<strong>画面上の URL、パス、ハッシュなどのトークンを fzf で選び、カーソル位置に入力します。純粋なシェルで動きます。</strong>

[English](README.md) &nbsp;|&nbsp; 日本語 &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-extract-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-extract-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-extract-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-extract-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-extract-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-extract-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-extract-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#クイックスタート"><strong>クイックスタート</strong></a> &nbsp;|&nbsp;
  <a href="#使い方">使い方</a> &nbsp;|&nbsp;
  <a href="#モード">モード</a> &nbsp;|&nbsp;
  <a href="#画面">画面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="ビルドログから URL を fzf で選び、プロンプトに入力する extract-revamped" width="800">
</p>

```console
$ EXTRACT_REVAMPED_OPEN_KEY=o extract-revamped list
bind-key M-x display-popup -E -w 80% -h 60% '/home/user/.tmux/plugins/tmux-extract-revamped/bin/extract-revamped' insert '#{pane_id}'
bind-key o display-popup -E -w 80% -h 60% '/home/user/.tmux/plugins/tmux-extract-revamped/bin/extract-revamped' open '#{pane_id}'
```

`prefix M-x` を押すと、画面上のすべての URL、パス、単語がポップアップの fzf に並びます。1 つ選ぶと、元のペインのカーソル位置にそのまま文字として入力されます。ほかのキーでは、トークンを開く、コピーする、コピーモードで探すことができます。

---

## クイックスタート

### 前提条件

| ツール | バージョン | 用途 |
|:-----|:--------|:---------|
| tmux | 3.2 以降 | ポップアップ |
| fzf | 任意のバージョン | 選択画面。ないときは `doctor` が報告します |
| オープナー | 任意 | URL 用。macOS では `open`、Linux では `xdg-open` |
| クリップボードのツール | 任意 | macOS では `pbcopy`、Linux では `wl-copy`、`xclip`、`xsel`、または `base64` による OSC 52 |
| gum | 任意 | `extract-revamped` のメニュー、表、色。なくてもすべてのコマンドがプレーンテキストで動きます |

### インストール

```tmux
set -g @plugin 'tmux-revamped/tmux-extract-revamped'
```

続けて `prefix + I` を押します。TPM を使わない場合は、リポジトリをクローンし、`~/.tmux.conf` からエントリーポイントを実行します。

```bash
git clone https://github.com/tmux-revamped/tmux-extract-revamped ~/.tmux/plugins/tmux-extract-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-extract-revamped/extract-revamped.tmux
```

クローンで `make install` を実行すると、`extract-revamped` が `~/.local/bin` に、manページと補完が `~/.local/share` の下に入ります。

### 確認

```bash
~/.tmux/plugins/tmux-extract-revamped/bin/extract-revamped doctor
```

## 使い方

| キー | 動作 | 既定 |
|:----|:-------|:--------|
| `prefix M-x` | トークンを選び、カーソル位置に入力します | 割り当て済み |
| `@extract_revamped_navigate_key` | トークンを選び、コピーモードで探します | 未割り当て |
| `@extract_revamped_open_key` | トークンを選んで開きます。URL はブラウザーで、パスは新しいウィンドウの `$EDITOR` で、それ以外は入力します | 未割り当て |
| `@extract_revamped_copy_key` | トークンを選び、コピーします | 未割り当て |
| `@extract_revamped_edit_key` | トークンを選び、種類を問わず新しいウィンドウの `$EDITOR` で開きます | 未割り当て |
| `@extract_revamped_run_key` | トークンを選び、新しいウィンドウで `@extract_revamped_command` を実行します | 未割り当て |
| `@extract_revamped_chooser_key` | チューザーで選びます。`Enter` で入力、`C-o` で開く、`C-y` でコピー、`C-e` で編集、`C-x` で自分のコマンドを実行、`C-n` で次のモード | 未割り当て |
| `@extract_revamped_doctor_key` | doctor の結果をポップアップで表示します | 未割り当て |

`M-x` はファミリーのキー割り当てでこのプラグインの枠です。`prefix M-x` を自分で割り当てているときは、プラグインはそのままにし、`doctor` がそれを報告します。`@extract_revamped_key` を別のキーにするか、`none` でキーなしにします。

| コマンド | 動作 |
|:--------|:-------------|
| `extract-revamped apply` | キーを今すぐ割り当てます。プラグインの読み込み時にエントリーポイントが実行します |
| `extract-revamped list` | apply が行う割り当てをすべて表示します。`--json` で 1 つのオブジェクトを出力します |
| `extract-revamped insert`, `navigate`, `open`, `copy`, `edit`, `run`, `choose` `PANE` | ペインで選択画面を実行します。キーはこれらをポップアップで実行します |
| `extract-revamped doctor` | 依存関係ごとに 1 行。ほかの誰かが使っている既定キーも含みます |
| `extract-revamped version` | バージョンと tmux のバージョン |
| `extract-revamped help` | ヘルプ。`man extract-revamped` にも同じコマンドと設定があります |
| `extract-revamped` | 端末ではメニュー |

| tmux オプション | 既定値 | 意味 |
|:------------|:--------|:--------|
| `@extract_revamped_key` | `M-x` | 挿入の選択画面のプレフィックスキー。`none` でキーなし |
| `@extract_revamped_picker` | `fzf` | `hints` にすると、ペインそのものの上で各トークンに文字を重ねて表示し、入力した文字のトークンを処理します。tmux 3.3 以降が必要で、`extract-revamped apply` の後に有効になります |
| `@extract_revamped_mode` | `all` | 選ぶもの。下のモードのいずれか |
| `@extract_revamped_modes` | `all urls paths words lines` | チューザーで `C-n` が切り替えるモード |
| `@extract_revamped_scope` | `pane` | 読むテキスト。`pane`、ウィンドウの `all-panes`、またはログフォルダーの最新ファイルの `last-log` |
| `@extract_revamped_log_dir` | `~/.tmux/logging-revamped` | `last-log` が読むフォルダー |
| `@extract_revamped_custom_regex` | なし | `custom` モードの拡張正規表現 |
| `@extract_revamped_command` | なし | 実行アクションが、ペインのフォルダーで新しいウィンドウに起動するシェルコマンド。選んだトークンは `"$1"`、`"$2"` の順に渡されます。例 `git show "$1"` |
| `@extract_revamped_min_length` | `0` | これより短いトークンを除きます |
| `@extract_revamped_reverse` | `0` | `1` で画面上の最後の一致を先頭にします |
| `@extract_revamped_multi` | `0` | `1` で fzf の `Tab` で複数のトークンを選べます。insert は空白でつないで入力します |
| `@extract_revamped_osc52` | `0` | `1` でクリップボードのツールの代わりに OSC 52 でコピーします |
| `@extract_revamped_frecency` | `0` | `1` で最近選んだものを先頭にし、最後の 20 件を `@extract_revamped_recent` に保存します |
| `@extract_revamped_lines` | `200` | 画面の上から読むスクロールバックの行数 |
| `@extract_revamped_popup_width` | `80%` | ポップアップの幅 |
| `@extract_revamped_popup_height` | `60%` | ポップアップの高さ |

tmux オプションで指定した設定はキーを実行したときに読むので、変更は次の選択から有効になります。`extract-revamped apply` にコマンドラインまたは環境変数で渡した設定は、割り当てたキーに引き継がれます。キーそのものは `extract-revamped apply` か設定の再読み込みで有効になります。どのオプションも、ダッシュ区切りのコマンドオプション（例 `--min-length 4`）と環境変数（例 `EXTRACT_REVAMPED_MIN_LENGTH`）で指定できます。優先順位はコマンドライン、環境変数、tmux オプションの順です。空の tmux オプションは既定値を意味します。

<a id="モード"></a>

## モード

| モード | 選ぶもの |
|:-----|:------|
| `all` | URL、パス、単語。重複なし |
| `urls` | `http`、`https`、`ftp`、`file` の URL とメールアドレス。末尾の句読点は除きます |
| `paths` | 絶対パス、ホーム、`./`、`../` のパスと、スラッシュを含む語 |
| `words` | 空白で区切られたすべての語 |
| `lines` | 空でないすべての行。前後の空白を除きます |
| `shas` | 英字を含む 7 から 40 文字の 16 進のオブジェクト名 |
| `ipv4`, `ipv6` | アドレス。範囲外の IPv4 オクテットは除きます |
| `hex` | `#a1b2c3` のような 16 進の色 |
| `uuids` | 標準形式の UUID |
| `numbers` | 符号付きの整数と小数 |
| `quoted` | ダブルクォート、シングルクォート、バッククォートの中のテキスト |
| `bracketed` | 丸括弧、角括弧、波括弧、山括弧の中のテキスト |
| `docker` | コンテナ ID、`ghcr.io/acme/api:1.4.2` のようなイメージ参照、`sha256` ダイジェスト |
| `kubernetes` | `pod/web-0` や `deployment.apps/web` のようなリソース名と、`web-7d4b9c6f5-x2k9q` のような自動生成の Pod 名 |
| `git-status` | `git status` が並べるファイル。長い形式と短い形式の両方に対応し、名前変更は両側を拾います |
| `diff` | diff の `diff --git`、`---`、`+++` の行にあるファイル |
| `markdown` | Markdown リンクのリンク先 |
| `branches` | `git status`、`git branch`、`git log` の装飾に出るブランチ名とタグ名 |
| `custom` | `@extract_revamped_custom_regex` に一致するもの |

選んだトークンは `send-keys -l` で入力されるので、`Enter` のようなトークンも押されずに文字として入力されます。開くときは、キーを押したペインのフォルダーから、パスを 1 つの引数としてエディターを起動します。

`@extract_revamped_picker hints` にすると、キーを押したときに枠なしのポップアップがペインを覆い、画面に見えている各トークンの先頭に文字を重ねて表示します。その文字を入力するとそのトークンを処理します。画面のトークンが 26 個を超えるときは 2 文字です。ほかのキーを押すと閉じます。ヒントは `@extract_revamped_scope` の値にかかわらず見えている画面だけを読み、チューザーは fzf のままです。

<a id="画面"></a>

## 画面

<details>
<summary>すべての画面。本物の tmux の中で <code>make screens</code> で録画し、押したキーをステータスラインに表示しています</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/picker.png" alt="extract-revamped: prefix M-x が画面上のすべてのトークンを並べる"><br><sub><code>prefix M-x</code> が画面上のすべてのトークンを並べる。<code>hero.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/inserted.png" alt="extract-revamped: 選んだ URL をプロンプトに入力"><br><sub>選んだ URL をプロンプトに入力。<code>hero.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/urls.png" alt="extract-revamped: @extract_revamped_mode urls は URL だけを並べる"><br><sub><code>@extract_revamped_mode urls</code> は URL だけを並べる。<code>hero.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/navigate.png" alt="extract-revamped: navigate キーがコピーモードでトークンを探す"><br><sub>navigate キーがコピーモードでトークンを探す。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/open.png" alt="extract-revamped: open キーがパスをエディターで表示する"><br><sub>open キーがパスをエディターで表示する。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/copy.png" alt="extract-revamped: copy キーがトークンをクリップボードに入れる"><br><sub>copy キーがトークンをクリップボードに入れる。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/chooser.png" alt="extract-revamped: C-n の後のチューザー（60% のポップアップ）"><br><sub><code>C-n</code> の後のチューザー（60% のポップアップ）。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/filters.png" alt="extract-revamped: 最小長、逆順、2 つの選択"><br><sub>最小長、逆順、2 つの選択。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/all-panes.png" alt="extract-revamped: @extract_revamped_scope all-panes がもう一方のペインを読む"><br><sub><code>@extract_revamped_scope all-panes</code> がもう一方のペインを読む。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/modes.png" alt="extract-revamped: git-status モードは git status のファイルを並べます"><br><sub>git-status モードは git status のファイルを並べます。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/edit.png" alt="extract-revamped: 編集の選択画面は選んだものをエディターで開きます"><br><sub>編集の選択画面は選んだものをエディターで開きます。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/run.png" alt="extract-revamped: 実行の選択画面は選んだものに自分のコマンドを実行します"><br><sub>実行の選択画面は選んだものに自分のコマンドを実行します。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/hints.png" alt="extract-revamped: ペインの上に重ねた文字のヒント"><br><sub>ペインの上に重ねた文字のヒント。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/hints-typed.png" alt="extract-revamped: 文字を押した後に入力されたトークン"><br><sub>文字を押した後に入力されたトークン。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/doctor-popup.png" alt="extract-revamped: doctor キー"><br><sub>doctor キー。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/menu.png" alt="extract-revamped: メニュー"><br><sub>メニュー。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="extract-revamped: doctor"><br><sub><code>doctor</code>。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/list.png" alt="extract-revamped: list"><br><sub><code>list</code>。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/json.png" alt="extract-revamped: list --json"><br><sub><code>list --json</code>。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="extract-revamped: gum なしのメニュー"><br><sub>gum なしのメニュー。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-apply.png" alt="extract-revamped: メニューからの apply"><br><sub>メニューからの <code>apply</code>。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/version.png" alt="extract-revamped: バージョン"><br><sub>バージョン。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/error.png" alt="extract-revamped: 不明なコマンド"><br><sub>不明なコマンド。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/themes.png" alt="extract-revamped: 6 つのテーマのヘッダー"><br><sub>6 つのテーマのヘッダー。<code>themes.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/help.png" alt="extract-revamped: ヘルプ"><br><sub>ヘルプ。<code>help.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/accent.png" alt="extract-revamped: EXTRACT_REVAMPED_ACCENT によるアクセント"><br><sub><code>EXTRACT_REVAMPED_ACCENT</code> によるアクセント。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"></td>
</tr>
</table>

</details>

## 移植性

プラグインは POSIX `sh` です。CI は下の各行ですべてのテストを実行します。

| シェル | 状態 |
|:------|:-------|
| `dash`、macOS の `/bin/sh` | 対応 |
| `bash` 3.2 と 5.x、システムの `zsh` と Homebrew の `zsh` | 対応 |

| システム | 状態 |
|:-------|:-------|
| macOS | Apple Silicon と Intel の Tahoe。付属のツール、Homebrew の GNU ツール、Homebrew の uutils で確認 |
| Linux | x86_64 と arm64 の Ubuntu 26.04。GNU coreutils、uutils、BusyBox で確認 |

## 開発

| コマンド | 実行内容 |
|:--------|:-------------|
| `make fmt` | すべてのスクリプトに shfmt `-i 2` をかけます |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint、actionlint を、指摘ゼロで通します |
| `make test` | システムの `sh` で bats のテスト |
| `make test-all` | インストール済みのすべてのシェルでテスト。macOS では bash と zsh の両方のビルドを含みます |
| `make test-linux` | Ubuntu のコンテナでテスト |
| `make coverage` | この Mac と Ubuntu のコンテナで bashcov を実行し、合算して 100 パーセントで判定します |
| `make screens` | 上の画面を、本物のプラグインから tmux の中で VHS で録画します。macOS で実行します |
| `make install` | コマンド、manページ、補完を `PREFIX` の下に置きます |

macOS では、`brew bundle` を実行すると、これらのターゲットが使うツールがすべて [`Brewfile`](Brewfile) からインストールされます。

コミットは Conventional Commits の形式に従い、そのまま `main` に入ります。`main` で `ci` が成功すると、`release.yml` が semantic-release を実行します。前回のタグ以降に `feat` か `fix` があればリリースを公開し、バージョン定数を更新し、変更内容を [`CHANGELOG.md`](CHANGELOG.md) に追加します。

## ライセンス

[MIT](LICENSE)、copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped ファミリー

このプラグインは tmux-revamped ファミリーの一員です。すべてのメンバーが [`FAMILY.md`](FAMILY.md) の同じ規約と同じ共有ライブラリを持ちます。メンバーは一緒にインストールする前提で作られており、ほかのメンバーが使うキーや tmux オプションを使うメンバーはありません。

あるメンバーで見つかった不具合は、修正完了とする前に全メンバーで同じ不具合を探します。

| メンバー | 機能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | tmuxの設定を編集して保存するだけで、キーもコマンドも使わずに自動で再読み込みされます |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | tmuxのステータスバーに電池の状態を表示し、ステータスの描画を一切止めません |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 接続中のすべてのBluetooth機器とその電池残量をtmuxのステータスバーに表示し、描画を止めません |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPUの負荷、温度、周波数をtmuxのステータスバーに表示し、描画を一切止めません |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | tmuxのステータスバーにディスク使用量を表示し、ステータスの描画を一切止めません |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | **このプラグイン**、画面上の URL、パス、ハッシュなどのトークンを fzf で選び、カーソル位置に入力します。純粋なシェルだけで動きます |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | ポップアップ内の fzf ピッカーから、tmux のセッション、ウィンドウ、ペインの切り替え、終了、名前変更、作成を行います |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | アクティブなペインのgitブランチ、変更、プロバイダーの件数を、描画を止めずにtmuxのステータスバーに表示します |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | NVIDIA、AMD、Intel、Apple の GPU の負荷、温度、クロック、電力、メモリを tmux のステータスバーに表示します |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 現在の Kubernetes コンテキストと名前空間を、kubectl を使わずに kubeconfig から解析して tmux のステータスバーに表示します |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 任意の TUI アプリを、現在のペインのディレクトリでポップアップまたはウィンドウとして起動します。アプリごとにキーを設定できます |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 任意のペインをファイルに保存します。ライブのログ記録、スクロールバック全体、1 回限りのスクリーンショットに対応します |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 再生中の曲をステータスバーに表示し、ステータスの描画を止めません |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | ネットワークのスループットをステータスバーに表示し、描画を止めません |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux のペインとウィンドウの操作キー。tmux のバージョンに対応し、vim と共存でき、どの prefix キーも無効にできます |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | tmuxのすべてのセッション、ウィンドウ、ペインを保存し、タイマーで自動保存して、再起動後にすべて復元します |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revampedプラグインの出発点です。共有ライブラリ、batsハーネス、CIを含みます |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | すべての状態をtmuxオプションに保持し、一時ファイルを使わない、tmuxステータスバーのポモドーロタイマーです |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM、スワップ、メモリプレッシャーをtmuxのステータスバーに表示します。計測はバックグラウンドで行うため描画を待たせません |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | tmuxのステータスバー上でウィンドウのタブをマウスでドラッグして、そのウィンドウを移動します |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 自分でスクロールできるアプリにはマウスホイールを渡し、それ以外ではtmuxのコピーモードに入ります |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | tmuxのバージョンと端末に合わせて適用され、ユーザーが設定したオプションには触れない、妥当な初期設定です |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmuxのタイル型ウィンドウ管理です。BSPのdwindleとspiralを含む8つのレイアウトと、レイアウトの取り消しがあります |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | ステータスバーにローカル時計と世界時計を時間帯ごとの色で表示し、カウントダウンと夏時間の警告も出します |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | wttr.inの天気をバックグラウンドで取得し、ステータスバーを待たせずに表示します |

<!-- family:end -->
