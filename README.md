# vimspeak

vimspeak is a plugin for connecting vim to
[espeak](http://espeak.sourceforge.net/). It overrides the default behavior of
the s and S keybindings. The former, when combined with a motion, will read the
implicated text aloud - for example, s} will read the next paragraph, sw will
read the next word, and ss will read the current line.

The S key is a prefix which can be combined with other keys to do more specific
actions:

- St: toggle vimspeak off or on (default: on)
- Sc: cancel the current reading
- Sl: read out the current line number
- Ss: adjust the speed of speech (default: 300)
- Sp: toggle punctuation (default: on)
- Sb: read the name of the current buffer

There are also some autocmds set up, which will read the name of the current
buffer whenever it changes, let you know when the file was written, and read out
the working directory when it changes.

## Settings

vimspeak reads a few global variables to adjust its behavior:

`g:vimspeak_args`: arguments passed to espeak (default: -k30)

`g:vimspeak_speed`: arguments passed to espeak (default: -s 300)

`g:vimspeak_punct`: arguments passed to espeak (default: --punct)

`g:vimspeak_enabled`: set to 1 to enable vimspeak, or 0 otherwise (default 1)

# TODO

- Handle a bunch more autocmds
    - SwapExists
    - FileChangedShell{,Post}
    - CmdUndefined rigging
    - Cmdline{Changed,Enter}
    - more?
- key echo (requires vim patch)
