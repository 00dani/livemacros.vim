# livemacros.vim

livemacros.vim allows you to write macros in a regular Vim buffer -- your macro
will be run automatically as you go, providing a preview of its operation.

# Usage

Get started by running the `:Livemacro` command.

    :Livemacro

A --livemacro-- window will open at the bottom of your tab page. Start typing
your macro into this window; when you leave Insert mode or apply a Normal mode
command to the --livemacro-- buffer, it'll automatically be applied to the
buffer you started with, giving you a realtime preview of your macro's result.

It's recommended that you set up a mapping to record livemacros. livemacros.vim
won't do this by itself, but you can make it do so with a call like this in
your `~/.vimrc`:

    :call livemacros#setup#map('Q')

Then you can record a livemacro into register `x` using `Qx`. (Q is a good
choice since it's extremely similar to q, and honestly who uses Ex-mode anyway?
Still, this is optional just-in-case you do in fact use Ex mode.)

# Macro Registers

By default, livemacros.vim will use the unnamed register `""` to store your
in-progress macro. This is probably not what you want in a lot of cases, since
the unnamed register changes *a lot*. It's recommended to use the named
registers `"a` to `"z` for macros instead.

You can change the register used by a livemacro by passing an argument to
`:Livemacro`:

    :Livemacro l
    " store in register l

Or by using the `"` prefix:

    "q:Livemacro
    " store in register q

Or, if you used `livemacros#setup#map()`:

    Qp
    " store in register p

# Installation

livemacros.vim can be installed through [Pathogen](https://github.com/tpope/vim-pathogen):

    cd ~/.vim/bundle
    git clone git://github.com/00Davo/livemacros.vim

Or [Vundle](https://github.com/gmarik/vundle):

    Bundle '00Davo/livemacros.vim'

# TODO

* Decide on sane behaviour for the uppercase registers "A to "Z. Right now they
  behave *super weirdly* if used.
