# zmodload zsh/zprof
### environment variables
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
	export ZSH_CONFIG_OS="WSL"
	# set alias for windows executables
	alias \
	f='/mnt/c/Windows/explorer.exe' \
	rg='rg.exe' \
	bat='bat.exe' \
	fzf='fzf.exe' \
	lsd='lsd.exe' \
	python='python.exe'
else
	export ZSH_CONFIG_OS="Linux"
fi

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# set zsh config directory
export ZSH_DATA="$XDG_CONFIG_HOME/zsh"
# set default editor
export EDITOR='code'
export VISUAL='code'
if [[ $ZSH_CONFIG_OS == "WSL" ]]; then
	# like $PATH, cd search subdirectories, frequently used parent directories
	export CDPATH='/mnt/c/main:/mnt/code:/mnt/c/main/config:/mnt/c/User/Vinh':"$HOME":".."
fi
# https://github.com/sharkdp/bat
export BAT_THEME='ansi'
# https://github.com/junegunn/fzf
export FZF_DEFAULT_OPTS='--multi --no-height --extended --reverse'
# https://github.com/ajeetdsouza/zoxide
export _ZO_DATA_DIR="$ZSH_DATA/zoxide"
export _ZO_RESOLVE_SYMLINKS=1
# dev
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/pycache"
export RUFF_CACHE_DIR="$XDG_CACHE_HOME/ruff"

### history configuration
HISTFILE="$ZSH_DATA/history.txt"
[[ -f '/mnt/c/main/config/ubuntu-wsl/zsh/history.txt' ]] && HISTFILE='/mnt/c/main/config/ubuntu-wsl/zsh/history.txt'
HISTSIZE=9999
SAVEHIST=9999
# HISTORY_IGNORE="(c|e|f|z|la|ll|ls|pwd|exit|clear|cd ..)"

setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY

### shell options
setopt autocd
setopt extendedglob
setopt nobeep
setopt interactivecomments

# Enable Powerlevel10k instant prompt. Should stay close to the top of .zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

autoload -Uz run-help
# autoload -Uz compinit
# compinit

# zstyle '*:compinit' arguments -u -i -C
zstyle ':completion:*:*:-command-:*:*' ignored-patterns "${(@f)$(< $ZSH_DATA/ignore-commands.txt)}"
# Use cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompcache"

### plugins
# https://github.com/zdharma-continuum/fast-syntax-highlighting
source "$ZSH_DATA/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
# https://github.com/marlonrichert/zsh-autocomplete
source "$ZSH_DATA/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
# https://github.com/romkatv/powerlevel10k
source "$ZSH_DATA/powerlevel10k/powerlevel10k.zsh-theme"

# docker autocomplete
# source <(docker completion zsh)
# https://github.com/greymd/docker-zsh-completion
source "$ZSH_DATA/docker-zsh-completion/docker-zsh-completion.plugin.zsh"

# zoxide is a smarter cd command
if command -v zoxide &> /dev/null; then
	eval "$(zoxide init zsh)"
fi

### customizations
# zstyle ':completion:*:*:docker:*' option-stacking yes
# zstyle ':completion:*:*:docker-*:*' option-stacking yes

## zsh-autocomplete plugin
# '': Start each new command line with normal autocompletion.
# history-incremental-search-backward: Start in live history search mode.
# zstyle ':autocomplete:*' default-context history-incremental-search-backward

# Wait this many seconds for typing to stop, before showing completions.
zstyle ':autocomplete:*' min-delay 0.05 # float

# Wait until this many characters have been typed, before showing completions.
zstyle ':autocomplete:*' min-input 1  # int

# '':     Always show completions.
# '..##': Don't show completions when the input consists of two or more dots.
# zstyle ':autocomplete:*' ignored-input '' # extended glob pattern

# If there are fewer than this many lines below the prompt, move the prompt up
# to make room for showing this many lines of completions (approximately).
zstyle ':autocomplete:*' list-lines 10  # int

# Show this many history lines when pressing ↑.
# zstyle ':autocomplete:history-search:*' list-lines 10  # int

# Show this many history lines when pressing ⌃R or ⌃S.
# zstyle ':autocomplete:history-incremental-search-*:*' list-lines 10  # int

# cdr:  Use Zsh's `cdr` function to show recent directories as completions.
# no:   Don't show recent directories.
# zsh-z|zoxide|z.lua|z.sh|autojump|fasd: Use this instead (if installed).
# ⚠️ NOTE: This setting can NOT be changed at runtime.
# zstyle ':autocomplete:*' recent-dirs zoxide

# Autocompletion
# zstyle -e ':autocomplete:list-choices:*' list-lines 'reply=( $(( LINES / 3 )) )'

# Override history search.
# zstyle ':autocomplete:history-incremental-search-backward:*' list-lines 10

# History menu.
# zstyle ':autocomplete:history-search-backward:*' list-lines 256

# no:  Tab uses Zsh's completion system only.
# yes: Tab first tries Fzf's completion, then falls back to Zsh's.
# ⚠️ NOTE: This setting can NOT be changed at runtime and requires that you
# have installed Fzf's shell extensions.
zstyle ':autocomplete:*' fzf-completion yes

# Add a space after these completions:
# zstyle ':autocomplete:*' add-space \
		# executables aliases functions builtins reserved-words commands

## color customization
# menu auto-complete
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} "ma=48;2;255;144;0;38;2;0;0;0"

## functions
zshaddhistory() {
  # ignore command less than 5 characters, start with space, end with semicolon, or multi-line
	c="${1%%[[:space:]]}"
  ! [[ ${#c} -lt 5 || $c == ' '* || $c == *';' || $c == *$'\n'* ]]
}
# https://wiki.archlinux.org/title/zsh#Clear_the_backbuffer_using_a_key_binding
function clear-screen-and-scrollback() {
	echoti civis >"$TTY"
	printf '%b' '\e[H\e[2J' >"$TTY"
	zle .reset-prompt
	zle -R
	printf '%b' '\e[3J' >"$TTY"
	echoti cnorm >"$TTY"
}
zle -N clear-screen-and-scrollback

### aliases
(( ${+aliases[run-help]} )) && unalias run-help
alias \
	..='cd ..' \
	...='cd ../..' \
  c=clear \
  e=exit \
  g=git \
  cp='cp -i' \
  gd=pushd \
  la='lsd -a' \
  ll=lsd \
  ls='ls --color=auto' \
	lt='lsd --tree' \
  mv='mv -i' \
  pd=popd \
  rm='rm -i' \
  dirs='dirs -v' \
  help=run-help

### key bindings
# https://wiki.archlinux.org/title/zsh#Key_bindings
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
# [[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
# [[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
# [[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
# [[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# Left, Right arrow
bindkey -M menuselect "${key[Left]}" .backward-char
bindkey -M menuselect "${key[Right]}" .forward-char

# Tab
# bindkey '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete
bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete

# Ctrl+L
bindkey '^L' clear-screen-and-scrollback

# Ctrl+Z
bindkey '^Z' undo

# To customize prompt, run `p10k configure` or edit /c/giga/data/zsh-windows/.p10k.zsh.
[[ ! -f "$ZSH_DATA/.p10k.zsh" ]] || source "$ZSH_DATA/.p10k.zsh"
# zprof
