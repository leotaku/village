# pura - a prompt that mimics the pure.zsh prompt

VILLAGE_SCRIPTDIR="$(dirname $(realpath $0))/.."
source $VILLAGE_SCRIPTDIR/library/elf.zsh

typeset -g ELF_PROMPT_NAME="pura"

function pura_git_up_down_handle {
    [[ -z "$1" ]] && return 1

    local up
    local down
    read up down <<< $1
    read down <<< "$(echo $down | tr -d '\r')"

    NEW="%F{cyan}"
    if [[ "$down" != 0 ]]; then
        NEW="$NEW⇣"
    fi
    if [[ "$up" != 0 ]]; then
        NEW="$NEW⇡"
    fi
}

typeset -g PURA_PROMPT_CHAR="❯"

elf_add la '%F{blue}%~'
elf_add la ' '
elf_add_async la 1 'git rev-parse --short HEAD 2>/dev/null | tr -d "[:space:]"' '(){ NEW="%F{242}$1"; }'
elf_add_async la 2 'git status --porcelain 2>/dev/null | wc -l | tr -d "[:space:]"' "(){ if [[ "\$1" == "0" ]]; then NEW=''; else NEW='%F{242}*'; fi; }"
elf_add la ' '
elf_add_async la 3 'GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh} -o BatchMode=yes" git fetch &>/dev/null && git rev-list --left-right --count HEAD...@'{u}' 2>/dev/null' pura_git_up_down_handle
elf_add la "$prompt_newline"
elf_add la '%(?.%F{magenta}.%F{red})$PURA_PROMPT_CHAR '

ELF_FINISHED_PROMPT="$ELF_PROMPT"
ELF_RPROMPT=""
ELF_FINISHED_RPROMPT=""

function pura_echo_n {
    echo ""
}

function elf_additional_setup {
    add-zsh-hook precmd pura_echo_n
}

function elf_additional_teardown {
    add-zsh-hook -d precmd pura_echo_n
}

elf_register
