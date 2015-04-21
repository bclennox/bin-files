[[ -n $BASH_PROFILE_SOURCED ]] && return

BASH_PROFILE_SOURCED=yes

PROMPT_COMMAND='echo -ne "\033k\033\\"'
PS1="\[\e]2;\W: \$(~/.rvm/bin/rvm-prompt)\a\[\e[34m\][\W]\\$ \[\e[0m\]"
PS2="? "

set -C

FCEDIT="/usr/bin/vim"
HISTCONTROL=ignoredups
IGNOREEOF=10
EDITOR="/usr/bin/vim"
VISUAL="/usr/bin/vim"

export FCEDIT HISTCONTROL IGNOREEOF EDITOR VISUAL
export PATH="$HOME/bin:/usr/local/bin:$PATH"

for path in $(find $HOME/.config/profile.d -mindepth 1) ; do
  [[ -s $path ]] && source $path
done
