if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
    fish_add_path /opt/homebrew/bin
    fish_add_path ~/.dotfiles/bin

    alias d='docker'
    alias dc='docker-compose'
    alias drmi="docker images | fzf -m | awk '{print $3}' | xargs docker rmi"
    alias drm="docker ps -a | fzf -m | awk '{print $1}' | xargs docker rm"

    if type -q pyenv
        pyenv init - | source
    end

    if type -q fnm
        fnm env --use-on-cd --shell fish | source
    end

    if type -q rbenv
        . (rbenv init - | source)
    end

    set -U fish_greeting "🐟"
end
