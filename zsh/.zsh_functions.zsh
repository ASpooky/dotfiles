# =============================================================================
# 個人用シェル関数
# =============================================================================

# git worktree間をfzfで選んで移動し、同じVSCodeウィンドウでそのフォルダを開く
wtcd() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "wtcd: not inside a git repository" >&2
    return 1
  fi

  local line wt_path
  line=$(git worktree list --porcelain | awk '
    /^worktree /{path=$2}
    /^branch /{b=$2; sub("refs/heads/", "", b); print path"\t"b}
    /^detached/{print path"\t(detached)"}
  ' | fzf --prompt="worktree> " --delimiter='\t' --with-nth=2,1 --query="$*" \
         --preview 'git -C {1} log --oneline -5' --preview-window=down:5:wrap)

  [ -n "$line" ] || return 0
  wt_path=${line%%$'\t'*}
  cd "$wt_path" || return 1
  code -r "$wt_path"
}

# PRをfuzzy検索して選択。Enter=ブラウザで開く、Ctrl-O=worktreeを作ってVSCodeで開く
prfz() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "prfz: not inside a git repository" >&2
    return 1
  fi
  if ! command -v gh &>/dev/null; then
    echo "prfz: gh command not found" >&2
    return 1
  fi

  local repo_root out key line num branch wt_dir
  repo_root=$(git rev-parse --show-toplevel) || return 1

  out=$(gh pr list --limit 200 --state all \
        --json number,title,headRefName,author,updatedAt \
        --jq '.[] | [.number, .title, .headRefName, .author.login, .updatedAt] | @tsv' \
    | fzf --prompt="pr> " --delimiter='\t' --with-nth=2,3,4,1 --query="$*" \
          --preview 'gh pr view {1}' --preview-window=down:15:wrap \
          --header 'enter: open in browser / ctrl-o: checkout as worktree + VSCode' \
          --expect=ctrl-o)

  key=$(echo "$out" | head -1)
  line=$(echo "$out" | sed -n '2p')
  [ -n "$line" ] || return 0
  num=${line%%$'\t'*}
  branch=$(echo "$line" | cut -f3)

  if [ "$key" = "ctrl-o" ]; then
    wt_dir="${repo_root}-pr-${num}"
    if [ ! -d "$wt_dir" ]; then
      git worktree add --detach "$wt_dir" || return 1
    fi
    (cd "$wt_dir" && gh pr checkout "$num") || return 1
    cd "$wt_dir" || return 1
    code -r "$wt_dir"
  else
    gh pr view "$num" --web
  fi
}

# issue番号(またはbranch名)からworktreeを作り、herdrに
# tab1: claudeペイン + hunkペイン(横並び split)、tab2: term をセットアップ。
# .claude-sessions/[number] があれば claude --resume で再開する。
wsnew() {
  local arg="$1"
  if [ -z "$arg" ]; then
    echo "usage: wsnew <issue-number|branch-name>" >&2
    return 1
  fi
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "wsnew: not inside a git repository" >&2
    return 1
  fi
  if ! command -v herdr &>/dev/null; then
    echo "wsnew: herdr command not found" >&2
    return 1
  fi

  local branch issue_num label
  case "$arg" in
    ''|*[!0-9]*)
      branch="$arg"
      ;;
    *)
      issue_num="$arg"
      branch="feature/issue-${issue_num}"
      ;;
  esac
  case "$branch" in
    feature/issue-*)
      issue_num="${branch#feature/issue-}"
      ;;
  esac
  if [ -n "$issue_num" ]; then
    label="issue-${issue_num}"
  else
    label=${branch//\//-}
  fi

  local repo_root wt_path
  repo_root=$(git rev-parse --show-toplevel) || return 1
  wt_path="${repo_root}-${label}"

  if [ -e "$wt_path" ]; then
    echo "wsnew: $wt_path already exists" >&2
    return 1
  fi

  git worktree add -b "$branch" "$wt_path" || return 1

  local claude_cmd session_file resume_id
  claude_cmd="claude"
  if [ -n "$issue_num" ]; then
    session_file="${repo_root}/.claude-sessions/${issue_num}"
    if [ -f "$session_file" ]; then
      resume_id=$(cat "$session_file")
      claude_cmd="claude --resume ${resume_id}"
    fi
  fi

  local ws_json ws_id root_pane root_tab hunk_pane
  ws_json=$(herdr workspace create --cwd "$wt_path" --label "$label") || return 1
  ws_id=$(echo "$ws_json" | python3 -c 'import sys,json;print(json.load(sys.stdin)["result"]["workspace"]["workspace_id"])')
  root_pane=$(echo "$ws_json" | python3 -c 'import sys,json;print(json.load(sys.stdin)["result"]["root_pane"]["pane_id"])')
  root_tab=$(echo "$ws_json" | python3 -c 'import sys,json;print(json.load(sys.stdin)["result"]["tab"]["tab_id"])')

  herdr tab rename "$root_tab" "claude" >/dev/null

  hunk_pane=$(herdr pane split "$root_pane" --direction right --no-focus \
    | python3 -c 'import sys,json;print(json.load(sys.stdin)["result"]["pane"]["pane_id"])')
  herdr pane run "$hunk_pane" "hunk diff --agent-notes --mode stack"

  herdr pane run "$root_pane" "$claude_cmd"

  herdr tab create --workspace "$ws_id" --cwd "$wt_path" --label "term" --no-focus >/dev/null
}
