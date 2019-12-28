# elf-load.zsh -- cleanly loading and unloading elf

local ELF_SCRIPTDIR="${0:A:h}"
source "$ELF_SCRIPTDIR/elf.zsh"

typeset -g ELF_INITIALIZED
typeset -g _ELF_RESTORE_TRAPINT
typeset -g _ELF_RESTORE_PROMPT
typeset -g _ELF_RESTORE_RPROMPT
typeset -g _ELF_RESTORE_PROMPT_2
typeset -g _ELF_RESTORE_RPROMPT_2
typeset -g _ELF_RESTORE_PROMPT_SUBST

function elf_setup {
    ((ELF_INITIALIZED == 1)) && return 1

    _ELF_RESTORE_TRAPINT="$(declare -f TRAPINT)"
    _ELF_RESTORE_PROMPT="$PS1"
    _ELF_RESTORE_RPROMPT="$RPS1"
    _ELF_RESTORE_PROMPT_2="$PS2"
    _ELF_RESTORE_RPROMPT_2="$RPS2"

    if ! [[ -o PROMPT_SUBST ]]; then
        _ELF_RESTORE_PROMPT_SUBST="1"
        setopt PROMPT_SUBST
    fi

    function TRAPINT {
        zle && {
            for hook in ${_ELF_TRAPINT_HOOKS[@]}; do
                $hook
            done
        }

        return 128
    }

    PS1="$ELF_PROMPT"
    RPS1="$ELF_RPROMPT"
    PS2="$ELF_PROMPT_2"
    RPS2="$ELF_RPROMPT_2"

    for hook func in ${_ELF_ZSH_HOOKS}; do
        add-zsh-hook "$hook" "$func"
    done

    for hook widget in ${_ELF_ZLE_HOOKS}; do
        add-zle-hook-widget "$hook" "$widget"
    done

    ELF_INITIALIZED=1
}

function elf_teardown {
    ((ELF_INITIALIZED =! 1)) && return 1
    ((DWARF_INITIALIZED == 1)) && dwarf_teardown
    ((ROGUE_INITIALIZED == 1)) && rogue_teardown

    unset psvar
    eval "$_ELF_RESTORE_TRAPINT"

    PS1="$_ELF_RESTORE_PROMPT"
    RPS1="$_ELF_RESTORE_RPROMPT"
    PS2="$_ELF_RESTORE_PROMPT_2"
    RPS2="$_ELF_RESTORE_RPROMPT_2"

    if [[ -n "$_ELF_RESTORE_PROMPT_SUBST" ]]; then
        unsetopt PROMPT_SUBST
    fi

    for hook func in ${_ELF_ZSH_HOOKS}; do
        add-zsh-hook -d "$hook" "$func"
    done

    # HACK:
    # this hack is needed because changing zle hooks
    # on the fly causes strange behavior
    for hook widget in ${_ELF_ZLE_HOOKS}; do
        add-zle-hook-widget -d "$hook" "$widget"
    done

    ELF_INITIALIZED=0
}
