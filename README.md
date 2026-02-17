# dotfiles

GNU Stow で管理する最小構成の dotfiles。
WSL2 (Ubuntu/zsh) と Windows (PowerShell) で Starship プロンプトを共有する。

## 構成

```
dotfiles/
├── zsh/
│   └── .zshrc                          → ~/.zshrc
├── starship/
│   └── .config/
│       └── starship.toml               → ~/.config/starship.toml
└── powershell/
    └── .config/
        └── powershell/
            └── profile.ps1             → ~/.config/powershell/profile.ps1
```

## 前提

- **Nerd Font** が必要（Starship の Tokyo Night プリセットがアイコンを使用）
  - WSL2: `https://www.nerdfonts.com/` からダウンロードしてインストール
  - Windows: `winget install JanDeDobbeleer.OhMyPosh` 経由、または手動で
    ```powershell
    winget search NerdFont   # 利用可能なフォントを検索
    winget install --id=DEVCOM.JetBrainsMonoNerdFont
    ```
  - ターミナルのフォント設定を Nerd Font（例: `JetBrainsMono Nerd Font`）に変更する

## セットアップ

### WSL2 (Ubuntu)

```bash
git clone https://github.com/ASpooky/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash setup-linux.sh
```

zsh, stow, Starship のインストールとシンボリックリンク作成を自動で行う。
新しいターミナルを開けば反映される。

### Windows (PowerShell 5.1)

管理者権限の PowerShell で実行する。

```powershell
git clone https://github.com/ASpooky/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles
.\setup-windows.ps1
```

Starship, posh-git, Nerd Font のインストールとシンボリックリンク作成を自動で行う。
PowerShell を再起動すれば反映される。

> **Note**: PowerShell 7 を使う場合は `profile.ps1` のリンク先を
> `$HOME\.config\powershell\profile.ps1` に手動で変更する。

## 設定の追加・変更

ファイルを編集後、WSL 側は `stow` を再実行するだけでリンクが更新される。

```bash
cd ~/dotfiles
stow -R zsh        # zsh の設定を再リンク
stow -R starship   # starship の設定を再リンク
```

新しいパッケージを追加する場合は、Stow の規約に従ってディレクトリを作る。

```bash
# 例: git の設定を追加
mkdir -p ~/dotfiles/git
# ~/dotfiles/git/.gitconfig を作成
stow git
```

## アンインストール

```bash
cd ~/dotfiles
stow -D zsh starship   # シンボリックリンクを削除
```
