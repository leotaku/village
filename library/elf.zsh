# elf.zsh -- easy (prompt)line formatting for zsh

# originally motivated by the slowness and lack
# of configuration of existing zsh prompts
# and inspired by the elvish (https://elv.sh/)
# shell, elf.zsh offers a straightforward configuration
# framework for your own, fully asycronous modeline creations

# load lib

ELF_SCRIPTDIR="$(dirname $(realpath $0))"
source $ELF_SCRIPTDIR/aui.zsh

autoload -Uz add-zsh-hook add-zle-hook-widget
setopt PROMPT_SUBST

# setup/teardown

typeset -g ELF_INITIALIZED
typeset -g ELF_RESTORE_TRAPINT
typeset -g ELF_RESTORE_PROMPT
typeset -g ELF_RESTORE_RPROMPT

function elf_setup {
    ELF_RESTORE_TRAPINT="$(declare -f TRAPINT)"
    ELF_RESTORE_PROMPT="$PS1"
    ELF_RESTORE_RPROMPT="$RPS1"
    
    add-zsh-hook precmd elf_precmd
    add-zle-hook-widget line-init elf-line-init
    add-zle-hook-widget line-finish elf-line-finish
    add-zle-hook-widget keymap-select elf-keymap-select

    function TRAPINT {
        zle && elf_line_reset
        return 128
    }

    elf_maybe_teardown_additional || return 1
    elf_maybe_setup_additional || return 1

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

    add-zsh-hook -d precmd elf_precmd
    add-zle-hook-widget -d line-init elf-line-init
    add-zle-hook-widget -d line-finish elf-line-finish
    add-zle-hook-widget -d keymap-select elf-keymap-select
    
    eval "$ELF_RESTORE_TRAPINT"

    PS1="$ELF_RESTORE_PROMPT"
    RPS1="$ELF_RESTORE_RPROMPT"

    elf_maybe_teardown_additional || return 1

    ELF_INITIALIZED="0"
}

function elf_maybe_setup_additional {
    if declare -f elf_additional_setup&>/dev/null; then
        elf_additional_setup || return 1
        unset -f elf_additional_setup
    fi
}

function elf_maybe_teardown_additional {
    if declare -f elf_additional_teardown&>/dev/null; then
        elf_additional_teardown || return 1
        unset -f elf_additional_teardown
    fi
}

function elf_register {
    if [[ "$ELF_INITIALIZED" == "1" ]]; then
        elf_maybe_setup_additional
    fi
}

if [[ "$ELF_INITIALIZED" == "1" ]]; then
    elf_maybe_teardown_additional
fi

typeset -g ELF_PROMPT=""
typeset -g ELF_RPROMPT=""
typeset -g ELF_FINISHED_PROMPT=""
typeset -g ELF_FINISHED_RPROMPT=""
typeset -gA ELF_PROMPT_WORKER_CMDS=()
typeset -gA ELF_PROMPT_WORKER_CALLBACKS=()

# prompt/line

function elf_add {
    local section="$2%f%k%b%u%s"
    local which_prompt="$1"

    case $which_prompt; in
        la)
            ELF_PROMPT="$ELF_PROMPT$section";;
        ra)
            ELF_RPROMPT="$ELF_RPROMPT$section";;
        lf)
            ELF_FINISHED_PROMPT="$ELF_FINISHED_PROMPT$section";;
        rf)
            ELF_FINISHED_RPROMPT="$ELF_FINISHED_RPROMPT$section";;
        no);;
        *)
            echo "elf_add: please specify a valid prompt type: la|ra|lf|rf|no" 1>&2
            return 1;;
    esac
}

function elf_add_async {
    local which_prompt="$1"
    local identifier="$2"
    local cmd="$3"
    local callback="$4"

    elf_add "$which_prompt" "\$psvar[$identifier]" || return 1

    if [[ -z "$cmd" ]] && [[ -z "$callback" ]]; then
        return 0
    fi
    
    if [[ -n "$cmd" ]] && [[ -z "$callback" ]]; then
        echo "elf_add_async: please specify a callback" 1>&2
        return 1
    fi

    ELF_PROMPT_WORKER_CMDS[$identifier]="$cmd"
    ELF_PROMPT_WORKER_CALLBACKS[$identifier]="$callback"
}

function elf_line_init {
    local identifier
    local cmd
    local callback
    local worker
    
    for identifier cmd in ${(kv)ELF_PROMPT_WORKER_CMDS}; do
        callback="${ELF_PROMPT_WORKER_CALLBACKS[$identifier]}"
        worker="${identifier}_worker"
        aui_stop_worker "$worker" &>/dev/null
        aui_start_worker "$worker"
        aui_run_worker "$WORKER" "$cmd" "(){ local NEW; shift; $callback "\$@"; if [[ \$NEW != \${psvar[$identifier]} ]]; then psvar[$identifier]=\$NEW; zle reset-prompt; fi; }"
    done
}

# TODO: missed optimization opportunity: manually expand prompts and check for changes
function elf_line_reset {
    PS1="$ELF_FINISHED_PROMPT"
    RPS1="$ELF_FINISHED_RPROMPT"
    zle reset-prompt
    PS1="$ELF_PROMPT"
    RPS1="$ELF_RPROMPT"
}

function elf_precmd {
    PS1="$ELF_PROMPT"
    RPS1="$ELF_RPROMPT"
}

# TODO:
function elf_keymap_select {
    PURA_PROMPT_CHAR="${${KEYMAP/vicmd/❮}/(main|viins)/❯}"
    zle .reset-prompt
}

# widgets
# widget names should always be kebab-case

zle -N elf-line-init elf_line_init
zle -N elf-line-finish elf_line_reset
zle -N elf-keymap-select elf_keymap_select
