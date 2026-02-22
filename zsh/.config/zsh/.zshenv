#
# Defines environment variables.
# Sourced for ALL shells (login, interactive, scripts, subshells).
# Keep this fast -- env vars only, no aliases or plugins.
#

export TMPDIR=/tmp

export XDG_CACHE_HOME=~/.cache
export XDG_CONFIG_HOME=~/.config
export XDG_DATA_HOME=~/.local/share
export XDG_RUNTIME_DIR=~/.run
export XDG_CONFIG_DIRS=/etc/xdg
export XDG_DATA_DIRS=/usr/local/share/:/usr/share/

export ZDOTDIR=$XDG_CONFIG_HOME/zsh

# XDG overrides
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
export GNUPGHOME=$XDG_CONFIG_HOME/gnupg
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc
export DOCKER_CONFIG=$XDG_CONFIG_HOME/docker
export GOPATH=$XDG_DATA_HOME/go

# less
export LESSHISTFILE=$XDG_CACHE_HOME/less/history
export LESSKEY=$XDG_CONFIG_HOME/less/lesskey

# psql
export PSQLRC="$XDG_CONFIG_HOME/pg/psqlrc"
export PSQL_HISTORY="$XDG_CACHE_HOME/pg/psql_history"
export PGPASSFILE="$XDG_CONFIG_HOME/pg/pgpass"
export PGSERVICEFILE="$XDG_CONFIG_HOME/pg/pg_service.conf"

# Python
export IPYTHONDIR=$XDG_CONFIG_HOME/ipython
export JUPYTER_CONFIG_DIR=$XDG_CONFIG_HOME/ipython
export PIPSI_HOME=$XDG_DATA_HOME/virtualenvs
export PIPENV_IGNORE_VIRTUALENVS=1
export PYENV_ROOT=$XDG_DATA_HOME/pyenv
export PYLINTHOME=$XDG_CACHE_HOME/pylint

# tmux
export TMUX_TMPDIR=$XDG_RUNTIME_DIR

# vim
export VIMCONFIG=$XDG_CONFIG_HOME/nvim
export VIMDATA=$XDG_DATA_HOME/nvim

# X11
export XAUTHORITY=$XDG_RUNTIME_DIR/Xauthority
export XINITRC=$XDG_CONFIG_HOME/X11/xinitrc
export XSERVERRC=$XDG_CONFIG_HOME/X11/xserverrc

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi
