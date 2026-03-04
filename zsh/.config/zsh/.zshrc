#
# Interactive shell config.
# Sourced for interactive shells only.
#

# Source Prezto
if [[ ! -s "${ZDOTDIR}/.zprezto/init.zsh" ]]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR}/.zprezto"
fi
source "${ZDOTDIR}/.zprezto/init.zsh"

unsetopt nomatch

alias ls=eza
alias m='make'
alias mp='MISE_ENV=prod mise exec --'
alias rg='rg --smart-case --hidden'
if type nvim > /dev/null 2>&1; then
  alias vim=nvim
fi

# Custom git aliases
alias gbb='git branch --color=always | grep brendan --color=never'
alias gcb='git clean-branches'
alias groh='echo "HEAD was at $(git rev-parse HEAD)"; git reset "origin/$(git-branch-current 2> /dev/null)" --hard'
alias grm='git rebase main'
alias gwt='git worktree'
alias pr='gh pr view --web'

export GPG_TTY=$(tty)

# Vi editor mode
export KEYTIMEOUT=1
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
for keymap in viins vicmd; do
  bindkey -M "$keymap" '^P' up-line-or-beginning-search
  bindkey -M "$keymap" '^N' down-line-or-beginning-search
  bindkey -M "$keymap" '^F' end-of-line
  bindkey -M "$keymap" '^[f' forward-word
done

# mise
eval "$(mise activate zsh)"
source <(mise completion zsh)

# Starship prompt
eval "$(starship init zsh)"

# Atuin history search
eval "$(atuin init zsh)"

# Zoxide directory jumper
eval "$(zoxide init zsh)"

fpath+=~/.zfunc
zstyle ':completion:*' menu select

# macOS
if [[ "$OSTYPE" == darwin* ]]; then
  source ~/.orbstack/shell/init.zsh 2>/dev/null || :
fi
