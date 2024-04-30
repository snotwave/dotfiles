#!/bin/zsh

# Completion
autoload -U compinit
compinit

# Correction
setopt correctall

# Prompt
autoload -U promptinit
promptinit
export PS1="%{%F{green}%}[%*] %{%F{cyan}%}%n@%M %{%F{magenta}%}%~ > %{%F{white}%}"

# Completion Cache
zstyle ':completion::complete:*' use-cache 1

# ls Colors
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
alias ls="ls --color=auto"

# Aliases
alias floorp="flatpak run one.ablaze.floorp"
alias gentoo-update="emerge --sync && emerge -auDNv @world "

# opam configuration
[[ ! -r /home/ix/.opam/opam-init/init.zsh ]] || source /home/ix/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null
