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
typeset -g ELF_ZSH_HOOKS=()
typeset -g ELF_ZLE_HOOKS=()

# prompt/line

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

function _elf_generate_async_fn {
    local identifier="$1"
    local cmd="$2"
    local callback="$3"
    local function_name="_elf_generated_async_${identifier}"
    local callback_name="_elf_generated_callback_${identifier}"

    eval "function $callback_name {
        $callback
    }"

    eval "function $function_name {
        aui_stop_worker "$identifier" &>/dev/null
        aui_start_worker "$identifier" &&\
        aui_run_worker \"$identifier\" \"$cmd\" \"$callback_name\"
    }"

    FUNCTION="$function_name"
}

function elf_async {
    local hook="$1"
    local identifier="$2"
    local cmd="$3"
    local callback="$4"

    _elf_generate_async_fn "$identifier" "$cmd" "$callback"
    elf_register "$hook" "$identifier" "$FUNCTION"
}

function elf_sync {
    local hook="$1"
    local identifier="$2"
    local cmd="$3"
    
    elf_register "$hook" "$identifier" "$cmd"
}

function elf_register {
    local hook="$1"
    local identifier="$2"
    local cmd="$3"
    local fn_name="_elf_hook_$identifier"
    local widget_name="_elf-hook-widget-$identifier"
    
    eval "function $fn_name {
        $cmd
    }"

    case "$hook" in
        # TRAPINT
        line-abort)
            ELF_TRAPINT_HOOKS+=("$fn_name");;
        # zle hook
        isearch-exit|isearch-update|line-pre-redraw|line-init|line-finish|history-line-set|keymap-select)
            zle -N "$widget_name" "$fn_name"
            ELF_ZLE_HOOKS+=("$hook" "$widget_name");;
        # zsh hook
        chpwd|precmd|preexec|periodic|zshaddhistory|zshexit|zsh_directory_name)
            ELF_ZSH_HOOKS+=("$hook" "$fn_name");;
        *)
            echo "elf_register: not a valid zsh or zle hook" 1>&2;;
    esac
}

function elf_update {
    variable="$1"
    value="$2"
    old="${(P)variable}"
    restorep="$3"

    if [[ "${old}" != "${value}" ]]; then
        # notify-send "${old} != ${value}" &|
        typeset -g "$variable=$value"
        zle reset-prompt
        [[ -n "$restorep" ]] &&\
        typeset -g "$variable=$old"
    fi
}
