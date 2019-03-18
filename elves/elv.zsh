# the default prompt used by the elvish shell, 
# but with fish-style directory collapsing

VILLAGE_SCRIPTDIR="$(dirname $(realpath $0))/.."
source $VILLAGE_SCRIPTDIR/library/elf.zsh

local invert="$(echo -e '%{\e[7m%}')"
local reset="$(echo -e '%{\e[0m%}')"

elf_add la '${${PWD/$HOME/~}//(#b)(\/#.#?)[^\/]#\//$match[1]/}> '
elf_add ra "$invert%n@%m%f%k"

ELF_FINISHED_PROMPT="$ELF_PROMPT"
ELF_FINISHED_RPROMPT=""
