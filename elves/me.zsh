# the prompt configuration the creator of village.zsh currently uses
# WARNING: may be subject to rapid change

VILLAGE_SCRIPTDIR="${0:A:h}/.."
source $VILLAGE_SCRIPTDIR/library/elf.zsh

workdir="$PWD"
elf_sync precmd workdir 'workdir="${${PWD/$HOME/~}//(#b)(\/#.#?)[^\/]#\//$match[1]/}"'
elf_async line-init nix-prompt "me_nix_prompt" 'elf_update promptchar $2'
elf_async line-init git "git rev-parse --short HEAD 2>/dev/null" 'elf_update git_rev $2'
elf_sync line-finish reset "elf_update git_rev '' 1"
elf_sync line-abort reset "elf_update git_rev '' 1"

elf_add la '$workdir' '$promptchar' ' '
elf_add ra '%B%F{red}$git_rev'

function me_nix_prompt {
    if [[ -z "$NIX_CC" ]]; then
        echo "%(?..%B%F{red})>"
    else
        echo "%B%(?.%F{blue}.%F{magenta})>"
    fi
}

ELF_FINISHED_PROMPT="$ELF_PROMPT"
ELF_FINISHED_RPROMPT=""

# typeset -g JOBS
# 
# function set_rprompt {
#     local jobn
# 
#     jobn="${(S%%)${:-%j}}"
# 
#     if [[ "$jobn" != "$OLD_JOBN" ]]; then
#         if [[ "$jobn" == 0 ]]; then
#             JOBS=""
#         else
#             JOBS="%F{yellow}%B$jobn%b"
#         fi
#         zle && zle .reset-prompt
#         typeset -g OLD_JOBN="$jobn"
#     fi
#     
#     aui_start_worker $1
#     aui_run_worker $1 "sleep 0.2" "set_rprompt"
# }

