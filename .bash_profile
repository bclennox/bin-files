[[ -n $BASH_PROFILE_SOURCED ]] && return

BASH_PROFILE_SOURCED=yes

PROMPT_COMMAND='echo -ne "\033k\033\\"'
PS1="\[\e]2;\u@\H: \w\a\[\e[32m\][\$(~/.rvm/bin/rvm-prompt i v p g s) \W]\\$ \[\e[0m\]"
PS2="? "

set -C
for command in bundle rake git; do
  complete -C "$HOME/bin/completions" -o default $command
done

FCEDIT="/usr/bin/nano -w"
HISTCONTROL=ignoredups
IGNOREEOF=10
EDITOR="/usr/bin/nano -w"
VISUAL="/usr/bin/vim"

export FCEDIT HISTCONTROL IGNOREEOF EDITOR VISUAL

export PATH="$HOME/bin:/usr/local/git/bin:/usr/local/mysql/bin:/usr/local/pear/bin:/usr/local/sbin:/usr/local/bin:$PATH"
export RUNWAY=66.93.99.4

LSCOLORS="exGxcxdxCxegedabagacad"
export CLICOLOR LSCOLORS

for path in .bash_aliases .bash_functions .rvm/scripts/rvm; do
  [[ -s "$HOME/$path" ]] && source "$HOME/$path"
done

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
