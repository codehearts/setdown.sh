#!/bin/sh

#
# Dialog
#

setdown_dialog='dialog --scrollbar --no-lines --no-shadow --output-fd 1'

# Displays a message and exits, leaving it on screen
# setdown_putstr "message string"
setdown_putstr() {
  $setdown_dialog --infobox "$1" 12 50
}

# Displays a message and waits for user to press OK
# setdown_putstr_ok "message string"
setdown_putstr_ok() {
  $setdown_dialog --msgbox "$1" 12 50
}

# Displays stdout + stderr from a command and exits, leaving output on screen
# setdown_putcmd find / -size 15c
setdown_putcmd() {
  "$@" 2>&1 | $setdown_dialog --progressbox 24 80
  return "${PIPESTATUS[0]}"
}

# Prompts for string input using the given heading
# name=`setdown_getstr "Who is the user?" "root"`
# [ `setdown_getstr "Who is the user?"` == "lain" ] && echo "it's her"
setdown_getstr() {
  $setdown_dialog --inputbox "$1" 12 50 "$2"
}

# Prompts for password input
# secret="$(setdown_getpw 'Enter your password:')"
setdown_getpw() {
  $setdown_dialog --passwordbox "$1" 12 50
}

# Primes the sudo cache if necessary to avoid breaking the gui
# setdown_sudo 'Enter your password:' && sudo whoami || echo "No auth"
setdown_sudo() {
  # Do nothing if sudo cache is already primed
  if sudo -vn 2>/dev/null; then
    return 0
  fi

  local _message="$1"
  while true; do
    local _password

    # If obtaining a password fails, exit with the return status
    _password="$(setdown_getpw "$_message")" || return $?

    # Set an incorrect password message for subsequent iterations
    _message='Incorrect password, try again:'

    # The loop will continue until the correct password is entered
    if printf '%s\n' "$_password" | sudo -Svp '' >/dev/null 2>&1; then
      break;
    fi
  done
}

# Prompts a yes/no question
# setdown_getconsent "Continue?" && echo "They said yes"
# if setdown_getconsent "Continue?"; then echo "They said yes"; fi
setdown_getconsent() {
  $setdown_dialog --yesno "$1" 12 50
}

# Displays a checklist with choices from an associative array
# my_choices=('opt 1' on 'opt 2' off)
# declare -a user_choices=$(setdown_getopts 'Title' my_choices)
# all_choices+=("${user_choices[@]}")
# for choice in "${user_choices[@]}"; do echo "$choice"; done
setdown_getopts() {
  local -n _setdown_options=$2
  echo -n '('
  [ -n "${_setdown_options[*]}" ] && $setdown_dialog --no-items --checklist \
    "$1" 24 70 16 "${_setdown_options[@]}"
  echo -n ')'
}

#
# Filesystem
#

# Creates a symlink $2 pointing to $1
# setdown_link ~/dotfiles/my_bashrc ~/.bashrc
setdown_link() {
  # Create link if doesn't exist, already points to target, or user consents
  if ! ln -s "$1" "$2" >/dev/null 2>&1; then
    if ! readlink "$2"* | grep -wq "$1"; then
      if setdown_getconsent "Couldn't link $1 to $2, try forcing?"; then
        ln -sf "$1" "$2" >/dev/null 2>&1
      else
        return 1
      fi
    fi
  fi
}

# Copies $1 to $2
# setdown_copy my_bashrc ~/.bashrc
setdown_copy() {
  # If the destination already exists or copying failed
  if [ -e "$2" ] || ! cp -r "$1" "$2" >/dev/null 2>&1; then
    # If the destination is not a file, or has identical contents as the source
    if [ ! -f "$1" ] || ! cmp -s "$1" "$2"; then
      # Ask to overwrite the destination
      if setdown_getconsent "Couldn't copy $1 to $2, try forcing?"; then
        if [ -d "$1" ]; then
          rm -rf "$2"
        fi

        cp -rf "$1" "$2" >/dev/null 2>&1
      else
        return 1
      fi
    fi
  fi
}

# Creates a symlink $2 pointing to $1
# setdown_sudo link ~/dotfiles/my_script /usr/local/sbin/
setdown_sudo_link() {
  # Create link if doesn't exist, already points to target, or user consents
  if ! sudo ln -s "$1" "$2" >/dev/null 2>&1; then
    if ! readlink "$2"* | grep -wq "$1"; then
      if setdown_getconsent "Couldn't link $1 to $2, try forcing?"; then
        sudo ln -sf "$1" "$2" >/dev/null 2>&1
      else
        return 1
      fi
    fi
  fi
}

# Copies $1 to $2 with sudo permissions
# setdown_sudo_copy my_script /usr/local/sbin/
setdown_sudo_copy() {
  # If the destination already exists or copying failed
  if [ -e "$2" ] || ! sudo cp -r "$1" "$2" >/dev/null 2>&1; then
    # If the destination is not a file, or has identical contents as the source
    if [ ! -f "$1" ] || ! sudo cmp -s "$1" "$2"; then
      # Ask to overwrite the destination
      if setdown_getconsent "Couldn't copy $1 to $2, try forcing?"; then
        if [ -d "$1" ]; then
          rm -rf "$2"
        fi

        sudo cp -rf "$1" "$2" >/dev/null 2>&1
      else
        return 1
      fi
    fi
  fi
}

#
# Utility
#

# Determines if the command is available
# if setdown_hascmd ruby; then ruby -v; fi
# setdown_hascmd ruby && has_ruby=true || has_ruby=false
setdown_hascmd() {
  command -v "$1" >/dev/null
}

# Determines if an entry is in an array
# fruits=(apple banana cherry)
# if setdown_hasstr fruits 'celery'; then echo 'celery is a fruit'; fi
setdown_hasstr() {
  local -n list=$1

  for item in "${list[@]}"; do
    if [ "$2" = "$item" ]; then
      return 0
    fi
  done

  return 1
}
