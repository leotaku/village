# the default prompt used by the elvish shell, 
# but with fish-style directory collapsing

ELF_SCRIPTDIR="$(dirname $(realpath $0))/library"
source $ELF_SCRIPTDIR/elf.zsh

elf_add la '${${PWD/$HOME/~}//(#b)(\/#.#?)[^\/]#\//$match[1]/}> '
elf_add ra '%{$fg[black]$bg[white]%}'
elf_add ra '%n@%m'
elf_add ra '%{$fg[default]$bg[default]%}'

ELF_FINISHED_PROMPT="$ELF_PROMPT"
ELF_FINISHED_RPROMPT=""
