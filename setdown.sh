#
# Dialog
#

setdown_dialog='dialog --scrollbar --no-lines --no-shadow --output-fd 1'

# Displays a message and exits, leaving it on screen
# setdown_putstr "message string"
setdown_putstr() { $setdown_dialog --infobox "$1" 12 50; }

# Displays a message and waits for user to press OK
# setdown_putstr_ok "message string"
setdown_putstr_ok() { $setdown_dialog --msgbox "$1" 12 50; }

# Displays stdout + stderr from a command and exits, leaving output on screen
# setdown_putcmd find / -size 15c
setdown_putcmd() {
  "$@" 2>&1 | $setdown_dialog --progressbox 24 80
  return ${PIPESTATUS[0]}
}

# Prompts for string input using the given heading
# name=`setdown_getstr "Who is the user?" "root"`
# [ `setdown_getstr "Who is the user?"` == "lain" ] && echo "it's her"
setdown_getstr() { $setdown_dialog --inputbox "$1" 12 50 "$2"; }

# Prompts for password input
# secret="$(setdown_getpw 'Enter your password:')"
setdown_getpw() { $setdown_dialog --passwordbox "$1" 12 50; }

# Primes the sudo cache if necessary to avoid breaking the gui
# setdown_sudo 'Enter your password:' && sudo whoami || echo "No auth"
setdown_sudo() {
  # Do nothing if sudo cache is already primed
  sudo -n true 2>/dev/null && return 0

  local password
  password="$(setdown_getpw "$1")" || return 1
  while ! setdown_putcmd sudo -Sp '' <<< "$password" true; do
    password="$(setdown_getpw 'Incorrect password, try again:')" || return 1
  done
  unset password
}

# Prompts a yes/no question
# setdown_getconsent "Continue?" && echo "They said yes"
# if setdown_getconsent "Continue?"; then echo "They said yes"; fi
setdown_getconsent() {
  $setdown_dialog --yesno "$1" 12 50
  [ $? -eq 0 ] && true || false
}

# Displays a checklist with choices from an associative array
# my_choices=('opt 1' on 'opt 2' off)
# declare -a user_choices=$(setdown_getopts 'Title' my_choices)
# all_choices+=("${user_choices[@]}")
# for choice in "${user_choices[@]}"; do echo "$choice"; done
setdown_getopts() {
  local -n options=$2
  echo '('
  [[ "${options[@]}" ]] && $setdown_dialog --no-items --checklist \
    "$1" 24 70 16 "${options[@]}"
  echo ')'
}

#
# Filesystem
#

# Creates a symlink $2 pointing to $1
# setdown_link ~/dotfiles/my_bashrc ~/.bashrc
setdown_link() {
  # Create link if doesn't exist, already points to target, or user consents
  if ! ln -s "$1" "$2" >/dev/null 2>&1; then
    [ -z "$(readlink "$2"* | grep "$1")" ] &&
      setdown_getconsent "Couldn't link $1 to $2, try forcing?" &&
        ln -sf "$1" "$2"
  fi
}

# Copies $1 to $2
# setdown_copy my_bashrc ~/.bashrc
setdown_copy() {
  # Create if destination does not exist or user consents to overwrite
  if ! cp -r "$1" "$2" >/dev/null 2>&1; then
    setdown_getconsent "Couldn't copy $1 to $2, try forcing?" &&
      cp -rf "$1" "$2"
  fi
}

# Creates a symlink $2 pointing to $1
# setdown_sudo link ~/dotfiles/my_script /usr/local/sbin/
setdown_sudo_link() {
  # Create link if doesn't exist, already points to target, or user consents
  if ! sudo ln -s "$1" "$2" >/dev/null 2>&1; then
    [ -z "$(readlink "$2"* | grep "$1")" ] &&
      setdown_getconsent "Couldn't link $1 to $2, try forcing?" &&
        sudo ln -sf "$1" "$2"
  fi
}

# Copies $1 to $2 with sudo permissions
# setdown_sudo_copy my_script /usr/local/sbin/
setdown_sudo_copy() {
  # Create if destination does not exist or user consents to overwrite
  if ! sudo cp -r "$1" "$2" >/dev/null 2>&1; then
    setdown_getconsent "Couldn't copy $1 to $2, try forcing?" &&
      sudo cp -rf "$1" "$2"
  fi
}

#
# Utility
#

# Determines if the command is available
# if setdown_hascmd ruby; then ruby -v; fi
# setdown_hascmd ruby && has_ruby=true || has_ruby=false
setdown_hascmd() {
  command -v $1 >/dev/null
}

# Determines if an entry is in an array
# fruits=(apple banana cherry)
# if setdown_hasstr fruits 'celery'; then echo 'celery is a fruit'; fi
setdown_hasstr() {
  local -n list=$1

  for item in "${list[@]}"; do
    if [[ "$2" == "$item" ]]; then
      return 0
    fi
  done

  return 1
}
