#!/usr/bin/env bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_tmux_option() {
  local option value default
  option="$1"
  default="$2"
  value="$(tmux show-option -gqv "$option")"

  if [ -n "$value" ]; then
    echo "$value"
  else
    echo "$default"
  fi
}

set() {
  local option=$1
  local value=$2
  tmux_commands+=(set-option -gq "$option" "$value" ";")
}

setw() {
  local option=$1
  local value=$2
  tmux_commands+=(set-window-option -gq "$option" "$value" ";")
}

main() {
  local theme
  theme="kanagawa"

  # Aggregate all commands in one array
  local tmux_commands=()

  # NOTE: Pulling in the selected theme by the theme that's being set as local
  # variables.
  source /dev/stdin <<<"$(sed -e "/^[^#].*=/s/^/local /" "${PLUGIN_DIR}/${theme}.tmuxtheme")"

  # status
  set status "on"
  set status-bg "${thm_bg}"
  set status-justify "left"
  set status-left-length "50"
  set status-right-length "150"

  # messages
  set message-style "fg=${thm_orange},bg=${thm_gray},align=centre"
  set message-command-style "fg=${thm_orange},bg=${thm_gray},align=centre"

  # panes
  set pane-border-style "fg=${thm_gray}"
  set pane-active-border-style "fg=${thm_blue}"

  # windows
  setw window-status-activity-style "fg=${thm_fg},bg=${thm_bg},none"
  setw window-status-separator ""
  setw window-status-style "fg=${thm_fg},bg=${thm_bg},none"

  #  Modes
  setw clock-mode-colour "${thm_blue}"
  setw mode-style "fg=${thm_orange} bg=${thm_gray} bold"

  local date_time
  readonly date_time="$(get_tmux_option "@kanagawa_date_time" "%H:%M")"

  # These variables are the defaults so that the setw and set calls are easier to parse.
  local git_branch
  readonly git_branch="#(cd #{pane_current_path}; git rev-parse --abbrev-ref HEAD)"

  local show_directory
  readonly show_directory="#[fg=$thm_green,bg=$thm_gray]  #{pane_current_path} #{?$git_branch,#[fg=$thm_fg]on #[fg=$thm_magenta] $git_branch,}"

  local show_session
  readonly show_session="#{?client_prefix,#[fg=$thm_orange],#[fg=$thm_fg]}#[bg=$thm_gray]  #S "

  local window_status_format
  readonly window_status_format="#[fg=$thm_fg,bg=$thm_bg] #I: #W "

  local window_status_current_format
  readonly window_status_current_format="#[fg=$thm_fg,bg=$thm_gray,underscore] #I: #W "

  local show_host
  readonly show_host="#[fg=$thm_fg,bg=$thm_gray] 󱩊 #(whoami)@#H "

  local show_date_time
  readonly show_date_time="#[fg=$thm_orange,bg=$thm_gray]  $date_time "

  set status-left ""
  set status-right "${show_directory} ${show_session} ${show_host} ${show_date_time}"

  setw window-status-format "${window_status_format}"
  setw window-status-current-format "${window_status_current_format}"

  tmux "${tmux_commands[@]}"
}

main "$@"
