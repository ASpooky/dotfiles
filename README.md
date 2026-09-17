# dotfiles

macOS / Linux用。Git・curl・zshを用意して実行する。

```sh
git clone https://github.com/ASpooky/dotfiles.git ~/dotfiles
~/dotfiles/setup.sh
```

ツールのインストールと設定のリンクを自動で行う。既存設定は`~/.dotfiles-backups/`にバックアップされる。

- 完了したら、新しいzshターミナルを開く。
- macOSではRaycastも自動導入される。初回はアプリを開いてセットアップする。
- cmux・VS Codeは事前にインストール。未導入ならスキップされるので、後から入れて再実行してもOK。
- アイコン表示にはターミナルでNerd Fontを選ぶ。

更新するとき：

```sh
cd ~/dotfiles && git pull && ./setup.sh
```
