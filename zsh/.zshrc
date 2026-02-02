# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Startup banner (optional art/info tools)
command -v pokego >/dev/null && pokego --no-title -r 1,3,6

# ---------------------
# Zinit Configuration
# ---------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Oh-My-Zsh plugin snippets (managed via Zinit)
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# ---------------------
# Keybindings
# ---------------------
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# ---------------------
# History Settings
# ---------------------
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# ---------------------
# Completion Styling
# ---------------------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# ---------------------
# Aliases
# ---------------------
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
# alias nvidia-smi="watch -n 1 nvidia-smi"
alias fetch="fastfetch"

# ---------------------
# Utility Functions
# ---------------------

# Yazi (file manager with directory restore)
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
export EDITOR=code

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

# ---------------------
# Miscellaneous
# ---------------------

# Fix cursor style in tmux
if [[ $TERM =~ "screen" ]]; then
  echo -ne "\e[5 q"
fi

# Zoxide + FZF integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Add user local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# source starship
# eval "$(starship init zsh)"
# export STARSHIP_CONFIG=~/.config/starship/starship.toml

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/dikpal/.dart-cli-completion/zsh-config.zsh ]] && . /home/dikpal/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

# QT Platform theme
export QT_QPA_PLATFORMTHEME=qt5ct

source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Disable window decorations
export GTK_CSD=0
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
# export GTK_THEME=Adwaita:dark

export EDITOR=nvim

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

export PATH="$HOME/.cargo/bin:$PATH"
