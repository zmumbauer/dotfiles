#!/usr/bin/env bash
#
# Backstop for tmux-continuum, run on every tmux config load.
#
# continuum decides "another tmux server is running" by counting processes whose
# command starts with `tmux`, so extra clients trip it. When that happens it
# silently skips both auto-restore and autosave. This script re-checks using real
# sockets and does whatever continuum skipped. Everything is idempotent.
#
# Safety rule: while the server only holds untouched default sessions and the
# last save is richer, autosave stays off, because its first save would replace
# the good layout. `--after-restore` (resurrect's post-restore hook) lifts this.
#
# Decisions are logged to ~/.local/state/tmux-continuum-guard.log.

PLUGINS="${TMUX_PLUGIN_MANAGER_PATH:-$HOME/.tmux/plugins}"
PLUGINS="${PLUGINS%/}"
LOG="$HOME/.local/state/tmux-continuum-guard.log"

PLUGIN_WAIT=30    # seconds to wait for plugins to load
SETTLE=5          # seconds to let continuum's own restore start (it sleeps 1s)
FRESH_WINDOW=60   # a server younger than this counts as just started
IDLE_WAIT=10      # seconds to let shell startup commands finish
RECHECK=20        # theme re-application can drop the hook, so check once more

log() {
	mkdir -p "$(dirname "$LOG")"
	printf '%s server=%s %s\n' "$(date '+%F %T')" "$(tmux display -p '#{pid}' 2>/dev/null)" "$*" >>"$LOG"
}

option() { tmux show -gqv "$1" 2>/dev/null; }

server_alive() { tmux list-sessions >/dev/null 2>&1; }

# True if another live tmux server shares our socket directory. Oh My Tmux's
# temporary plugin-discovery probes are not real servers.
other_server_running() {
	local own dir sock
	own="$(tmux display -p '#{socket_path}')"
	dir="$(dirname "$own")"
	for sock in "$dir"/*; do
		[ -S "$sock" ] && [ "$sock" != "$own" ] || continue
		case "$(basename "$sock")" in tmux-discover-plugins-*) continue ;; esac
		tmux -S "$sock" list-sessions >/dev/null 2>&1 && return 0
	done
	return 1
}

# True if every session is an auto-numbered one with a single window and pane.
only_default_sessions() {
	! tmux list-panes -a -F '#{session_name} #{session_windows} #{window_panes}' |
		grep -qvE '^[0-9]+ 1 1$'
}

saved_pane_count() {
	# shellcheck disable=SC1091
	source "$PLUGINS/tmux-resurrect/scripts/helpers.sh"
	cat "$(last_resurrect_file)" 2>/dev/null | grep -c '^pane'
}

# Restoring over a richer layout is only useful if this server has nothing yet.
layout_at_risk() {
	only_default_sessions && [ "$(saved_pane_count)" -gt "$(tmux list-panes -a | wc -l)" ]
}

just_started() {
	[ $(($(date +%s) - $(tmux display -p '#{start_time}'))) -le "$FRESH_WINDOW" ]
}

restore_enabled() {
	[ "$(option @continuum-restore)" = "on" ] && [ ! -f "$HOME/tmux_no_auto_restore" ]
}

# Waits for every pane to sit at a shell, so a running program is never killed.
panes_idle() {
	local i
	for ((i = 0; i < IDLE_WAIT; i++)); do
		tmux list-panes -a -F '#{pane_current_command}' | sed 's/^-//' |
			grep -qvxE '(ba|z|da|k|fi)?sh' || return 0
		sleep 1
	done
	return 1
}

save_script() {
	echo "$(cd "$PLUGINS/tmux-continuum" 2>/dev/null && pwd)/scripts/continuum_save.sh"
}

ensure_autosave() {
	local script current
	script="$(save_script)"
	[ -x "$script" ] || { log "continuum_save.sh not found"; return 1; }
	current="$(option status-right)"
	case "$current" in *continuum_save.sh*) return 0 ;; esac
	# Without a timestamp the first status refresh would save immediately.
	[ -n "$(option @continuum-save-last-timestamp)" ] ||
		tmux set -gq @continuum-save-last-timestamp "$(date +%s)"
	tmux set -gq status-right "#($script)$current" && log "autosave hook installed"
}

remove_autosave() {
	local current hook
	current="$(option status-right)"
	hook="#($(save_script))"
	case "$current" in *"$hook"*) tmux set -gq status-right "${current//"$hook"/}" ;; esac
}

# continuum can add its hook on a config reload, possibly after our first check.
hold_autosave() {
	log "autosave held: $1"
	remove_autosave
	tmux display -d 8000 "tmux-continuum-guard: autosave held to protect your last save ($1). Restore with prefix + R." 2>/dev/null
	sleep "$RECHECK"
	server_alive && layout_at_risk && remove_autosave
}

if [ "$1" = "--after-restore" ]; then
	other_server_running && { log "after-restore: another server is running"; exit 0; }
	ensure_autosave
	exit 0
fi

waited=0
until [ -n "$(option @resurrect-restore-script-path)" ]; do
	server_alive || exit 0
	[ "$waited" -ge "$PLUGIN_WAIT" ] && { log "plugins did not load in time"; exit 0; }
	sleep 1
	waited=$((waited + 1))
done
sleep "$SETTLE"
server_alive || exit 0

if other_server_running; then
	log "another server is running, leaving continuum's decision alone"
	exit 0
fi

if layout_at_risk; then
	just_started || { hold_autosave "server has only default sessions"; exit 0; }
	restore_enabled || { hold_autosave "auto-restore is off"; exit 0; }
	panes_idle || { hold_autosave "a pane is busy"; exit 0; }
	# -o fails if already set, so only one guard per server can restore.
	if tmux set -s -o @continuum-guard-restored 1 2>/dev/null; then
		log "continuum did not restore, restoring now"
		"$(option @resurrect-restore-script-path)" >/dev/null 2>&1
	fi
	if layout_at_risk; then
		hold_autosave "restore did not complete"
		exit 0
	fi
fi

ensure_autosave
sleep "$RECHECK"
server_alive || exit 0
layout_at_risk || ensure_autosave
exit 0
