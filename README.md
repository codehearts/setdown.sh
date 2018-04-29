# setdown.sh

[![Build Status][build-badge]][build-link] [![Coverage][coverage-badge]][coverage-link] [![MIT License][license-badge]](LICENSE.md)

Utilities for making interactive system setup easier. Supports Bash 4.4+. Some commands depend on `dialog`, but not all! This readme will tell you the dependencies for each function.

I'm personally using setdown.sh for my [dotfiles](https://github.com/codehearts/dotfiles), check out my [katify.sh script](https://github.com/codehearts/dotfiles/blob/master/katify.sh) for ideas on how to use it. I'm able to configure an entire Arch Linux or macOS system by selecting the packages I want and choosing which dotfiles to link in.

## Command Reference

### User Input Commands

- **`setdown_putcmd`**: *bash, dialog*  
Displays a window with standard output and error from a command. 

  ```bash
  setdown_putcmd find / -size 15c
  ```

  - The return status of the given command will be returned.
  - The output window remains on screen once the command exits, allowing for seamless dialog windows.

- **`setdown_getstr`**: *dialog*  
Displays a text entry field with `$1` as the prompt and `$2` as an optional default value.

  ```bash
  username="$(setdown_getstr "Who is the user?" "lain")"
  ```

  - `true` is returned only if the user provides input.
  - `false` is returned if the user aborts text entry.
  - User input is given over standard output.

- **`setdown_getpw`**: *dialog*  
Displays a password entry field with `$1` as the prompt.

  ```bash
  setdown_getpw 'Enter your password:' | sudo -Sp '' install firefox
  ```

  - `true` is returned only if the user provides input.
  - `false` is returned if the user aborts password entry.
  - User input is given over standard output.

- **`setdown_sudo`**: *dialog, sudo*  
Displays a password entry field with `$1` as the prompt, priming the sudo cache.

  ```bash
  if setdown_sudo 'Enter password for installation:'; then
    sudo install firefox
  else
    printf 'Authentication not provided for installation\n'
  fi
  ```

  - `true` is returned only if the user entered the correct password.
  - `false` is returned if the user aborts password entry.
  - The user will have infinite attempts to enter the correct password.
  - If the sudo cache is already primed, no password is prompted.

- **`setdown_getconsent`**: *dialog*  
Prompts a yes/no question with `$1` as the string to display.

  ```bash
  if setdown_getconsent "Install firefox?"; then
    install firefox
  fi
  ```

  - `true` is returned only if the user selected "Yes." All other options return `false`.

- **`setdown_getopts`**: *dialog*  
Displays a checklist with `$1` as the title and choices from an associative array named by `$2`.

  ```bash
  all_packages=('docker', 'gcc')
  editors=('emacs' off 'vim' on)

  declare -a editor_choices=$(setdown_getopts 'Choose editors to install' editors)
  all_packages+=("${editor_choices[@]}")

  for package in "${all_packages[@]}"; do
    install "$package" # (docker, gcc, vim) by default
  done
  ```

  - `$2` is the _name_ of the associative array.
  - The format of the array named by `$2` is `(choice_name status)`.
    - Choice name is an arbitrary string.
    - Status is either `on` to select by default or `off` to deselect by default.
  - This function outputs a string over stdout which evaluates to an array.


### Filesystem Commands

- **`setdown_link`**: *dialog, grep, readlink, ln*  
Creates a symlink from `$2` pointing to `$1`.

  ```bash
  setdown_link ~/dotfiles/.bashrc ~/.bashrc
  ```

  - If the link can't be created, the user will be asked to force linking.


- **`setdown_copy`**: *dialog, cmp, cp*  
Copies `$1` to `$2`.

  ```bash
  setdown_copy ~/dotfiles/.bashrc ~/.bashrc
  setdown_copy ~/dotfiles/.vim/ ~/.vim/
  ```

  - Directories will always be placed at the destination location rather than inside it.
  - If the destination already exists or copying fails, the user will be asked to force copying.
  - If the source is a file and the destination is identical, no copy is performed.
  - If the source is a directory and the destination is identical, the user will be prompted to overwrite.

- **`setdown_sudo_link`**: *dialog, sudo, grep, readlink, ln*  
Creates a symlink from `$2` pointing to `$1` with sudo permissions.

  ```bash
  setdown_sudo_link ~/dotfiles/my_script /usr/local/sbin/my_script
  ```

  - If the link can't be created, the user will be asked to force linking.


- **`setdown_sudo_copy`**: *dialog, sudo, cmp, cp*  
Copies `$1` to `$2` with sudo permissions.

  ```bash
  setdown_sudo_copy ~/dotfiles/my_script /usr/local/sbin/
  setdown_sudo_copy ~/dotfiles/shell-scripts/ /usr/local/sbin/shell-scripts
  ```

  - Directories will always be placed at the destination location rather than inside it.
  - If the destination already exists or copying fails, the user will be asked to force copying.
  - If the source is a file and the destination is identical, no copy is performed.
  - If the source is a directory and the destination is identical, the user will be prompted to overwrite.

### Utility Commands

- **`setdown_hascmd`**: *command*  
Determines if a command is available.

  ```bash
  if setdown_hascmd ruby; then
    ruby main.rb;
  fi
  ```

- **`setdown_hasstr`**: *no dependencies*  
Determines if a string is a member of an array.

  ```bash
  fruits=(apple banana cherry)
  if setdown_hasstr fruits 'celery'; then # false
    echo 'celery is a fruit'
  fi
  ```

## Development

When your changes are ready, create a pull request and I'll get to it as soon as possible! Continuous integration is set up to ensure builds pass, but you can use Docker locally to test your changes before pushing.

**Project Dev Tools**  
- [ShellCheck](https://github.com/koalaman/shellcheck) for static analysis
- [shUnit2](https://github.com/kward/shunit2) for the test framework
- [stub.sh](https://github.com/jimeh/stub.sh) for test mocks
- [Docker](https://www.docker.com) to run these tools

**Available `make` Commands**  
- `make test`: Test all supported shell versions
- `make test_bash4_4`: Test with Bash 4.4
- `make coverage`: Generate test coverage report
- `make lint`: Run static analysis

[coverage-badge]: https://codecov.io/gh/codehearts/setdown.sh/branch/master/graph/badge.svg
[coverage-link]:  https://codecov.io/gh/codehearts/setdown.sh
[license-badge]:  https://img.shields.io/badge/license-MIT-007EC7.svg
[build-badge]:    https://travis-ci.org/codehearts/setdown.sh.svg?branch=master
[build-link]:     https://travis-ci.org/codehearts/setdown.sh
