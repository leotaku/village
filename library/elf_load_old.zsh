# elf-load.zsh -- cleanly loading and unloading elf

ELF_SCRIPTDIR="${0:A:h}"
source $ELF_SCRIPTDIR/elf.zsh

typeset -g ELF_INITIALIZED
typeset -g ELF_RESTORE_TRAPINT
typeset -g ELF_RESTORE_PROMPT
typeset -g ELF_RESTORE_RPROMPT
typeset -g ELF_RESTORE_PROMPT_2
typeset -g ELF_RESTORE_RPROMPT_2
typeset -g ELF_RESTORE_PROMPT_SUBST
typeset -gA ELF_USER_ZSH_HOOKS
typeset -gA ELF_USER_ZLE_HOOKS

function elf_setup {
    ELF_RESTORE_TRAPINT="$(declare -f TRAPINT)"
    ELF_RESTORE_PROMPT="$PS1"
    ELF_RESTORE_RPROMPT="$RPS1"
    
    #add-zsh-hook precmd elf_precmd
    add-zle-hook-widget line-init elf-line-init
    add-zle-hook-widget line-finish elf-line-finish
    #add-zle-hook-widget keymap-select elf-keymap-select

    if ! [[ -o PROMPT_SUBST ]]; then
        ELF_RESTORE_PROMPT_SUBST="1"
        setopt PROMPT_SUBST
    fi

    function TRAPINT {
        zle && _elf_line_reset
        return 128
    }

    for hook func in ${(kv)ELF_USER_ZSH_HOOKS}; do
        add-zsh-hook "$hook" "$func"
    done

    for hook widget in ${(kv)ELF_USER_ZLE_HOOKS}; do
        add-zle-hook-widget "$hook" "$widget"
    done

    PS1="$ELF_PROMPT"
    RPS1="$ELF_RPROMPT"
    PS2="$ELF_PROMPT_2"
    RPS2="$ELF_RPROMPT_2"

    ELF_INITIALIZED="1"
}

function elf_teardown {
    unset ELF_PROMPT
    unset ELF_RPROMPT
    unset ELF_FINISHED_PROMPT
    unset ELF_FINISHED_RPROMPT
    unset ELF_PROMPT_WORKER_CMDS
    unset ELF_PROMPT_WORKER_CALLBACKS

    unset psvar

    add-zle-hook-widget -d line-init elf-line-init
    add-zle-hook-widget -d line-finish elf-line-finish
    add-zle-hook-widget -d keymap-select elf-keymap-select
    
    eval "$ELF_RESTORE_TRAPINT"

    PS1="$ELF_RESTORE_PROMPT"
    RPS1="$ELF_RESTORE_RPROMPT"
    PS1="$ELF_RESTORE_PROMPT_2"
    RPS1="$ELF_RESTORE_RPROMPT_2"

    if [[ -n "$ELF_RESTORE_PROMPT_SUBST" ]]; then
        unsetopt PROMPT_SUBST
    fi

    for hook func in ${(kv)ELF_USER_ZSH_HOOKS}; do
        add-zsh-hook -d "$hook" "$func"
    done
    ELF_USER_ZSH_HOOKS=()

    for hook widget in ${(kv)ELF_USER_ZLE_HOOKS}; do
        add-zle-hook-widget -d "$hook" "$widget"
    done
    ELF_USER_ZLE_HOOKS=()

    ELF_INITIALIZED="0"
}

function elf_add_zsh_hook {
    local hook="$1"
    local func="$2"

    ELF_USER_ZSH_HOOKS[$hook]="$func"
}

function elf_add_zle_hook {
    local hook="$1"
    local func="$2"
    local widget="elf-user-widget-${func//_/-}"

    zle -N "$widget" "$func"
    ELF_USER_ZLE_HOOKS[$hook]="$widget"
}

