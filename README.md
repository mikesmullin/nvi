# Very opinionated Node.JS VI clone

This will become my dream collaborative editor.

**WARNING:** Its in a very ALPHA state right now. Contributions welcome.

![Screenshot](https://raw.github.com/mikesmullin/nvi/development/docs/screenshot.png)

## Vision:

We're taking the best parts of Vim:
  * 256-color text-based user interface
  * works locally via terminal incl. tmux
  * works remotely via ssh
  * modes
  * buffers
  * block edit
  * macros
  * mouse support
  * plugins:
    * syntax highlighting
    * nerdtree
    * ctags
    * taglist

and making them better:
  * collaborative editing
    * multiple writers w/ colored cursors
    * follow/professor mode
  * type inference and code completion (coffeescript will be first)
  * easily configured and modded via coffeescript and javascript
  * unforgiving bias toward modern systems

## Achieved Features:

* 256-color terminal text-based user interface
* tiled window management for buffers
* modes: COMBO, NORMAL, REPLACE, BLOCK, LINE-BLOCK, COMMAND
* connect multiple nvi sessions in host-guests configuration
* local unix and remote tcp socket support for pairing

## Installation
```bash
npm install nvi -g
```

## Usage
```bash
nvi # new file
nvi <file> # existing file
```

## Getting Started

Nvi modes are not Vim modes.
Nvi NORMAL is Vim INSERT.
Nvi COMBO is Vim NORMAL.
These mode names are less confusing to new users.
When you first run Nvi, you begin in Nvi NORMAL mode.
This is intended to provide new users with a sense of familiarity as it is conventional to nano or Notepad on first impression.
This is aided by default hotkey behaviors like:
 * Esc: enter Nvi COMBO mode
 * Ctrl+S: Save, enter Nvi COMBO mode
 * Ctrl+Q: Prompt to save if any changes, then quit
 * Ctrl+X: Cut selection to clipboard
 * Ctrl+C: Copy selection to clipboard
 * Ctrl+V: Paste clipboard

## Beginning a Collaborative Editing Session

* Open `nvi` twice
* In the first Nvi, press `<Esc>` to enter COMBO mode, type: `:listen`, and hit `<Enter>`
* In the second Nvi, press `<Esc>` to enter COMBO mode, type: `:connect`, and hit `<Enter>`

## TODO most immediately:

* rendering multiple host and guest cursor movements
* arrow keys cursor movement constrained by view text depending on mode

* make it draw a dividing line
* make the dividing lines draggable to hresize and vresize

* make view statusbar toggle focus with click
* also cursor focus toggle with click
* and render both cursors in same view
* hmm maybe also make it so view status bar only appears if there is more than one?

* lclick to place cursor
* lclick+drag to highlight
* double-lclick to highlight word
* triple-lclick to highlight line


## Similar projects:

* [Floobits Vim plugin](https://floobits.com/)
