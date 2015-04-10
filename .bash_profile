[[ -n $BASH_PROFILE_SOURCED ]] && return

BASH_PROFILE_SOURCED=yes

PROMPT_COMMAND='echo -ne "\033k\033\\"'
PS1="\[\e]2;\W: \$(~/.rvm/bin/rvm-prompt)\a\[\e[34m\][\W]\\$ \[\e[0m\]"
PS2="? "

set -C
for command in bundle rake git; do
  complete -C "$HOME/bin/completions" -o default $command
done

FCEDIT="/usr/bin/vim"
HISTCONTROL=ignoredups
IGNOREEOF=10
EDITOR="/usr/bin/vim"
VISUAL="/usr/bin/vim"

export FCEDIT HISTCONTROL IGNOREEOF EDITOR VISUAL
export PATH="$HOME/bin:/usr/local/bin:$PATH"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

for path in .bash_aliases .bash_functions .rvm/scripts/rvm; do
  [[ -s "$HOME/$path" ]] && source "$HOME/$path"
done

eval "$(direnv hook bash)"
