alias src="source ~/.zshrc"
alias zshe="vim ~/.zshrc"
alias clc="fc -ln -1 | awk '{$1=$1}1' | pbcopy"
alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias nvime="nvim ~/.config/nvim"
alias pull="git pull --ff-only --prune"
alias gs="git status"
alias ytt="/usr/local/bin/ytt.py"
alias prm="gh pr merge -md"
alias gfp="git add . && git commit --amend --no-edit && gp -f"
alias gi="gemini"
alias cl="claude"
alias c="codex --yolo"
alias ls='eza --group-directories-first --icons=always --git-ignore'
alias l='eza --all --long --header --group --icons=always --group-directories-first --time-style=long-iso --git-ignore'
alias la='eza --all --group-directories-first --icons=always'
alias ll='eza --long --header --group --icons=always --git --group-directories-first --time-style=long-iso'
alias lt='eza --tree --level=2 --icons=always --group-directories-first --git-ignore'
alias rgs="rg --color=always --line-number --smart-case --hidden --glob '!{.git,node_modules,venv,dist,build}'"
alias kill-panel="tmux kill-pane -t"

alias cf="pbcopy <"

co() {
  if [[ -t 0 ]]; then
    fc -ln -1 | awk '{$1=$1}1' | pbcopy
  else
    tee >(pbcopy)
  fi
}

export BAT_THEME="Visual Studio Dark+"

if command -v bat >/dev/null 2>&1; then
  unalias cat ccat >/dev/null 2>&1 || true
  cat() {
    if [[ -t 0 && -t 1 ]]; then
      command bat --theme="$BAT_THEME" --style=full --paging=auto "$@"
    else
      command bat --style=plain --paging=never "$@"
    fi
  }
  ccat() {
    cat "$@"
  }
elif command -v batcat >/dev/null 2>&1; then
  unalias cat ccat >/dev/null 2>&1 || true
  cat() {
    if [[ -t 0 && -t 1 ]]; then
      command batcat --theme="$BAT_THEME" --style=full --paging=auto "$@"
    else
      command batcat --style=plain --paging=never "$@"
    fi
  }
  ccat() {
    cat "$@"
  }
fi
