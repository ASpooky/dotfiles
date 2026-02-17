#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$1"; }
ok()    { printf '\033[1;32m[OK]\033[0m    %s\n' "$1"; }
skip()  { printf '\033[1;33m[SKIP]\033[0m  %s\n' "$1"; }

# --- 1. apt パッケージ ---
info "zsh, stow, git, curl をインストール"
PKGS=()
for cmd in zsh stow git curl; do
    if ! command -v "$cmd" &>/dev/null; then
        PKGS+=("$cmd")
    fi
done

if [ ${#PKGS[@]} -gt 0 ]; then
    sudo apt update && sudo apt install -y "${PKGS[@]}"
    ok "インストール完了: ${PKGS[*]}"
else
    skip "zsh, stow, git, curl はすべてインストール済み"
fi

# --- 2. Starship ---
info "Starship をインストール"
if command -v starship &>/dev/null; then
    skip "Starship はインストール済み ($(starship --version | head -1))"
else
    curl -sS https://starship.rs/install.sh | sh
    ok "Starship をインストールしました"
fi

# --- 3. Stow でシンボリックリンク ---
info "stow zsh starship でシンボリックリンクを作成"
cd "$DOTFILES_DIR"
stow -R zsh starship
ok "シンボリックリンクを作成しました"

# --- 4. デフォルトシェルを zsh に変更 ---
if [ "$SHELL" = "$(which zsh)" ]; then
    skip "デフォルトシェルは既に zsh"
else
    read -rp "デフォルトシェルを zsh に変更しますか? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        chsh -s "$(which zsh)"
        ok "デフォルトシェルを zsh に変更しました（新しいターミナルで反映）"
    else
        skip "デフォルトシェルの変更をスキップ"
    fi
fi

echo ""
ok "セットアップ完了！新しいターミナルを開いてください。"
