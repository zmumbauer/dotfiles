run() {
  local repo_root repo_name entrypoint target

  repo_root="$(command git rev-parse --show-toplevel 2>/dev/null || pwd -P)"

  if [[ -f "$repo_root/bin/.entrypoint" ]]; then
    entrypoint="$(<"$repo_root/bin/.entrypoint")"
    target="$repo_root/bin/$entrypoint"

    if [[ -x "$target" && ! -d "$target" ]]; then
      "$target" "$@"
      return $?
    fi

    print -u2 -- "run: configured entry point is missing or not executable: $target"
    return 1
  fi

  repo_name="$(basename "$repo_root")"
  target="$repo_root/bin/$repo_name"

  if [[ -x "$target" && ! -d "$target" ]]; then
    "$target" "$@"
    return $?
  fi

  print -u2 -- "run: could not determine entry point for $repo_root"
  print -u2 -- "run: add bin/.entrypoint or create bin/$repo_name"
  return 1
}
