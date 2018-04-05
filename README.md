# setdown.sh

[![Build Status][build-badge]][build-link] [![Coverage][coverage-badge]][coverage-link] [![MIT License][license-badge]](LICENSE.md)

Utilities for making interactive system setup easier. Supports Bash 4.4+. Some commands depend on `dialog`, but not all! This readme will tell you the dependencies for each function.

I'm personally using setdown.sh for my [dotfiles](https://github.com/codehearts/dotfiles), check out my [katify.sh script](https://github.com/codehearts/dotfiles/blob/master/katify.sh) for ideas on how to use it. I'm able to configure an entire Arch Linux or macOS system by selecting the packages I want and choosing which dotfiles to link in.

## Command Reference

### Filesystem Commands

#### `setdown_link`

**depends on: dialog | grep | readlink | ln**  
Creates a symlink from `$2` pointing to `$1`.

- If the link can't be created, the user will be asked to force linking.

```bash
setdown_link ~/dotfiles/.bashrc ~/.bashrc
```

#### `setdown_copy`

**depends on: dialog | cmp | cp**  
Copies `$1` to `$2`.

- Directories will always be placed at the destination location rather than inside it.
- If the destination already exists or copying fails, the user will be asked to force copying.
- If the source is a file and the destination is identical, no copy is performed.
- If the source is a directory and the destination is identical, the user will be prompted to overwrite.

```bash
setdown_copy ~/dotfiles/.bashrc ~/.bashrc
setdown_copy ~/dotfiles/.vim/ ~/.vim/
```

#### `setdown_sudo_link`

**depends on: dialog | sudo | grep | readlink | ln**  
Creates a symlink from `$2` pointing to `$1` with sudo permissions.

- If the link can't be created, the user will be asked to force linking.

```bash
setdown_sudo_link ~/dotfiles/my_script /usr/local/sbin/my_script
```

#### `setdown_sudo_copy`

**depends on: dialog | sudo | cmp | cp**  
Copies `$1` to `$2` with sudo permissions.

- Directories will always be placed at the destination location rather than inside it.
- If the destination already exists or copying fails, the user will be asked to force copying.
- If the source is a file and the destination is identical, no copy is performed.
- If the source is a directory and the destination is identical, the user will be prompted to overwrite.

```bash
setdown_sudo_copy ~/dotfiles/my_script /usr/local/sbin/
setdown_sudo_copy ~/dotfiles/shell-scripts/ /usr/local/sbin/shell-scripts
```

### Utility Commands

#### `setdown_hascmd`

**depends on: command**  
Determines if a command is available.

```bash
if setdown_hascmd ruby; then
  ruby main.rb;
fi
```

#### `setdown_hasstr`

**depends on: no dependencies**  
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
