# ix nvim dotfiles

## Requirements
### LSP
- C/C++ 
    - `clangd`
- Lua 
    - `luals`
- Haskell
    - `ghcup`
        - run `ghcup tui` from a terminal and grab the recommended `hls` distribution
- `opam`
    - when you install oCaml, be sure to also install opam (oCaml's package manager)
    - oCaml
        - run `opam install ocaml-lsp-server`
    - rocq
        - run `opam install rocq` to get base rocq
        - run `opam install vscoq-language-server` for vscoq to work

## Special Keybinds
- <F6> - activate file browser
    - <-> to move up a level
    - otherwise, Oil operates exactly the same as vim (every line is a file)
- <F7> - toggle diagnostics

