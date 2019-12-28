# the prompt configuration the creator of village.zsh currently uses
# WARNING: may be subject to rapid change

local VILLAGE_SCRIPTDIR="${0:A:h}/.."
source $VILLAGE_SCRIPTDIR/library/elf.zsh

declare -gA me

me[cwd]="~"
me[git_rev]=""
me[color]=""

me[in_nix]="%B%(?.%F{blue}.%F{magenta})"
me[failed]="%(?..%B%F{red})"
me[color_templ]='${${${+NIX_CC}:/1/${me[in_nix]}}:/0/${me[failed]}}'
me[cwd_templ]='${${PWD/$HOME/~}//(#b)(\/#.#?)[^\/]#\//$match[1]/}'

elf_sync  precmd      workdir "me[cwd]=\"$me[cwd_templ]\""
elf_sync  precmd      color   "me[color]=\"$me[color_templ]\""
elf_async line-init   git     "git rev-parse --short HEAD 2>/dev/null" 'elf_set "me[git_rev]" $2'
elf_sync  line-finish reset   _me_transient_prompt
elf_sync  line-abort  reset   _me_transient_prompt

function _me_transient_prompt {
    local old="$PS1"
    local rold="$RPS1"
    RPS1=""

    zle && zle reset-prompt
    PS1="$old"; RPS1="$rold"
}

elf_add la '$me[cwd]' '$me[color]> '
elf_add ra '%B%F{red}$me[git_rev]'
