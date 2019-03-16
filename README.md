# village

Village is a collection of responsive zsh prompt configurations using their own shared asynchronous configuration framework. (`elf.zsh`)

Using `elf.zsh`, village prompts often noticeably outperform both well known prompt configurations and frameworks as well as handcrafted prompts of similar complexity.

`elf.zsh` is implemented in less than 200 LOC with no external dependencies.

# usage

You may load any elf/configuration in the following manner:

```
source $VILLAGE_SCRIPTDIR/your_favorite_elf.zsh

# use elf_prompt_initialize instead of elf_both_initialize if you
# do not want your cursor to change based on the current vi state

elf_both_initialize
#elf_prompt_initialize
```

# other
`elf.zsh` also allows you to easily create your own prompt configuration.
Visit the `library` subdir for instructions.

*Elves usually live in villages, right?*
