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

eval "$(starship init zsh)"

# Extended Sources

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.orbstack/shell/init.zsh ] && source ~/.orbstack/shell/init.zsh 2>/dev/null || :
[ -f ~/.cargo/env ] && . ~/.cargo/env

#
# Language Setup
#

# Ruby
if (( $+commands[rbenv] ))
then
  eval "$(rbenv init -)"
fi

# Node
if (( $+commands[fnm] ))
then
    eval "$(fnm env --use-on-cd)"
fi

# Python
if (( $+commands[pyenv] ))
then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi


alias d='docker $*'
alias dc='docker-compose $*'
alias drmi="docker images | fzf -m | awk '{print $3}' | xargs docker rmi"
alias drm="docker ps -a | fzf -m | awk '{print $1}' | xargs docker rm"


export EDITOR='code'

# Activate syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Disable underline (syntax highlighting)
# (( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
# ZSH_HIGHLIGHT_STYLES[path]=none
# ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# Activate autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

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
# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/mphilpot/.lmstudio/bin"
