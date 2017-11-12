#
# Defines Pablo Ricco's aliases.
#
# Authors:
#   Pablo Ricco <pricco@gmail.com>
#
#
alias p="cd ~/projects"

# Tmux
alias tml="tmux list-sessions"
alias tma="tmux attach-session"
alias tmc="clear && tmux clear-history"
alias tmk="tmux kill-session"
alias tvim="tmux new-session -n vim 'vim' \; \
            split-window -h -p 45 \; \
            select-pane -L \;"

# Virtualenv
function ve () {
    PROJECT=$(basename $(pwd))
    if [ -d "${WORKON_HOME}/${PROJECT}" ]
    then
        source "${WORKON_HOME}/${PROJECT}/bin/activate"
    fi
}
export ve

# IDE
function ide() {
    PWD=$(pwd)
    PROJECT=$(basename $PWD)
    PROJECT=${PROJECT//./}
    tmux has-session -t "${PROJECT}" > /dev/null 2>&1
    if [ $? != 0 ]
    then
        tmux -q \
            new-session -s "${PROJECT}" -n editor -c "${PWD}" -d  vim \; \
            split-window -h -p 40 -t "${PROJECT}:editor"\; \
            new-window -t "${PROJECT}" -n server -c "${PWD}" \; \
            new-window -t "${PROJECT}" -n shell -c "${PWD}" \; \
            select-window -t "${PROJECT}:editor" \; \
            select-pane -t "${PROJECT}:editor.1" \; \
            resize-pane -Z -t "${PROJECT}:editor.1" \;
    fi
    tmux -q attach -t "${PROJECT}" > /dev/null 2>&1
}
export ide

# Determine size of a file or total size of a directory
function fs () {
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh;
  else
    local arg=-sh;
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@";
  else
    du $arg .[^.]* *;
  fi;
}
export fs

# `v` with no arguments opens the current directory in Vim, otherwise opens the
# given location
function v() {
  if [ $# -eq 0 ]; then
    vim .;
  else
    vim "$@";
  fi;
}
export v

# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
  if [ $# -eq 0 ]; then
    open .;
  else
    open "$@";
  fi;
}
export o

alias ccat='pygmentize -O style=monokai -f console256 -g'
