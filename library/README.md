# elf.zsh

`elf.zsh` is a framework for creating your own fully asynchronous zsh prompts, using its own library for zsh-native non-blocking computation. (`aui.zsh`)
Its creation was motivated by the slowness and lack of configurability of existing zsh prompts.

## Usage
Using elf is very simple.

In essence you only need to perform these actions:
1. load the `elf.zsh` library
2. register your preferred synchronous and asynchronous sections
3. design your prompt and rprompt
4. load the `elf_load.zsh` library
5. initialize elf

A fully functional elf setup might look like this:

```zsh
source $ZSH_PLUGIN_DIR/elf/elf.zsh

elf_add la "%~ > "
elf_add ra '%1v'

elf_async git_rev "git rev-parse --short HEAD 2>/dev/null" 'psvar[1]=$1'

source $ZSH_PLUGIN_DIR/elf/elf_load.zsh
elf_setup
```

With this setup your left prompt shows the cwd and the right prompt shows the currently active git branch.
The git branch is fetched and displayed fully asynchronously.

## Command reference

Coming soon. Elf is currently still undergoing significant API changes

## FAQ

### How do I start?

If you are a beginner zsh user you might want to first take a look at the `village` parent directory of this repo.
It contains predefined elf configurations that you may use directly or as a base for your own creations.

### How does this compare to other zsh prompts?

I do not know how to reliably benchmark prompts return times, however I personally perceive elf to be significantly faster than nearly all other solutions I have tried.

Elf also aims to be as small as possible and to not rely on external dependencies.

| prompt        | performance            | sloc (lines -blank -comments)                   | external dependencies               |
| ------------- | ----------------       | ----------------------------------              | ----------------------------------- |
| alien         | noticable delays       | 511 (alien libs) + 1390 (external)              | promptlib, zsh-256color, zsh-async  |
| pure          | no delay               | 372 (pure.zsh) + 292 (async.zsh)                | async.zsh (copied into repo)        |
| geometry      | noticeable delays      |                                                 |                                     |
| spaceship     |                        |                                                 |                                     |
| powerlevel10k |                        |                                                 |                                     |
| elf           | no or very small delay | 98 (elf.zsh) + 68 (elf_load.zsh) + 48 (aui.zsh) | none                                |

#### Why is pure so much faster than any other prompt?

From my investigation, [pure](https://github.com/sindresorhus/pure) is much much faster than any other prompt framework.
I would like to investigate why that is and improve village with this information.

* `zprof` reports that async takes up a considerable amount of time.
* It seems like pure uses what it calls a *preprompt* mechanism.
* Pure might not actually be any faster than elf

#### Is it possible to have a transient prompt with sufficient performance?

`elf` does not natively support transient prompts, because most obvious mechanisms result in noticeable delays and stuttering.

Themes that want to employ transient prompts thus currently have to rely on implementing their own ad-hoc mechanisms.

# aui.zsh

`aui` is a zsh library responsible for managing asynchronous computations.
It was specifically designed for `elf`, but may also be used separately.

Documentation can be found in the commented source file.
