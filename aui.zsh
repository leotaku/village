#!/usr/bin/env zsh

# aui -- a simple async ui framework for zsh

typeset -g AUI_VERSION="DEBUG"
typeset -g AUI_DEBUG_FD=${EAS_DEBUG_INFO:-/dev/null}

# setup

zmodload zsh/zpty
typeset -gA AUI_FD_WORKERS
typeset -gA AUI_WORKER_FDS
typeset -gA AUI_WORKER_CALLBACKS

# functions

# Initialize a worker with the name of "$1", which can then
# be consumed by aui_run_worker or aui_stop_worker.
#
# trying to start an already existing worker will fail with
# exit code 1
#
# !!! WARNING: this command must run in the top level shell !!!
# !!! this means you may not use "$()" or pipe the function !!!

function aui_start_worker {
    local worker="$1"
    
    zpty -b "$worker" "read -r cmd; eval \$cmd" || return 1

    local fd="$REPLY"
    AUI_WORKER_FDS[$worker]="$fd"
    AUI_FD_WORKERS[$fd]="$worker"

    zle -F "$fd" _aui_callback

    WORKER="$worker"
}

# forcefully consume a worker without waiting for it
# to complete. stopping a worker will also discard
# its callback
#
# trying to stop a non-existent worker will fail with 
# exit code 1

function aui_stop_worker {
    local worker="$1"
    local fd="${AUI_WORKER_FDS[$worker]}"
    
    zpty -d "$worker" || return 1
    zle -F "$fd" || return 1

    unset "AUI_WORKER_FDS[$worker]"
    unset "AUI_FD_WORKERS[$fd]"
    unset "AUI_WORKER_CALLBACKS[$worker]"
}

# run command "$2" (quoted) in worker "$1" with callback "$3"
# both the command and callback are ordinary shell commands
# passed to eval. This means you may use piping etc.
#
# trying to run a non-existent worker will fail with 
# exit code 1
# trying to run an already running worker will fail with
# exit code 2

function aui_run_worker {
    local worker="$1";
    local cmd="$2"
    local callback="$3"
    local fd="${AUI_WORKER_FDS[$worker]}"

    if [[ -z "$fd" ]]; then
        return 1
    elif [[ -n "${AUI_WORKER_CALLBACKS[$worker]}" ]]; then
        return 2
    fi
    
    AUI_WORKER_CALLBACKS[$worker]="$callback"

    zpty -w "$worker" "$cmd"
}

# the internal callback passed to zle -F for all jobs

function _aui_callback {
    local fd="$1"
    local err="$2"
    local worker="${AUI_FD_WORKERS[$fd]}"
    local handle="${AUI_WORKER_CALLBACKS[$worker]}"
    
    if [[ -n "$err" ]]; then
        local output="$(zpty -r $worker)"
        aui_stop_worker "$worker"
        eval "$handle "$worker" $output"
    fi
}
