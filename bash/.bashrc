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

alias d='docker $*'
alias dc='docker-compose $*'
alias drmi="docker images | fzf -m | awk '{print $3}' | xargs docker rmi"
alias drm="docker ps -a | fzf -m | awk '{print $1}' | xargs docker rm"


export EDITOR='code'

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
