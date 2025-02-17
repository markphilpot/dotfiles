if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
    fish_add_path /opt/homebrew/bin
    fish_add_path ~/.dotfiles/bin
    fish_add_path ~/.local/bin

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

    # Emulates vim's cursor shape behavior
    # Set the normal and visual mode cursors to a block
    set fish_cursor_default block
    # Set the insert mode cursor to a line
    set fish_cursor_insert line
    # Set the replace mode cursors to an underscore
    set fish_cursor_replace_one underscore
    set fish_cursor_replace underscore
    # Set the external cursor to a line. The external cursor appears when a command is started.
    # The cursor shape takes the value of fish_cursor_default when fish_cursor_external is not specified.
    set fish_cursor_external line
    # The following variable can be used to configure cursor shape in
    # visual mode, but due to fish_cursor_default, is redundant here
    set fish_cursor_visual block
    set fish_vi_force_cursor true

    fish_vi_key_bindings
end
