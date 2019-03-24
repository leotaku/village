# the default prompt used by the elvish shell, 
# but with fish-style directory collapsing

VILLAGE_SCRIPTDIR="${0:A:h}/.."
source $VILLAGE_SCRIPTDIR/library/elf.zsh

elf_add la '${${PWD/$HOME/~}//(#b)(\/#.#?)[^\/]#\//$match[1]/}> '
elf_add ra "%a%n@%m"

ELF_FINISHED_PROMPT="$ELF_PROMPT"
ELF_FINISHED_RPROMPT=""
