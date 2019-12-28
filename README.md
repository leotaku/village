# village

Village is a collection of responsive zsh prompts using their own shared asynchronous configuration framework. (`elf.zsh`)
It also includes some other zsh-prompt related utilities under `allies`.

Using `elf.zsh`, village prompts often noticeably outperform both well known prompt configurations and frameworks as well as handcrafted prompts of similar complexity.

`elf.zsh` is implemented in about 200 SLOC with no external dependencies.

## Usage

You may load any village configuration in the following manner:

```zsh
source $DIR/library/elf_load.zsh
source $DIR/elves/YOUR_FAVORITE_ELF.zsh
source $DIR/allies/SOME_FEATURE.zsh

SOME_FEATURE_setup
elf_setup
```

All things village may also be unloaded cleanly:

```zsh
elf_teardown
SOME_FEATURE_teardown
```

## Other

### Why another zsh configuration framework?

Village isn't a zsh configuration framework. It simply provides a tool to create your own zsh prompts, some predefined example prompts and some additional helpers that the author uses.

### Roll your own elf

`elf.zsh` also allows you to easily create your own prompt configuration.
Simply edit one of the preexisting configurations under `elves`.
