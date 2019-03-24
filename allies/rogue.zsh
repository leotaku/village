# rogue.zsh - make zsh startup appear faster with visual tricks

typeset -g ROGUE_INITIALIZED

function rogue_setup {
    function zsh {
        echo -ne "${(%%S)PS1}"
        [[ "$DWARF_INITIALIZED" == "1" ]] && dwarf_set_insert_cursor
        command zsh $@
    }

    ROGUE_INITIALIZED="1"
}

function rogue_teardown {
    unset -f zsh
    ROGUE_INITIALIZED="0"
}
