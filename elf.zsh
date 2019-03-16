# elf.zsh -- easy (prompt)line formatting for zsh
# source $dir/elf.zsh

# originally inspired by the elvish (https://elv.sh/)
# shell, elf.zsh offers a straightforward configuration
# framework for your own, fully asycronous modeline creations

# load lib

ALINE_SCRIPTDIR="$(dirname $(realpath $0))"
source $ALINE_SCRIPTDIR/aui.zsh

# prompt/line

typeset -g ALINE_PROMPT
typeset -g ALINE_RPROMPT
typeset -g ALINE_FINISHED_PROMPT
typeset -g ALINE_FINISHED_RPROMPT
typeset -gA ALINE_RESETTED_VARS
typeset -gA ALINE_PROMPT_WORKER_CMDS
typeset -gA ALINE_PROMPT_WORKER_CALLBACKS

function aline_add {
    local section="$2"
    local which_prompt="$1"

    case $which_prompt; in
        la)
            ALINE_PROMPT="$ALINE_PROMPT$section";;
        ra)
            ALINE_RPROMPT="$ALINE_RPROMPT$section";;
        lf)
            ALINE_FINISHED_PROMPT="$ALINE_FINISHED_PROMPT$section";;
        rf)
            ALINE_FINISHED_RPROMPT="$ALINE_FINISHED_RPROMPT$section";;
        no);;
        *)
            echo "aline_add: please specify a valid prompt type: la|ra|lf|rf|no" 1>&2
            return 1;;
    esac

    if [[ -n "$ALINE_PROMPT_INITIALIZED" ]]; then
        PS1="$ALINE_PROMPT"
        RPS1="$ALINE_RPROMPT"
    fi
}

function aline_add_async {
    local which_prompt="$1"
    local variable="ALINE_VARS_$2"
    local cmd="$3"
    local callback="$4"

    aline_add "$which_prompt" "\$$variable" || return 1

    if [[ -z "$cmd" ]] && [[ -z "$callback" ]]; then
        return 0
    fi
    
    if [[ -n "$cmd" ]] && [[ -z "$callback" ]]; then
        echo "aline_add_async: please specify a callback" 1>&2
        return 1
    fi

    ALINE_PROMPT_WORKER_CMDS[$variable]="$cmd"
    ALINE_PROMPT_WORKER_CALLBACKS[$variable]="$callback"
}

function aline_prompt_line_init {
    local variable
    local cmd
    local callback
    local worker
    
    for variable cmd in ${(kv)ALINE_PROMPT_WORKER_CMDS}; do
        callback="${ALINE_PROMPT_WORKER_CALLBACKS[$variable]}"
        worker="${variable}_worker"
        aui_stop_worker "$worker" &>/dev/null
        aui_start_worker "$worker"
        aui_run_worker "$WORKER" "$cmd" "(){ local NEW; shift; $callback "\$@"; if [[ \$NEW != \$$variable ]]; then $variable=\$NEW; zle reset-prompt; fi; }"
    done
}

function aline_prompt_line_reset {
    PS1="$ALINE_FINISHED_PROMPT"
    RPS1="$ALINE_FINISHED_RPROMPT"
    zle reset-prompt
    PS1="$ALINE_PROMPT"
    RPS1="$ALINE_RPROMPT"
}

# vi cursors

typeset -g ALINE_VI_SUPPORTED_TERMS=('screen-256color'
                                     'xterm-256color'
                                     'tmux-256color'
                                     'xterm-kitty')

typeset -gA ALINE_VI_CURSORS=('normal' '\033[2 q' 
                              'insert' '\033[6 q' 
                              'vline' '\033[4 q')

function aline_vi_change_cursor {
    if [[ "$KEYMAP" == "main" ]]; then
        aline_vi_set_insert_cursor
    elif [[ "$KEYMAP" == "vicmd" ]]; then
        aline_vi_set_normal_cursor
    else 
        return
    fi
}

function aline_vi_set_normal_cursor {
    [[ "$ALINE_VI_SUPPORTED_TERMS" =~ "$TERM" ]] || return 1
    printf "${ALINE_VI_CURSORS[normal]}"
}

function aline_vi_set_insert_cursor {
    [[ "$ALINE_VI_SUPPORTED_TERMS" =~ "$TERM" ]] || return 1
    printf "${ALINE_VI_CURSORS[insert]}"
}


# widgets
# widget names should always be kebab-case

function aline-prompt-line-init { aline_prompt_line_init; }
function aline-prompt-line-finish { aline_prompt_line_reset; }

function aline-vi-change-cursor { aline_vi_change_cursor; }
function aline-vi-set-normal-cursor { aline_vi_set_normal_cursor; }
function aline-vi-set-insert-cursor { aline_vi_set_insert_cursor; }

function aline-both-line-init {
    aline_vi_set_insert_cursor
    aline_prompt_line_init
}

function aline-both-line-finish {
    aline_prompt_line_reset
    aline_vi_set_normal_cursor
}

# initialization

typeset -g ALINE_PROMPT_INITIALIZED
typeset -g ALINE_VI_INITIALIZED

function aline_prompt_initialize {
    PS1="$ALINE_PROMPT"
    RPS1="$ALINE_RPROMPT"
    
    zle -N zle-line-init aline-prompt-line-init
    zle -N zle-line-finish aline-prompt-line-finish

    function TRAPINT {
        aline_prompt_line_reset
        return 128
    }

    ALINE_PROMPT_INITIALIZED="1"
}

function aline_vi_initialize {
    zle -N zle-keymap-select aline-vi-change-cursor
    zle -N zle-line-init aline-vi-set-insert-cursor
    zle -N zle-line-finish aline-vi-set-normal-cursor

    ALINE_VI_INITIALIZED="1"
}

function aline_both_initialize {
    aline_vi_initialize
    aline_prompt_initialize

    zle -N zle-line-init aline-both-line-init
    zle -N zle-line-finish aline-both-line-finish
}
