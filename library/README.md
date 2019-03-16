# village

If you are a beginner zsh user you might want to first take a look at the `village` parent directory of this repo.

It contains predefined elf configurations that you may use directly or as a base for your own creations.

# elf.zsh

`elf.zsh` is a framework for creating your own fully asynchronous zsh prompts, using its own library for zsh-native non-blocking computation. (`aui.zsh`)
Its creation was motivated by the slowness and lack of configurability of existing zsh prompts.

## Usage
Using elf.zsh is very simple.

In essence you only need to perform these actions:
1. load the elf.zsh library
2. add your preferred synchronous and asynchronous sections
3. initialize elf

A simple elf setup might look like this:
```zsh
source $ZSH_PLUGIN_DIR/elf/elf.zsh

elf_add la "%~ > "
aline_add ra '%{$fg_bold[red]%}'
elf_add_async ra GIT_REV "git rev-parse --short HEAD 2>/dev/null | tr -d \"[:space:]\"" "(){ NEW="\$1"; }"
aline_add ra '%{$fg_no_bold[default]%}'

elf_prompt_initialize
```

With this setup your left prompt shows the cwd and the right prompt shows the currently active git branch.
The git branch is fetched and displayed fully asynchronously.

## Command reference

### Initialization

`elf` offers 3 different commands for its initialization. 

* `elf_prompt_initialize`
  Initialize the elf prompt configuration functionality
* `elf_vi_initialize`
  Initialize only the vi cursor changing functionality
* `elf_both_initialize`
  Initialize both the prompt as well as the vi cursor changing functionality
  This kind of combined initialization is needed because zle hooks are exclusive, but vi-cursors and elf depend on some of the same hooks

Before initialization, `elf` only defines functions and variables. Hooks are then placed when elf is initialized.

After initialization, `elf`:
* sets `PS1` and `RPS1`
* takes over the following zle hooks
    * zle-line-init
    * zle-line-finish
    * zle-keymap-select (when vi cursor support is loaded)
* traps the INT signal

### Configuration

`elf` offers 2 commands for prompt configuration.
* `elf_add [WHICH_PROMPT] [SECTION]`
  add text SECTION to the end of prompt WHICH_PROMPT. escaped values are synchronously expanded when the prompt is shown.
  Use this for static values and cheap computations that wont block your prompt. (eg. `"$?"`, `"%~"`)
* `elf_add_async [WHICH_PROMPT] [IDENTIFIER] [CMD] [CALLBACK]`
  register the command CMD with callback CALLBACK. show the value returned by assigning `"$NEW"` in the callback at the end of prompt WHICH_PROMPT.

#### Concepts
* `CMD`
  the command CMD is asynchronously `eval`uated. It can not change the interactive shells environment.
* `CALLBACK`
  the callback that is run after `CMD` has completed, with the stdout+err of CMD as its first and only argument.
  It has full access to the interactive shells environment.
  For convenience CALLBACK may modify the value of it's associated variable by simply assigning `$NEW`
* `WHICH_PROMPT`
  WHICH_PROMPT is the value used for describing the prompt a block should be added to.
  * la - the left prompt while still active
  * ra - the right prompt while still active
  * lf - the left prompt after it has either been aborted or accepted
  * rf - the right prompt after it has either been aborted or accepted
  * no - add the block to no prompt. Useful mainly for debugging and prototyping

### Examples
Add a piece of static text to the left active prompt.
```zsh
elf_add la "> "
```

Set the finished left prompt to mimic the active left prompt.
```zsh
ELF_FINISHED_PROMPT="$ELF_PROMPT"
```

Same but for right prompt.
```zsh
ELF_FINISHED_RPROMPT="$ELF_RPROMPT"
```
Add an asynchronous block to the right active prompt.
```zsh
aline_add_async ra GIT_REV "git rev-parse --short HEAD 2>/dev/null | tr -d \"[:space:]\"" "(){ NEW="\$1"; }"
```

## FAQ

### How does this compare to other asynchronous zsh prompts? (pure, alien, ...)
I do not know how to properly benchmark prompts return times, however I personally perceive `elf` to be significantly faster than any other solution I have tried. 

Elf of course also allows you to create your own prompts without modifying the source.

### Why is the vi-cursors functionality integrated into elf? It doesn't really fit in this package.
I entirely agree. In an ideal world it would be an entirely different package/library. However, zsh zle hooks are exclusive, meaning only one command may be bound to them at any time.

This means any two library wanting to use a "shared" zle hook need to have custom built integration.

__NOTE:__ this could maybe be fixed with the help of [zsh-hooks](https://github.com/willghatch/zsh-hooks)

# aui.zsh
`aui.zsh` - asynchronous ui for zsh

`aui` is the zsh library responsible for managing `elf`s asynchronous computations.
It was specifically designed for `elf`, but may also be used separately.

Documentation can be found in the commented source file.
