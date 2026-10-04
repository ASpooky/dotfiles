# dotfiles

macOS / Linux用。Git・curl・zshを用意して実行する。

```sh
git clone https://github.com/ASpooky/dotfiles.git ~/dotfiles
~/dotfiles/setup.sh
```

ツールのインストールと設定のリンクを自動で行う。既存設定は`~/.dotfiles-backups/`にバックアップされる。

- 完了したら、新しいzshターミナルを開く。
- macOSではFinder・Dock・キーボード等の共通設定(`defaults write`)も適用される。一部はログアウト/再ログインで反映。
- macOSではRaycastも自動導入される。初回はアプリを開いてセットアップする。
- cmux・VS Codeは事前にインストール。未導入ならスキップされるので、後から入れて再実行してもOK。
- アイコン表示にはターミナルでNerd Fontを選ぶ。
- ツールは基本mise(`mise/config.toml`)で入れる。miseで入らないものだけ`brew/Brewfile`(Homebrewが無ければスキップ)。

PCごとの設定はリポジトリに入れず、次のファイルに書く：

| ファイル | 用途 |
|---|---|
| `~/.zshrc.local` | PC固有のPATH・alias・環境変数 |
| `~/.secrets` | トークン等の秘密情報 |
| `~/.gitconfig` | `user.name`・`user.email` |
| `~/.config/mise/conf.d/*.toml` | PC固有のツール・バージョン |

更新するとき：

```sh
cd ~/dotfiles && git pull && ./setup.sh
```

## Windows

GlazeWM（タイル型WM、Zebar同梱）とFlow Launcherをwingetで入れて設定を配置する。PowerShellで実行する（WSL内のリポジトリでもOK）。

```powershell
powershell -ExecutionPolicy Bypass -File \\wsl.localhost\Ubuntu\home\<user>\dotfiles\setup.ps1
```

- 設定はリンクではなくコピーで配置する（開発者モード不要、ログイン直後にWSLが起動していなくても読める）。差分がある既存設定は`~\.dotfiles-backups\`へ退避。
- GlazeWMはスタートアップに登録される。Flow Launcherは自身の設定で自動起動する。
- Flow Launcherのサードパーティプラグインは`flow-launcher/plugins.txt`のIDから導入する。
- 何度実行してもよい。

アプリ側で設定を変えたら、リポジトリに書き戻してコミットする：

```powershell
powershell -ExecutionPolicy Bypass -File .\glazewm\export.ps1
powershell -ExecutionPolicy Bypass -File .\flow-launcher\export.ps1  # ウィンドウ位置などPC依存の値は除外される
```

テスト（Pester 3.4+）：`Invoke-Pester .\tests`
