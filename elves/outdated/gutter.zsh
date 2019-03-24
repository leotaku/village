# the prompt configuration the creator of village.zsh currently uses
# WARNING: may be subject to rapid change

VILLAGE_SCRIPTDIR="${0:A:h}/.."
source $VILLAGE_SCRIPTDIR/library/elf.zsh

elf_add la '%(?.%F{green}.%F{red})▏'
elf_add l2 '%F{blue}▏'

#elf_add ra '${${PWD/$HOME/}#\/}//(#b)(\/#.#?)[^\/]#\//$match[1]/}'
elf_add ra '${${PWD/$HOME/}#\/}'
elf_add ra '$JOBS'

typeset -g JOBS

function set_rprompt {
    local jobn

    jobn="${(S%%)${:-%j}}"

    if [[ "$jobn" != "$OLD_JOBN" ]]; then
        if [[ "$jobn" == 0 ]]; then
            JOBS=""
        else
            JOBS="%F{yellow}%B$jobn%b"
        fi
        zle && zle .reset-prompt
        typeset -g OLD_JOBN="$jobn"
    fi
    
    aui_start_worker $1
    aui_run_worker $1 "sleep 0.2" "set_rprompt"
}

function elf_additional_setup {
    set_rprompt "jobs_worker" "."
    function elf_additional_setup {}
}

elf_add_zsh_hook precmd elf_additional_setup

ELF_FINISHED_PROMPT="$ELF_PROMPT"
ELF_FINISHED_RPROMPT=""
