# the prompt configuration the creator of village.zsh currently uses
# WARNING: may be subject to rapid change

VILLAGE_SCRIPTDIR="${0:A:h}/.."
source $VILLAGE_SCRIPTDIR/library/elf.zsh

workdir="$PWD"
in_nix="%B%(?.%F{blue}.%F{magenta})"
out_of="%(?..%B%F{red})"
promptchar="${${${+NIX_CC}:/1/${in_nix}}:/0/${out_of}}>"

elf_sync precmd workdir 'workdir="${${PWD/$HOME/~}//(#b)(\/#.#?)[^\/]#\//$match[1]/}"'
elf_async line-init git "git rev-parse --short HEAD 2>/dev/null" 'elf_update git_rev $2'
elf_sync line-finish reset "elf_update git_rev '' 1"
elf_sync line-abort reset "elf_update git_rev '' 1"

elf_add la '$workdir' '$promptchar' ' '
elf_add ra '%B%F{red}$git_rev'

ELF_FINISHED_PROMPT="$ELF_PROMPT"
ELF_FINISHED_RPROMPT=""

