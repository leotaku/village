# rogue.zsh - make zsh startup appear faster with visual tricks

# Variables

typeset -g ROGUE_INITIALIZED

# Functions

function _rogue_print_prompt {
    printf $'\033[50D'
    printf $'\033[3C'

    setopt prompt_cr prompt_sp
    add-zsh-hook -d precmd _rogue_print_prompt
}

function _rogue_save_prompt {
    export _ROGUE_PROMPT="${(%%S)PS1}"
}

# Widgets

zle -N _rogue-save-prompt _rogue_save_prompt

# Initialization

function rogue_setup {
    ((ROGUE_INITIALIZED == 1)) && return 1

    unsetopt prompt_cr prompt_sp
    setopt PROMPT_SUBST

    function zsh {
        printf "${(%%S)PS1}"
        ((DWARF_INITIALIZED == 1)) && _dwarf_line_init
        command zsh
    }

    printf $'\033[50D'
    printf "${_ROGUE_PROMPT:-${(%%S)ELF_PROMPT}}"

    ((DWARF_INITIALIZED == 1)) && _dwarf_line_init

    add-zsh-hook precmd _rogue_print_prompt
    add-zle-hook-widget line-finish _rogue-save-prompt

    ROGUE_INITIALIZED=1
}

function rogue_teardown {
    ((ROGUE_INITIALIZED =! 1)) && return 1

    unset -f zsh
    add-zsh-hook -d precmd _rogue_print_prompt
    add-zle-hook-widget -d line-finish _rogue-save-prompt

    ROGUE_INITIALIZED=0
}
