# aline -- an asyncronous prompt for zsh shell
# load with 'source aline.zsh'

# load lib

ALINE_SCRIPTDIR="$(dirname $(realpath $0))"
source $ALINE_SCRIPTDIR/aui.zsh

# prompt/line

ALINE_PROMPT='${${PWD/$HOME/~}//(#b)(\/#.#?)[^\/]#\//$match[1]/}$(aline-prompt-char)%{$fg_no_bold[default]%}%{$bg_no_bold[default]%}'
ALINE_RPROMPT='%{$fg_bold[red]%}$ALINE_GIT_REV$ALINE_GIT_DIRTY%{$fg_no_bold[default]%}'

function aline-prompt-char {
    if [[ "$?" != "0" ]]; then
        echo -n "%{${fg_bold[red]}%}x%{${fg_no_bold[default]}%}"
    else
        echo -n " "
    fi
    if [[ -n "$NIX_CC" ]]; then
        echo -n "%{${fg_bold[magenta]}%}"
    fi
    echo -n "> "
}

function aline-run-git {
    aui/stop-worker git-rev-worker &>/dev/null
    aui/start-worker git-rev-worker &&\
    aui/run-worker $WORKER "git rev-parse --short HEAD 2>/dev/null | head -n 1" aline-git-rev-callback
    
    aui/stop-worker git-status-worker &>/dev/null
    aui/start-worker git-status-worker
    aui/run-worker $WORKER "git status --porcelain 2>/dev/null" aline-git-dirty-callback
}

function aline-git-dirty-callback {
    local text="$2"

    if [[ -n "${text//[^?]/}" ]]; then
        new="?"
    elif [[ -n "${text}" ]]; then
        new="*"
    else
        new=""
    fi

    if [[ "$new" != "$ALINE_GIT_DIRTY" ]]; then
        ALINE_GIT_DIRTY="$new"
        zle && zle reset-prompt
    fi
}

function aline-git-rev-callback {
    local new="$(echo -n $2 | tr -d '\r')"
    if [[ "$new" != "$ALINE_GIT_REV" ]]; then
        ALINE_GIT_REV="$new"
        zle && zle reset-prompt
    fi
}

function aline-reset-rprompt {
    RPS1=""
    zle reset-prompt
    RPS1="$ALINE_RPROMPT"
    zle .accept-line
}

# vi cursors

typeset -g ALINE_VI_SUPPORTED_TERMS=('screen-256color'
                                     'xterm-256color'
                                     'tmux-256color')

typeset -gA ALINE_VI_CURSORS=('block' '\033[2 q' 
                              'hline' '\033[6 q' 
                              'vline' '\033[4 q')

function aline-update-vi-cursor {
    [[ "$ALINE_VI_SUPPORTED_TERMS" =~ "$TERM" ]] || return 1

    if [[ "$KEYMAP" == "main" ]]; then
        printf "$ALINE_VI_CURSORS[hline]"
    elif [[ "$KEYMAP" == "vicmd" ]]; then
        printf "$ALINE_VI_CURSORS[block]"
    else 
        return
    fi
}

function aline-reset-vi-cursor {
    [[ "$ALINE_VI_SUPPORTED_TERMS" =~ "$TERM" ]] || return 1
    printf "${ALINE_VI_CURSORS[block]}"
}

# combined

function aline-line-init {
    aline-update-vi-cursor
    aline-run-git
}

# hooks

PS1="$ALINE_PROMPT"
RPS1="$ALINE_RPROMPT"

function chpwd {
    ALINE_GIT_REV=""
    ALINE_GIT_DIRTY=""
}

TRAPINT () {
    RPS1=""; 
    zle reset-prompt; 
    RPS1="$ALINE_RPROMPT"
    return 128
}

zle -N accept-line aline-reset-rprompt
zle -N zle-keymap-select aline-update-vi-cursor
zle -N zle-line-finish aline-reset-vi-cursor
zle -N zle-line-init aline-line-init
#zle -N zle-line-init aline-update-vi-cursor
#zle -N zle-line-init aline-aline-run-git
