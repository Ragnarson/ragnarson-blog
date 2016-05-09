---
title: Synchronize your settings with Dropbox and Mackup
author: wijet
shelly: true
---

Most of the developers are creatures of habit. Once they get comfortable
with an editor, a set of shortcuts or a terminal setup they tend to stick
to it for a long time. In this post I will show how to share and keep
application configs and so called dotfiles in sync across machines.
It's very useful when you have a desktop at the office and a laptop at home.

To accomplish that we are going to use a simple tool called
[mackup](https://github.com/lra/mackup) and [Dropbox](https://www.dropbox.com).
Mackup keeps your application settings in sync using Dropbox as a storage.
It can be installed using homebrew or downloaded as a script,
we will do the latter because we want to modify this script later on. READMORE

Before you start make sure Dropbox is configured on all machines.

## Setting up mackup on the current machine

1. Install mackup script on Dropbox

    ```bash
    mkdir -p ~/Dropbox/Mackup/bin
    curl -o ~/Dropbox/Mackup/bin/mackup https://raw2.github.com/lra/mackup/036575af6cf41ac0ad85f853107c93ab3ada7509/mackup.py
    chmod +x ~/Dropbox/Mackup/bin/mackup
    ```

2. Add mackup to your `$PATH`. Most likely you want to put that in the
`~/.bashrc ` or `~/.zshrc` (then reload your environment with `source ~/.zsh`
or `source ~/.bashrc`)

    ```bash
    export PATH=~/Dropbox/Mackup/bin/mackup:$PATH
    ```

3. Create `~/.mackup.cfg` and specify which applications you want to keep in
sync, or which you don't want to. I don't recommend leaving it blank
which will sync all supported applications because it forces some unsecure
defaults, like storing private SSH keys on Dropbox. Below is an example,
the full list of supported applications can be found on
[project's site](https://github.com/lra/mackup).

    ```
    [Allowed Applications]
    Adium
    TextMate
    Zsh
    Spotify
    Screen
    Ruby
    Pow
    Oh My Zsh
    Git
    Colloquy
    Ack
    Curl
    Mackup
    Chef
    ```

4. Run `mackup backup` to move all your configs to `~/Dropbox/Mackup` and
then symlink them back to the right places on your system.

    ```
    mackup backup
    ```

## Setting mackup on the remaining machines

Now it's time to use configs from Dropbox on other machine(s).
The steps below need to be performed on all remaining computers.

1. Add mackup to your `$PATH` as in step 2 of the "Setting up mackup on the
current machine" part.

2. Run `mackup restore` to link all configs from Dropbox to your system.

    ```
    mackup restore
    ```

## Custom file list

What if you want to keep a custom directory in sync? I for example
keep some of my pet projects on Dropbox, despite the fact that I use Git
for them. This allows me to quickly change machines without having to
git commit & push. Also it keeps development
configs/sqlite databases/binaries/logs in sync across machines which usually
shouldn't be in a git repo.

For now there is no easy way to specify the list of custom files that
we want to sync with mackup. There is a
[a pull request](https://github.com/lra/mackup/pull/71)
adding this functionality, which hopefully will be merged soon.

Nothing is lost! We can edit the script to handle custom files and adjust
existing formulas.

First we will prevent from syncing SSH private keys. It's just as simple
as editing a hash.

Open `~/Dropbox/Mackup/bin/mackup` in your favorite editor and replace

```python
'SSH': ['.ssh'],
```

with

```python
'SSH': ['.ssh/config', '.ssh/known_hosts'],
```

Now you can add SSH to `~/.mackup.cfg` and run `mackup backup` on your current
machine and `mackup restore` on the rest of them.

If you want to add a custom directory just create a new key in the hash and
add it's name to `~/.mackup.cfg` and run mackup backup/restore again.

```
'My Projects': ['projects/my', 'projects/go']
```

Last but not least, as a side effect of using Dropbox your configs will be
backed up and versioned (meaning you can restore old configs).

How do you manage your configs? I would love to hear about your setups in comments.
