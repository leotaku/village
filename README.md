# village

Village is a collection of responsive zsh prompts using their own shared asynchronous configuration framework. (`elf.zsh`)
It also includes some other zsh-prompt related utilities (`allies`)

Using `elf.zsh`, village prompts often noticeably outperform both well known prompt configurations and frameworks as well as handcrafted prompts of similar complexity.

`elf.zsh` is implemented in about 200 LOC with no external dependencies.

# usage

You may load any elf/configuration in the following manner:

```zsh
source $VILLAGE_SCRIPTDIR/your_favorite_elf.zsh
source $VILLAGE_SCRIPTDIR/allies/some_feature.zsh

some_feature_setup
elf_setup
```

All things provided by village may also be unloaded cleanly:

```zsh
elf_teardown
some_feature_teardown
```

# other

## why another zsh configuration framework? what about my unix philosophy?

village isn't a zsh configuration framework. It simply provides a tool to create your own zsh prompts,
some predefined example prompts and some additional *allies*.

All village tools can be used separately from one another, but are built to play off of each others strengths.

## roll your own elf

`elf.zsh` also allows you to easily create your own prompt configuration.
Visit the `library` subdirectory for instructions and other information regarding elf.

*Elves usually live in villages, right?*
