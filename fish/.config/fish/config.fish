if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
    fish_add_path /opt/homebrew/bin
    fish_add_path ~/.dotfiles/bin

    alias d='docker $argv'
    alias dc='docker-compose $argv'
    alias drmi="docker images | fzf -m | awk '{print $3}' | xargs docker rmi"
    alias drm="docker ps -a | fzf -m | awk '{print $1}' | xargs docker rm"

    set -U fish_greeting "🐟"
end
