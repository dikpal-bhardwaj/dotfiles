#!/bin/bash

source "${HOME}/.cache/wal/colors.sh"

tmux popup -w 40% -h 40% -E "bash -c '
  source ${HOME}/.cache/wal/colors.sh
  selected=\$(tmux list-windows -a -F \"#{session_name}:#{window_index}:#{window_name}\" | fzf \
    --prompt=\"Window > \" \
    --color=fg:\$foreground,bg:\$background,hl:\$color5,fg+:\$color0,bg+:\$color13,hl+:\$color7)
  if [ -n \"\$selected\" ]; then
    session=\$(echo \"\$selected\" | cut -d\":\" -f1)
    window=\$(echo \"\$selected\" | cut -d\":\" -f2)
    tmux switch-client -t \"\$session\"
    tmux select-window -t \"\$session:\$window\"
  fi
'"
