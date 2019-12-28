# dwarf.zsh - change cursors shape based on vi state
#
# NOTE: For optimal responsiveness this feature should be
# NOTE: initialized before elf

# Load lib

autoload -Uz add-zsh-hook add-zle-hook-widget

# Variables

typeset -g DWARF_DELAY=0.1

typeset -gA DWARF_CURSORS=(
    'normal' '\033[2 q'
    'insert' '\033[6 q'
    'vline' '\033[4 q'
)

# Functions

function _dwarf_change_cursor {
    if [[ "$KEYMAP" == "main" ]]; then
        _dwarf_set_insert_cursor
    elif [[ "$KEYMAP" == "vicmd" ]]; then
        _dwarf_set_normal_cursor
    else
        return
    fi
}

function _dwarf_set_normal_cursor {
    printf "${DWARF_CURSORS[normal]}"
}

function _dwarf_set_insert_cursor {
    printf "${DWARF_CURSORS[insert]}"
}

function _dwarf_line_init {
    _dwarf_set_insert_cursor
    kill $_DWARF_NORMAL_PROCESS &>/dev/null
}

function _dwarf_line_finish {
    { sleep "$DWARF_DELAY" && _dwarf_set_normal_cursor } &!
    _DWARF_NORMAL_PROCESS=$!
}

# Widgets

zle -N _dwarf-keymap-select _dwarf_change_cursor
zle -N _dwarf-line-init _dwarf_line_init
zle -N _dwarf-line-finish _dwarf_line_finish

# Initialization

function dwarf_setup {
    ((DWARF_INITIALIZED == 1)) && return 1

    add-zle-hook-widget keymap-select _dwarf-keymap-select
    add-zle-hook-widget line-init _dwarf-line-init
    add-zle-hook-widget line-finish _dwarf-line-finish

    DWARF_INITIALIZED=1
}

function dwarf_teardown {
    ((DWARF_INITIALIZED =! 1)) && return 1

    add-zle-hook-widget -d keymap-select _dwarf-keymap-select
    add-zle-hook-widget -d line-init _dwarf-line-init
    add-zle-hook-widget -d line-finish _dwarf-line-finish

    DWARF_INITIALIZED=0
}
