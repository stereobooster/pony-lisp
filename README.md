# pony-lisp

Small experiment

## Status

[![CircleCI](https://circleci.com/gh/stereobooster/pony-lisp.svg?style=svg)](https://circleci.com/gh/stereobooster/pony-lisp)

Do not use.

## Developemnt

- https://tutorial.ponylang.io/
- https://www.ponylang.io/media/cheatsheet/pony-cheat-sheet.pdf
- https://tutorial.ponylang.io/reference-capabilities/reference-capabilities.html
- https://github.com/kanaka/mal/blob/master/process/guide.md#step0

## Shortcuts

- `Cmd` + `Shift` + `B` - build
- `Cmd` + `T` - go to defintion (you need to build tags first - `make tag`)
- `Shift` + `^` + `\`` - open terminal
- `^` + `\`` - toggle terminal
- `Cmd` + `J` - toggle terminal panel
- You can use `Cmd` + `Click` in terminal to open files
- `Cmd` + `B` - toggle file explorer
- `Ctrl` + `Shift` + `P` - open command palette
- `Ctrl` + `P` - search files
- `Ctrl` + `K` `Enter` - keep file open
- `Shift` + `Option` + `F` - format file
s
- https://code.visualstudio.com/docs/getstarted/tips-and-tricks
- https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf
- https://code.visualstudio.com/docs/getstarted/keybindings
- https://tkainrad.dev/posts/learning-all-vscode-shortcuts-evolved-my-developing-habits/

- https://marketplace.visualstudio.com/items?itemName=mads-hartmann.yassnippet
- https://github.com/ponylang/pony-snippets

## Pony first impression

- No recursive types, need to use classes instead
- No way to pass error message with exception (`error`)
- Potential issues with utf-8 strings?
- Hard to read error messages
- `SomeClass` will create instance of a given calss, the same as `SomeClass()` (but second requires `new create`)
