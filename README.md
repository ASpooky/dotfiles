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

## セットアップ

### WSL2 (Ubuntu)

```bash
# 1. 必要なパッケージをインストール
sudo apt update && sudo apt install -y zsh stow git curl

# 2. Starship をインストール
curl -sS https://starship.rs/install.sh | sh

# 3. リポジトリをクローン
git clone https://github.com/ASpooky/dotfiles.git ~/dotfiles

# 4. Stow でシンボリックリンクを作成
cd ~/dotfiles
stow zsh starship

# 5. デフォルトシェルを zsh に変更
chsh -s $(which zsh)
```

新しいターミナルを開けば反映される。

### Windows (PowerShell)

```powershell
# 1. Starship をインストール
winget install Starship.Starship

# 2. リポジトリをクローン
git clone https://github.com/<your-username>/dotfiles.git $HOME\dotfiles

# 3. profile.ps1 をシンボリックリンク (管理者権限で実行)
New-Item -ItemType Directory -Path "$HOME\.config\powershell" -Force
New-Item -ItemType SymbolicLink `
  -Path "$HOME\.config\powershell\profile.ps1" `
  -Target "$HOME\dotfiles\powershell\.config\powershell\profile.ps1"

# 4. starship.toml をシンボリックリンク
New-Item -ItemType Directory -Path "$HOME\.config" -Force
New-Item -ItemType SymbolicLink `
  -Path "$HOME\.config\starship.toml" `
  -Target "$HOME\dotfiles\starship\.config\starship.toml"
```

PowerShell を再起動すれば反映される。

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
