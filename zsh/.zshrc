# shortcut to this dotfiles path is $ZSH
export ZSH=$HOME/.dotfiles

# Stash your environment variables in ~/.localrc. This means they'll stay out
# of your main dotfiles repository (which may be public, like this one), but
# you'll have access to them in your scripts.
if [[ -a ~/.localrc ]]
then
  source ~/.localrc
fi

export PATH="./bin:/usr/local/bin:/usr/local/sbin:$ZSH/bin:/opt/homebrew/bin:$PATH"

command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Extended Sources

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.orbstack/shell/init.zsh ] && source ~/.orbstack/shell/init.zsh 2>/dev/null || :
[ -f ~/.cargo/env ] && . ~/.cargo/env

#
# Language Setup
#
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
elif [ -x "$HOME/.local/bin/mise" ]; then
  eval "$("$HOME/.local/bin/mise" activate zsh)"
fi

alias d='docker $*'
alias dc='docker-compose $*'
alias drmi="docker images | fzf -m | awk '{print $3}' | xargs docker rmi"
alias drm="docker ps -a | fzf -m | awk '{print $1}' | xargs docker rm"


export EDITOR='code'

# Homebrew-installed zsh plugins (skipped where Homebrew is not available)
if command -v brew >/dev/null 2>&1; then
  brew_prefix="${HOMEBREW_PREFIX:-$(brew --prefix)}"
fi

# Activate syntax highlighting
[ -f "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && source "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Disable underline (syntax highlighting)
# (( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
# ZSH_HIGHLIGHT_STYLES[path]=none
# ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# Activate autosuggestions
[ -f "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt HIST_REDUCE_BLANKS

function k
{
    level=$1
    cdback=""
    for i in `seq 1 $level`
    do
        cdback=$cdback"../"
    done

    cd $cdback
}

umask 022
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh)"
