## Task & Issue Management

### 作業の原則
- すべてのタスクは GitHub issue として管理する。
- issue がないタスクは着手前に issue を作成する。

### Issue 作業の開始
issue 番号を渡されたら以下を実行する：
1. `HERDR_ENV=1` なら `wsnew [number]` を実行する（`~/.zsh_functions.zsh` 定義）。
   - worktree作成（`.claude-sessions/[number]` があれば `claude --resume` で再開、なければ新規）と、
     herdrワークスペースのセットアップ（tab1: claudeペイン+hunkペインの横並びsplit、tab2: term）を一括で行う。
   - 作業はそのworkspaceの新しいclaudeセッション（tab1左ペイン）側に移る。
2. `HERDR_ENV` が未設定なら従来どおり手動で行う：
   a. `.claude-sessions/[number]` に sessionId が存在するか確認する。あれば `--resume` で再開する。なければ新規セッションで開始する。
   b. `git worktree add ../[repo]-issue-[number] -b feature/issue-[number]`
3. `gh issue view [number]` で issue 内容を読み込む。
4. issue のフェーズを判断して作業を開始する。

### PR 作成時のルール
- PR は必ず draft で作成する（`gh pr create --draft`）。draft にしないと作成直後にレビューが始まってしまう。ready for review への変更は本人が行う。
- issue と PR のリポジトリが分かれている場合（例: issue=app-issues, PR=app）、PR 本文に `Closes [owner]/[repo]#[number]` 形式で書く。デフォルトブランチへのマージ時に issue が自動クローズされる。
- 本番反映の確認まで issue を開けておきたい場合は `Closes` を使わず `ref: [owner]/[repo]#[number]` に留め、確認後に手動クローズする。

### Issue 作業の終了・中断
1. sessionId を `.claude-sessions/[number]` に保存する。
2. `git worktree remove ../[repo]-issue-[number]`
3. issue に作業サマリーをコメントとして残す。

### レビューが必要なタイミング
1. issue コメントに設計案またはコードレビュー依頼を投稿する。
2. `@[username]` をメンションして待機する。

## Coding Style

- コメントは最小限に。コードで十分表現できていることは書かない。WHYが非自明な場合のみ残す。
