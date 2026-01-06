#!/bin/bash

source "${HOME}/.cache/wal/colors.sh"

tmux popup -w 40% -h 40% -E "bash -c '
  source ${HOME}/.cache/wal/colors.sh
  selected=\$(tmux list-sessions -F \"#{session_name}\" | fzf \
    --prompt=\"Session > \" \
    --color=fg:\$foreground,bg:\$background,hl:\$color5,fg+:\$color0,bg+:\$color13,hl+:\$color7)
  if [ -n \"\$selected\" ]; then
    tmux switch-client -t \"\$selected\"
  fi
'"
