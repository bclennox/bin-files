ack(){
  pattern="$1"
  shift

  if [ $# = 0 ]; then
    dirs=.
  else
    dirs=$*
  fi

  if [ "x$ACK_GREP" = "x" ]; then
    grep=grep
  else
    grep=$ACK_GREP
  fi

  for dir in $dirs; do
    # find/bash can't handle all these special characters when they're in
    # variables, so don't bother trying to optimize these excluded paths
    find ${dir%/} \( -path '*/db' -o -path '*/.git' -o -path '*/.svn' -o -path '*/public/ext' -o -path '*/public/ext4' -o -path '*/public/assets' -o -path '*/vendor' -o -path '*/app/assets/javascripts/lib' -o -path '*/tmp' -o -path '*/log' \) -prune -o -type f -print0 | xargs -0 $grep -n "$pattern"
  done
}

app(){
  supercd "$HOME/apps" "$1" master
}

echzec(){
  echo "$*"
  sh -c "$*"
}

gems(){
  dir=$(rvm gemdir)

  if [ -n "$1" ]; then
    gem=$1
  fi

  supercd $dir/gems $gem
}

jsack(){
  ack $1 app/views/ app/assets/javascripts/ public/javascripts/ | grep -v app/assets/javascripts/lib
}

m(){
  dir=$PWD
  until [ -d "$dir/.git" ]; do
    dir=$(cd "$dir/.." && pwd)
    if [[ $dir = '/' ]]; then
      echo "Couldn't find a .git directory. Are you in a git repo?"
      return 1
    fi
  done
  cd "$dir" && pwd
}

me(){
  _ssh brandanl $1
}

repo(){
  root=$HOME/repos
  projects=($(cat $root/.repos))

  if [ -z "$1" ]; then
    echo "Select a project:"
    i=1
    for project in ${projects[@]}; do
      echo "  [$i] $project"
      i=$((i + 1))
    done
    echo -n '? '

    read id
  else
    id=$1
  fi

  if [ $id = 0 ]; then
    cd $root
  else
    cd "$root/${projects[$((id - 1))]}"
  fi

  pwd
}

rmsshkey(){
  last=$_

  if [ -z "$1" -a -n "$last" ]; then
    rmsshkey $last
  else
    while [ $# -ne 0 ] ; do
      local re=${1#*@}
      echo "Removing $re"
      if [ -n "$re" -a -f ~/.ssh/known_hosts ] ; then
        perl -ni -e "print unless /$re/" ~/.ssh/known_hosts
      fi
      shift
    done
  fi
}

root(){
  _ssh root $1
}

routes(){
  rake routes | grep "$1"
}

site(){
  supercd "$HOME/Sites" "$1" htdocs
}

src(){
  supercd "$HOME/src" "$1"
}

_ssh(){
  user=$1
  host=192.168.$(echo $2 | perl -lne 'print /\./ ? $_ : "42.$_"')
  ssh $user@$host
}

# will cd into $1, look for a subdirectory starting with $2,
# cd into that if it exists, and potentially cd into $3 or $2
# if that exists under $1/$2
supercd(){
  dir=$1
  subdir=$2
  repo=$3

  if [ -z "$2" ]; then
    cd $1
  else
    if [ ! -d "$dir/$subdir" ]; then
      subdir=$(ls "$dir" | grep "\b$subdir" | head -1)
      if [ -z "$subdir" ]; then echo "No such project: $2" && return 1; fi
    fi

    cd "$dir/$subdir"

    if [ -n "$repo" ]; then
      if [ -d "$dir/$subdir/$repo" ]; then
        cd $3
      elif [ -d "$dir/$subdir/$subdir" ]; then
        cd "$dir/$subdir/$subdir"
      fi
    fi
  fi

  pwd
}
