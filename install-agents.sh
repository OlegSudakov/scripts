#!/usr/bin/env bash
set -euo pipefail

curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 sh
curl -fsSL https://claude.ai/install.sh | bash -s latest

while read -r repo commit; do
  [[ -d "$repo/.git" ]] || git clone "https://github.com/unclebob/$repo.git"
  git -C "$repo" checkout --detach "$commit"
done <<'REPOS'
ub-mode 3da62bf3fcfd2034de41f30d920d2739e566171f
crapper 6fd92c4c9bcc56efb64a2f8743d5a2993bcfd42d
dryer 66ff6d21a42c04afcad89c78a80066176d1294b0
mutator a5a0cb803b66e0cdb8bf471b3b08af701d424a41
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

if [[ -f "$HOME/.bashrc" ]]; then
  # Shell startup files may assume unset variables and tolerate nonzero commands.
  set +eu
  source "$HOME/.bashrc"
  set -eu
fi

echo "Done."
