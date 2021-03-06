#!/bin/bash

dotzsh_dir="${ZDOTDIR:-$HOME}/.zprezto"
dotzsh_git="git://github.com/pricco/dotzsh.git"
dotzsh_branch="master"

info () {
  if [ "${1}" -eq '0' ]; then
    printf '\e[32m[✔]\e[0m %b\n' "$2" >&2
  else
    printf '\e[31m[✘]\e[0m %b\n' "$2" >&2
    if [ -z "${3}" ] || [ "${3}" -eq "true" ] ; then
      exit 1
    fi
  fi
}

user () {
  printf '    %b' "${1}"
}

program_exists () {
  local ret='0'
  type $1 >/dev/null 2>&1 || { local ret='1'; }
  # throw error on non-zero return value
  if [ ! "${ret}" -eq '0' ]; then
    info 1 "Sorry, we cannot continue without ${1}, please install it first."
  fi
}

clone () {
  if [ ! -e "${1}" ]; then
    git clone -q --recursive "${2}" "${1}" &&
    cd "${1}" &&
    git submodule -q init &&
    git submodule -q update --init --recursive
    info $? "Cloned ${1}"
  else
    cd "${1}" &&
    git pull -q origin "${3}" &&
    git submodule -q update --init --recursive
    info $? "Updated ${1}"
  fi
}

link_file () {
  local src=$1 dst=$2

  local overwrite= backup= skip=
  local action=

  if [ -f "${dst}" -o -d "${dst}" -o -L "${dst}" ]
  then

    if [ "${overwrite_all}" == "false" ] && [ "${backup_all}" == "false" ] && [ "${skip_all}" == "false" ]
    then

      local currentSrc="$(readlink $dst)"

      if [ "${currentSrc}" == "$src" ]
      then

        skip=true;

      else

        user "File already exists: ${dst} ($(basename "${src}")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action
        printf "\n"

        case "${action}" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "${overwrite}" == "true" ]
    then
      rm -rf "${dst}"
      info $? "Removed ${dst}"
    fi

    if [ "${backup}" == "true" ]
    then
      mv "${dst}" "${dst}.backup"
      info $? "Moved ${dst} to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      info 0 "Skipped ${src}"
    fi
  fi

  if [ "${skip}" != "true" ]  # "false" or empty
  then
    ln -s "${1}" "${2}"
    info $? "Linked ${1} to ${2}"
  fi
}

zsh_install () {
  program_exists "git"
  clone "${dotzsh_dir}" "${dotzsh_git}" "${dotzsh_branch}"
  local overwrite_all=false backup_all=false skip_all=false
  local files=("zlogin" "zlogout" "zpreztorc" "zprofile" "zshenv" "zshrc")
  for file in "${files[@]}"; do
    link_file "${dotzsh_dir}/runcoms/${file}" "${HOME}/.${file}"
  done
  unset file
}

zsh_install
