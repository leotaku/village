# the prompt configuration the creator of village.zsh currently uses
# WARNING: may be subject to rapid change

VILLAGE_SCRIPTDIR="$(dirname $(realpath $0))/.."
source $VILLAGE_SCRIPTDIR/library/elf.zsh

function me_nix_prompt {
    if [[ -n "$NIX_CC" ]]; then
        echo -n "%B%F{magenta}"
    fi
    echo -n "> "
}

elf_add la '${${PWD/$HOME/~}//(#b)(\/#.#?)[^\/]#\//$match[1]/}'
elf_add la '%(?. .%B%F{red}x)'
elf_add_async la 1 "me_nix_prompt" "(){ NEW="\$1"; }"
elf_add_async ra 2 "git rev-parse --short HEAD 2>/dev/null | tr -d \"[:space:]\"" "(){ NEW="%B%F{red}\$1"; }"
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
    set_rprompt "job_worker" "f"
}

ELF_FINISHED_PROMPT="$ELF_PROMPT"
ELF_FINISHED_RPROMPT=""
