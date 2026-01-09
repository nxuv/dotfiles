# Persistent $XDG_DATA_DIR program sources

## List

- `_func_show_config_dir.d`
    > Initially it was confed, a separate "package" I had used.
    >
    > Reads from file and prints directory
    > that's matching requested one or opens editor on it,
    > used inside zsh function with `-p` flag to cd into config dir.
- `_func_show_repo_list.c`
    > Lists repositories in `/g` (TODO: change to env variable)
    > with some misc filtering features based on files (`.metarepo` and `.nonrepo`).
    >
    > Is used inside zsh function for selecting repo with fzf and cd'ing into it.
- `aur.d`
    > AUR helper to clone, build, install or create packages.
- `fetch.d`
    > Custom fetch that's ran when I open zsh prompt.
    > Contains fancy "logo", some sys info I might need
    > and list of drives that are mounted to root directories.
    >
    > Additionally `t` is used after calling fetch to print list of
    > tasks that currently need my attention.
- `floppy-test.d`
    > A "script" to test if floppy is in working state, was used to check
    > through oh so many of them to weed out failed ones.
- `floppy-watch.d`
    > Mounts floppies and runs whatever autostart and autoclose scripts
    > they have on them. Useful to fool around but impractical.
- `fnt.d`
    > Was used to fetch, preview and install fonts, but right now
    > it's broken because it's unable to reach one of endpoints.
- `git-poll.d`
    > Shows git status - ahead, behind, change count and last commit,
    > for all of subdirectories of working directory
- `rdmd.d`
    > Allows to run single-file D scripts with a shebang.
- `setcursor.d`
    > Automatically fixes cursor for me by setting GTK, Qt and Xorg
    > configuration files to use correct cursor theme.
- `udisk.d`
    > Don't remember what it was supposed to do, I think it
    > was meant to allow me to mount/unmount drives without sudo?
- `ytmp3.d`
    > Downloads youtube videos and converts them to mp3.

## Building

Requires [just](https://github.com/casey/just) or can be done manually.

To build anything, simply run `just build [FILENAME]`,

```bash
just build _func_show_repo_list.c
just build _func_show_config_dir.d
```

and binaries will be placed into `$XDG_DATA_DIR/bin` or `$HOME/.local/share/bin`.

