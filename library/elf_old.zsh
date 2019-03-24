# elf.zsh -- easy (prompt)line formatting for zsh

# originally motivated by the slowness and lack
# of configuration of existing zsh prompts
# and inspired by the elvish (https://elv.sh/)
# shell, elf.zsh offers a straightforward configuration
# framework for your own, fully asycronous modeline creations

# load lib

ELF_SCRIPTDIR="${0:A:h}"
source $ELF_SCRIPTDIR/aui.zsh
autoload -Uz add-zsh-hook add-zle-hook-widget

# setup/teardown

typeset -g ELF_PROMPT=""
typeset -g ELF_RPROMPT=""
typeset -g ELF_PROMPT_2=""
typeset -g ELF_RPROMPT_2=""
typeset -g ELF_FINISHED_PROMPT=""
typeset -g ELF_FINISHED_RPROMPT=""
typeset -gA ELF_PROMPT_WORKER_CMDS=()
typeset -gA ELF_PROMPT_WORKER_CALLBACKS=()

# prompt/line

# function elf_expand {
#     local section="$1"
#     local reset="%{%f%k%b%u%s%}"
#     local newline=$'\n%{\r%}'
# 
#     section="${section//\%R/$reset}"
#     section="${section//\%r/$newline}"
# 
#     echo -n "$section"
# }

function elf_add {
    which_prompt="$1"; shift

    for section in "${@}"; do
        _elf_add "$which_prompt" "$section"
    done
}

function _elf_add {
    local which_prompt="$1"
    local section="$2"

    local reset="%{%f%k%b%u%s%}"
    local newline=$'\n%{\r%}'
    local invert=$'%{\e[7m%}'

    section="$section%R"
    section="${section//\%R/$reset}"
    section="${section//\%r/$newline}"
    section="${section//\%a/$invert}"

    case $which_prompt; in
        la)
            ELF_PROMPT="$ELF_PROMPT$section";;
        ra)
            ELF_RPROMPT="$ELF_RPROMPT$section";;
        lf)
            ELF_FINISHED_PROMPT="$ELF_FINISHED_PROMPT$section";;
        rf)
            ELF_FINISHED_RPROMPT="$ELF_FINISHED_RPROMPT$section";;
        l2)
            ELF_PROMPT_2="$ELF_PROMPT_2$section";;
        r2)
            ELF_RPROMPT_2="$ELF_RPROMPT_2$section";;
        *)
            echo "elf_add: please specify a valid prompt location: la|ra|lf|rf|l2|r2" 1>&2
            return 1;;
    esac
}

function elf_register_async {
    local identifier="$1"
    local cmd="$2"
    local callback="$3"

    case $identifier in
        1|2|3|4|5|6|7|8|9);;
        *)
            echo "elf_register_async: please specify a valid identifier (1-9)"
            return 1;;
    esac

    if [[ -z "$cmd" ]] || [[ -z "$callback" ]]; then
        echo "elf_register_async: please specify a command as well as a callback" 1>&2
        return 1
    fi

    ELF_PROMPT_WORKER_CMDS[$identifier]="$cmd"
    ELF_PROMPT_WORKER_CALLBACKS[$identifier]="$callback"
}

function _elf_line_init {
    local identifier
    local cmd
    local callback
    local worker
    
    for identifier cmd in ${(kv)ELF_PROMPT_WORKER_CMDS}; do
        callback="${ELF_PROMPT_WORKER_CALLBACKS[$identifier]}"
        worker="${identifier}_worker"
        aui_stop_worker "$worker" &>/dev/null
        aui_start_worker "$worker"
        aui_run_worker "$WORKER" "$cmd" "_elf_line_callback $identifier '(){$callback; true}'"
    done
}

function _elf_line_callback {
    local identifier="$1"
    local callback="$2"
    local NEW
    shift 3;

    eval "$callback \"$@\"" || {
        echo "_elf_line_callback: eval error occured"
        echo "$callback $@"
    }

    if [[ "$NEW" != "${psvar[$identifier]}" ]]; then 
        psvar[$identifier]="$NEW"
        zle reset-prompt 
    fi
}


# TODO: missed optimization opportunity: manually expand prompts and check for changes
function _elf_line_reset {
    PS1="$ELF_FINISHED_PROMPT"
    RPS1="$ELF_FINISHED_RPROMPT"
    zle reset-prompt
    PS1="$ELF_PROMPT"
    RPS1="$ELF_RPROMPT"
}

# function elf_precmd {
#     PS1="$ELF_PROMPT"
#     RPS1="$ELF_RPROMPT"
# }

# TODO:
# function elf_keymap_select {
#     PURA_PROMPT_CHAR="${${KEYMAP/vicmd/❮}/(main|viins)/❯}"
#     zle .reset-prompt
# }

# widgets
# widget names should always be kebab-case

zle -N elf-line-init _elf_line_init
zle -N elf-line-finish _elf_line_reset
# zle -N elf-keymap-select _elf_keymap_select
