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
alias ls='eza --long --header --icons --git'
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

export BAT_THEME="Coldark-Cold"

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --style=plain --paging=never'
  alias ccat='bat --theme="Coldark-Cold" --style=full --paging=always'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --style=plain --paging=never'
  alias ccat='batcat --theme="Coldark-Cold" --style=full --paging=always'
fi
