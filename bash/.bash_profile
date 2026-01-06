# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# =====================
# Startup banner
# =====================
if command -v pokego >/dev/null 2>&1; then
  pokego --no-title -r 1,3,6
fi

# =====================
# History Settings
# =====================
HISTSIZE=5000
HISTFILE=~/.bash_history
HISTFILESIZE=$HISTSIZE

# ignore duplicates and commands starting with space
HISTCONTROL=ignoreboth:erasedups

# append to history file, don't overwrite
shopt -s histappend

# share history between sessions (approximate zsh's sharehistory)
PROMPT_COMMAND='history -a; history -n; '"$PROMPT_COMMAND"

# =====================
# Keybindings (readline)
# =====================
# Emacs-style keybindings (default in bash, but we set anyway)
set -o emacs

# Ctrl-p / Ctrl-n search history by prefix
bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'

# Alt-w: kill region (similar to kill-region in zsh)
bind '"\ew": kill-region'

# =====================
# Bash Completion
# =====================
if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# =====================
# Aliases
# =====================
alias ls='eza -1 --icons=auto'
alias l='eza -lh --icons=auto'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias ld='eza -lhD --icons=auto'
alias lt='eza --icons=auto --tree'
alias mkdir='mkdir -p'
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias fastfetch='fastfetch --logo-type kitty'
alias c='clear'
alias t="tmux -f ~/.config/tmux/tmux.conf"
alias tn="tmux new-session -s"
alias tl="tmux list-sessions"
alias ta="tmux attach-session"
alias dwmstart="startx"
alias hyprstart="./start_hyprland.sh"
alias spotify="spotify_player"
alias v="nvim"

# =====================
# Utility Functions
# =====================

# Yazi (file manager with directory restore)
y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# Pacman shorthand
p() {
  case "$1" in
    s)    shift; sudo pacman -S "$@" ;;
    R)    shift; sudo pacman -R "$@" ;;
    Rns)  shift; sudo pacman -Rns "$@" ;;
    Ss)   shift; pacman -Ss "$@" ;;
    Q)    shift; pacman -Q "$@" ;;
    Qe)   shift; pacman -Qe "$@" ;;
    Qdtq) shift; pacman -Qdtq "$@" ;;
    Syu)  sudo pacman -Syu ;;
    Sy)   sudo pacman -Sy ;;
    Syyu) sudo pacman -Syyu ;;
    *)    echo "Unknown shorthand: $1" ;;
  esac
}

# Yay shorthand
a() {
  case "$1" in
    s)    shift; yay -S "$@" ;;
    R)    shift; yay -R "$@" ;;
    Rns)  shift; yay -Rns "$@" ;;
    Ss)   shift; yay -Ss "$@" ;;
    Syu)  yay -Syu ;;
    Sy)   yay -Sy ;;
    Syyu) yay -Syyu ;;
    Q)    shift; yay -Q "$@" ;;
    Qe)   shift; yay -Qe "$@" ;;
    Qdtq) shift; yay -Qdtq "$@" ;;
    *)    echo "Unknown yay shorthand: $1" ;;
  esac
}

# =====================
# Miscellaneous
# =====================

# Fix cursor style in tmux
if [[ $TERM =~ screen ]]; then
  echo -ne "\e[5 q"
fi

# FZF integration
if command -v fzf >/dev/null 2>&1; then
  # If you installed fzf with its installer, this file exists
  if [ -f ~/.fzf.bash ]; then
    . ~/.fzf.bash
  fi
fi

# Add user local bin to PATH
export PATH="$HOME/.local/bin:$HOME/.local/share/bob/nvim-bin:$PATH"

# QT / GTK options
export QT_QPA_PLATFORMTHEME=qt5ct
export GTK_CSD=0
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
# export GTK_THEME=Adwaita:dark

# Editor + FZF defaults
export EDITOR=nvim
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
#
# ===== Starship prompt =====
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# Dart CLI completion (adjust if you have a bash script for it)
# Example (if it exists):
# [[ -f /home/dikpal/.dart-cli-completion/bash-config.bash ]] && \
#   . /home/dikpal/.dart-cli-completion/bash-config.bash || true

# =====================
# fzf-tab style completion (fzf for everything on TAB)
# =====================

# make sure fzf exists
if command -v fzf >/dev/null 2>&1; then

  _fzf_tab_complete() {
    local line point left right word is_first candidates selected

    # Current line & cursor position from readline
    line=${READLINE_LINE}
    point=${READLINE_POINT}

    left=${line:0:point}   # Text before cursor
    right=${line:point}    # Text after cursor

    # Current "word" before cursor (split by spaces – simple but works)
    word=${left##* }

    # Is this the first word in the line? (command position)
    if [[ "$left" == "$word" ]]; then
      is_first=1
    else
      is_first=0
    fi

    # Build candidate list
    candidates=""

    if [[ $is_first -eq 1 ]]; then
      # First token: commands + files
      candidates+=$(compgen -c -- "$word")
      candidates+=$'\n'"$(compgen -f -- "$word")"
    else
      # Later tokens: files/dirs
      candidates+=$(compgen -f -- "$word")
      candidates+=$'\n'"$(compgen -d -- "$word")"
    fi

    # Remove empty lines
    candidates=$(printf '%s\n' "$candidates" | sed '/^$/d' | sort -u)
    [[ -z "$candidates" ]] && return 0

    # Use fzf to pick one
    selected=$(
      printf '%s\n' "$candidates" | fzf \
        --height=40% \
        --layout=reverse \
        --border \
        --prompt='> ' \
        --query="$word" \
        --select-1 \
        --exit-0 \
        --bind 'tab:down,btab:up'
    ) || return 0


    # Replace the word under cursor with the selected completion
    # left_without_word = left with the last occurrence of $word trimmed off
    local left_without_word=${left%$word}

    READLINE_LINE="${left_without_word}${selected}${right}"
    READLINE_POINT=${#READLINE_LINE}
  }

  # Bind TAB (Ctrl-i) to our fzf completer
  bind -x '"\C-i": _fzf_tab_complete'
fi

export PATH="$HOME/.cargo/bin:$PATH"

# Zoxide integration
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash --cmd cd)"
fi

