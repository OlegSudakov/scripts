#!/usr/bin/env bash
set -euo pipefail

sudo_cmd=()
[[ "${1:-}" != "--sudo" ]] || sudo_cmd=(sudo)
"${sudo_cmd[@]}" apt-get update
"${sudo_cmd[@]}" apt-get install -y git curl python3 python3-venv

curl -fsSL https://chatgpt.com/codex/install.sh | sh
curl -fsSL https://claude.ai/install.sh | bash -s latest

while read -r repo commit; do
  [[ -d "$repo/.git" ]] || git clone "https://github.com/unclebob/$repo.git"
  git -C "$repo" checkout --detach "$commit"
done <<'REPOS'
ub-mode 57a8bdd
crapper 6fd92c4
dryer 66ff6d2
mutator a5a0cb8
REPOS

for skills in "$HOME/.agents/skills" "$HOME/.claude/skills"; do
  mkdir -p "$skills/ub-mode"
  cp ub-mode/SKILL.md "$skills/ub-mode/SKILL.md"
done

tool_path="$HOME/.local/bin:$PWD/crapper:$PWD/dryer:$PWD/mutator"
export PATH="$tool_path:$PATH"
rc="$HOME/.bashrc"
[[ "${SHELL:-}" != */zsh ]] || rc="$HOME/.zshrc"
path_line=$(printf 'export PATH=%q:"$PATH"' "$tool_path")
grep -qxF -- "$path_line" "$rc" 2>/dev/null || printf '\n%s\n' "$path_line" >> "$rc"

echo "Done. Run: source $rc"
