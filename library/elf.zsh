# elf.zsh -- easy (prompt)line formatting for zsh

# originally motivated by the slowness and lack
# of configuration of existing zsh prompts
# and inspired by the elvish (https://elv.sh/)
# shell, elf.zsh offers a straightforward configuration
# framework for your own, fully asycronous modeline creations

# load lib

local ELF_SCRIPTDIR="${0:A:h}"
source "$ELF_SCRIPTDIR/aui.zsh"
autoload -Uz add-zsh-hook add-zle-hook-widget

# setup/teardown

typeset -g ELF_PROMPT=""
typeset -g ELF_RPROMPT=""
typeset -g _ELF_ZSH_HOOKS=()
typeset -g _ELF_ZLE_HOOKS=()
typeset -g _ELF_TRAPINT_HOOKS=()

# prompt/line

function elf_add {
    local which_prompt="$1"; shift
    local section
    
    for section in ${@}; do
        _elf_add "$which_prompt" "$section"
    done
}

function _elf_add {
    local which_prompt="$1"
    local section="$2"

    local reset="%{%f%k%b%u%s%}"
    local newline=$'\n%{\r%}'
    local invert=$'%{\e[7m%}'

    local section="$section%R"
    local section="${section//\%R/$reset}"
    local section="${section//\%r/$newline}"
    local section="${section//\%a/$invert}"

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

function _elf_generate_async_fn {
    local identifier="$1"
    local cmd="$2"
    local callback="$3"
    local function_name="__elf_async_${identifier}"
    local callback_name="__elf_callback_${identifier}"

    eval "function $callback_name {
        $callback
    }"

    eval "function $function_name {
        aui_stop_worker \"$identifier\" &>/dev/null
        aui_start_worker \"$identifier\" &&\
        aui_run_worker \"$identifier\" \"$cmd\" \"$callback_name\"
    }"

    FUNCTION="$function_name"
}

function elf_async {
    local hook="$1"
    local identifier="$2"
    local cmd="$3"
    local callback="$4"

    local FUNCTION
    _elf_generate_async_fn "$identifier" "$cmd" "$callback"
    elf_sync "$hook" "$identifier" "$FUNCTION"
}

function elf_sync {
    local hook="$1"
    local identifier="$2"
    local cmd="$3"
    local fn_name="__elf_hook_$identifier"
    local widget_name="__elf-hook-widget-$identifier"
    
    eval "function $fn_name {
        $cmd
    }"

    case "$hook" in
        # TRAPINT
        line-abort)
            _ELF_TRAPINT_HOOKS+=("$fn_name");;
        # zle hook
        isearch-exit|isearch-update|line-pre-redraw|line-init|line-finish|history-line-set|keymap-select)
            zle -N "$widget_name" "$fn_name"
            _ELF_ZLE_HOOKS+=("$hook" "$widget_name");;
        # zsh hook
        chpwd|precmd|preexec|periodic|zshaddhistory|zshexit|zsh_directory_name)
            _ELF_ZSH_HOOKS+=("$hook" "$fn_name");;
        *)
            echo "elf: '$hook' not a valid zsh or zle hook" 1>&2;;
    esac
}

function elf_set {
    local variable="$1"
    local value="$2"
    local old="${(P)variable}"
    
    if [[ "${old}" != "${value}" ]]; then
        typeset -g "$variable=$value"
        zle && zle reset-prompt
    fi
}
