#!/usr/bin/env bash
# Claude Code status line: directory | git | usage | model
input=$(cat)

pct='if . == null then "-" else (. + 0.5 | floor | tostring) end'
IFS=$'\t' read -r dir model five < <(jq -r "[
  (.workspace.current_dir // .cwd // \"\"),
  (.model.display_name // \"?\"),
  (.rate_limits.five_hour.used_percentage | $pct)
] | @tsv" <<<"$input")

# Directory name only
out="${dir##*/}"; out="${out:-/}"

# Git: branch (or short hash), *N uncommitted files, ↑N unpushed commits
if st=$(git -C "$dir" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null); then
  read -r branch changes ahead < <(awk '
    /^# branch.oid / { oid = substr($3, 1, 7) }
    /^# branch.head / { head = $3 }
    /^# branch.ab / { ahead = substr($3, 2) }
    !/^#/ && NF { n++ }
    END { if (head == "(detached)") head = oid; print head, n + 0, ahead + 0 }
  ' <<<"$st")
  (( changes > 0 )) && branch+=" *$changes"
  (( ahead > 0 )) && branch+=" ↑$ahead"
  out+=" | $branch"
fi

# Usage: 5-hour plan limit, when available
[ "$five" != "-" ] && out+=" | 5h ${five}%"
out+=" | $model"

printf '%s' "$out"
