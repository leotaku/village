# pura - a prompt that mimics the pure.zsh prompt

VILLAGE_SCRIPTDIR="${0:A:h}/.."
source $VILLAGE_SCRIPTDIR/library/elf.zsh

function pura_git_fetch_and_count {
    GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh} -o BatchMode=yes"\
    git fetch &>/dev/null &&\
    git rev-list --left-right --count HEAD...@'{u}' 2>/dev/null
}

function pura_git_up_down_handle {
    [[ -z "$1" ]] && return 1
    
    local up
    local down
    read up down <<< "$1"

    if [[ "$down" != 0 ]]; then
        NEW="$NEW⇣"
    fi
    if [[ "$up" != 0 ]]; then
        NEW="$NEW⇡"
    fi
}

elf_register_async 1 "git rev-parse --short --abbrev-ref=loose HEAD 2>/dev/null" 'NEW="$1"'
elf_register_async 2 'git status --porcelain 2>/dev/null | wc -l' 'if [[ "$1" == "0" ]]; then NEW=''; else NEW="*"; fi'
elf_register_async 3 pura_git_fetch_and_count 'pura_git_up_down_handle $@'

elf_add la '%F{blue}%~'
elf_add la ' '
elf_add la '%F{242}%1v%2v'
elf_add la ' '
elf_add la '%F{cyan}%3v'
elf_add la '%r'
elf_add la '%(?.%F{magenta}.%F{red})${${${KEYMAP/vicmd/❮}/(main|viins)/❯}:-❯} '

ELF_FINISHED_PROMPT="$ELF_PROMPT"
ELF_RPROMPT=""
ELF_FINISHED_RPROMPT=""

function pura_echo_n {
    # TODO: first precmd?
    echo ""
}

function pura_reset_git {
    psvar[1]=""
    psvar[2]=""
    psvar[3]=""
}

function pura_vi_char {
    PURA_PROMPT_CHAR="${${KEYMAP/vicmd/❮}/(main|viins)/❯}"
    zle .reset-prompt
}

elf_add_zsh_hook chpwd pura_reset_git
elf_add_zle_hook_widget keymap-select .reset-prompt
elf_add_zsh_hook precmd pura_echo_n
#elf_add_zle_hook line-init pura_vi_char
