# elf.zsh -- easy (prompt)line formatting for zsh
# source $dir/elf.zsh

# originally motivated by the slowness and lack
# of configuration of existing zsh prompts
# and inspired by the elvish (https://elv.sh/)
# shell, elf.zsh offers a straightforward configuration
# framework for your own, fully asycronous modeline creations

# load lib

ELF_SCRIPTDIR="$(dirname $(realpath $0))"
source $ELF_SCRIPTDIR/aui.zsh

# prompt/line

typeset -g ELF_PROMPT
typeset -g ELF_RPROMPT
typeset -g ELF_FINISHED_PROMPT
typeset -g ELF_FINISHED_RPROMPT
typeset -gA ELF_RESETTED_VARS
typeset -gA ELF_PROMPT_WORKER_CMDS
typeset -gA ELF_PROMPT_WORKER_CALLBACKS

function elf_add {
    local section="$2"
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

    if [[ -n "$ELF_PROMPT_INITIALIZED" ]]; then
        PS1="$ELF_PROMPT"
        RPS1="$ELF_RPROMPT"
    fi
}

function elf_add_async {
    local which_prompt="$1"
    local variable="ELF_VARS_$2"
    local cmd="$3"
    local callback="$4"

    elf_add "$which_prompt" "\$$variable" || return 1

    if [[ -z "$cmd" ]] && [[ -z "$callback" ]]; then
        return 0
    fi
    
    if [[ -n "$cmd" ]] && [[ -z "$callback" ]]; then
        echo "elf_add_async: please specify a callback" 1>&2
        return 1
    fi

    ELF_PROMPT_WORKER_CMDS[$variable]="$cmd"
    ELF_PROMPT_WORKER_CALLBACKS[$variable]="$callback"
}

function elf_prompt_line_init {
    local variable
    local cmd
    local callback
    local worker
    
    for variable cmd in ${(kv)ELF_PROMPT_WORKER_CMDS}; do
        callback="${ELF_PROMPT_WORKER_CALLBACKS[$variable]}"
        worker="${variable}_worker"
        aui_stop_worker "$worker" &>/dev/null
        aui_start_worker "$worker"
        aui_run_worker "$WORKER" "$cmd" "(){ local NEW; shift; $callback "\$@"; if [[ \$NEW != \$$variable ]]; then $variable=\$NEW; zle reset-prompt; fi; }"
    done
}

function elf_prompt_line_reset {
    PS1="$ELF_FINISHED_PROMPT"
    RPS1="$ELF_FINISHED_RPROMPT"
    zle reset-prompt
    PS1="$ELF_PROMPT"
    RPS1="$ELF_RPROMPT"
}

# vi cursors

typeset -g ELF_VI_SUPPORTED_TERMS=('screen-256color'
                                     'xterm-256color'
                                     'tmux-256color'
                                     'xterm-kitty')

typeset -gA ELF_VI_CURSORS=('normal' '\033[2 q' 
                              'insert' '\033[6 q' 
                              'vline' '\033[4 q')

function elf_vi_change_cursor {
    if [[ "$KEYMAP" == "main" ]]; then
        elf_vi_set_insert_cursor
    elif [[ "$KEYMAP" == "vicmd" ]]; then
        elf_vi_set_normal_cursor
    else 
        return
    fi
}

function elf_vi_set_normal_cursor {
    [[ "$ELF_VI_SUPPORTED_TERMS" =~ "$TERM" ]] || return 1
    printf "${ELF_VI_CURSORS[normal]}"
}

function elf_vi_set_insert_cursor {
    [[ "$ELF_VI_SUPPORTED_TERMS" =~ "$TERM" ]] || return 1
    printf "${ELF_VI_CURSORS[insert]}"
}


# widgets
# widget names should always be kebab-case

function elf-prompt-line-init { elf_prompt_line_init; }
function elf-prompt-line-finish { elf_prompt_line_reset; }

function elf-vi-change-cursor { elf_vi_change_cursor; }
function elf-vi-set-normal-cursor { elf_vi_set_normal_cursor; }
function elf-vi-set-insert-cursor { elf_vi_set_insert_cursor; }

function elf-both-line-init {
    elf_vi_set_insert_cursor
    elf_prompt_line_init
}

function elf-both-line-finish {
    elf_prompt_line_reset
    elf_vi_set_normal_cursor
}

# initialization

typeset -g ELF_PROMPT_INITIALIZED
typeset -g ELF_VI_INITIALIZED

function elf_prompt_initialize {
    PS1="$ELF_PROMPT"
    RPS1="$ELF_RPROMPT"
    
    zle -N zle-line-init elf-prompt-line-init
    zle -N zle-line-finish elf-prompt-line-finish

    function TRAPINT {
        elf_prompt_line_reset
        return 128
    }

    ELF_PROMPT_INITIALIZED="1"
}

function elf_vi_initialize {
    zle -N zle-keymap-select elf-vi-change-cursor
    zle -N zle-line-init elf-vi-set-insert-cursor
    zle -N zle-line-finish elf-vi-set-normal-cursor

    ELF_VI_INITIALIZED="1"
}

function elf_both_initialize {
    elf_vi_initialize
    elf_prompt_initialize

    zle -N zle-line-init elf-both-line-init
    zle -N zle-line-finish elf-both-line-finish
}
