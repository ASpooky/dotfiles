# dotfiles

zshとStarshipの設定。

## 準備

zshをログインシェルに設定し、使いたいツール（Starship・direnv・mise）をインストールする。未インストールのツールはスキップされる。
Starshipのアイコン表示には、ターミナルでNerd Fontを使用する。

入力候補と構文ハイライトを使う場合は、プラグインを配置する。

```sh
mkdir -p "$HOME/.zsh/plugins"
git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.zsh/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh/plugins/zsh-syntax-highlighting"
```

## セットアップ

リポジトリをcloneする（取得済みなら不要）。

```sh
git clone https://github.com/ASpooky/dotfiles.git "$HOME/Desktop/dotfiles"
```

既存の`~/.zshrc`とStarship設定がある場合は、別の場所へバックアップしてからリンクを作成する。
clone先を変更した場合は、リンク元のパスも変更する。

```sh
ln -s "$HOME/Desktop/dotfiles/.zshrc" "$HOME/.zshrc"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"
ln -s "$HOME/Desktop/dotfiles/starship.toml" "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
```

新しいターミナルを開くと設定が反映される。以後はリポジトリ内の設定ファイルを編集する。

秘密情報などのローカル設定は`~/.secrets`に記述すると読み込まれる。
