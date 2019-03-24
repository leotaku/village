# dwarf.zsh - change cursors shape based on vi state
#
# for optimal responsiveness this feature should be 
# initialized before elf

# load lib

autoload -Uz add-zsh-hook add-zle-hook-widget

# vi cursors

typeset -g DWARF_SUPPORTED_TERMS=('screen-256color'
                                  'xterm-256color'
                                  'tmux-256color'
                                  'xterm-kitty')

typeset -gA DWARF_CURSORS=('normal' '\033[2 q' 
                           'insert' '\033[6 q' 
                           'vline' '\033[4 q')

function dwarf_change_cursor {
    if [[ "$KEYMAP" == "main" ]]; then
        dwarf_set_insert_cursor
    elif [[ "$KEYMAP" == "vicmd" ]]; then
        dwarf_set_normal_cursor
    else 
        return
    fi
}

function dwarf_set_normal_cursor {
    [[ "$DWARF_SUPPORTED_TERMS" =~ "$TERM" ]] || return 1
    printf "${DWARF_CURSORS[normal]}"
}

function dwarf_set_insert_cursor {
    [[ "$DWARF_SUPPORTED_TERMS" =~ "$TERM" ]] || return 1
    printf "${DWARF_CURSORS[insert]}"
}

# widgets

zle -N dwarf-keymap-select dwarf_change_cursor
zle -N dwarf-line-init dwarf_set_insert_cursor
zle -N dwarf-line-finish dwarf_set_normal_cursor

# initialization

function dwarf_setup {
    add-zle-hook-widget keymap-select dwarf-keymap-select
    add-zle-hook-widget line-init dwarf-line-init
    add-zle-hook-widget line-finish dwarf-line-finish

    DWARF_INITIALIZED="1"
}

function dwarf_teardown {
    add-zle-hook-widget -d keymap-select dwarf-keymap-select
    add-zle-hook-widget -d line-init dwarf-line-init
    add-zle-hook-widget -d line-finish dwarf-line-finish

    DWARF_INITIALIZED="0"
}
