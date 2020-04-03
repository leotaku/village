# Village

Village is a collection of responsive ZSH prompts using their own shared asynchronous configuration framework.
It also includes some other prompt related utilities under `allies`.

## Install

The ZSH plugin manager situation is heavily fragmented, so I am completely uninterested in providing a tutorial on how to install village using every single option available.
Just follow the instructions in the [usage](#usage) section and you will be fine.

## <a id="usage"></a>Usage

You may load any village configuration in the following manner.

```zsh
source $DIR/library/elf_load.zsh
source $DIR/elves/SOME_THEME.zsh
source $DIR/allies/SOME_FEATURE.zsh

SOME_FEATURE_setup
elf_setup
```

All components may also be unloaded cleanly.

```zsh
elf_teardown
SOME_FEATURE_teardown
```

## Further reading

### elf.zsh

Using `elf.zsh`, Village prompts often noticeably outperform both well known prompt configurations and frameworks as well as handcrafted prompts of similar complexity.
`elf.zsh` is implemented in about 200 SLOC with no external dependencies, which makes it massively lighter than most competing alternatives.

Development and usage are documented in more detail [here](library).

### allies

Village also provides some additional modules that further improve the interactive ZSH experience.
They are included here because they, in some way, need to hook into prompt mechanisms, making ZSH prompt framework agnosticism unrealistic.

Individual modules are documented [here](allies).

## Contributing

PRs and issues are welcome.

## License

Undecided
