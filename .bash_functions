echzec(){
  echo "$*"
  sh -c "$*"
}

gems(){
  pcd $(bundle show $1)
}

# Usage: m
#
# Climbs the directory tree until it reaches the root of a Git repository.
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
  quick_ssh brandanl $1
}

# Usage: quick_ssh user hostish
#
# SSHes you into a machine on the local network. The hostish argument
# will be passed to the raleigh_ip script, so see the docs on that:
#
#   quick_ssh brandanl 49       # ssh brandanl@192.168.42.49
#   quick_ssh root 43.151       # ssh root@192.168.43.151
#   quick_ssh user smoke-test   # ssh user@smoke-test
#
# You'll probably never call this directly. Use me() and root() instead:
#
#   me 49
#   root 43.151
quick_ssh(){
  user=$1
  host=$(raleigh_ip $2)

  ssh $user@$host
}

# Usage: repo [id]
#
# Clone all your Git repos into ~/repos. Create a file named ~/repos/.repos
# containing the newline-separated repo names:
#
#   poweriq_web
#   poweriq_web_rpm
#   poweriq_core
#
# Then run `repo 1` to cd directly into ~/repos/poweriq_web. Or run `repo`
# with no argument to see the full list with numbers.
repo(){
  root=$HOME/repos
  projects=($(cat $root/.repos))
  pattern='^[0-9]+$'

  if [ -z "$1" ]; then
    echo "Select a project:"
    i=1
    for project in ${projects[@]}; do
      echo "  [$i] $project"
      i=$((i + 1))
    done
    echo -n '? '

    read id
  elif [[ $1 =~ $pattern ]]; then
    id=$1
  else
    return 1
  fi

  if [ $id = 0 ]; then
    cd $root
  else
    cd "$root/${projects[$((id - 1))]}"
  fi

  pwd
}

# Usage: rmsshkey [host ...]
#
# Removes an IP address or hostname from your ~/.ssh/known_hosts file. By
# default, removes the last argument of the last command (i.e., $_):
#
#   $ ssh brandanl@192.168.42.140
#   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#   @    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
#   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#   $ rmsshkey
#   Removing 192.168.42.140
#   $ ssh brandanl@192.168.42.140
#   The authenticity of host ...
#
# But you can pass arguments too:
#
#   $ rmsshkey 42.140 smoke-test
#   Removing 42.140
#   Removing smoke-test
rmsshkey(){
  last=$_

  if [ -z "$1" -a -n "$last" ]; then
    rmsshkey $last
  else
    while [ $# -ne 0 ] ; do
      local re=${1#*@} # strips everything up to and including an @ symbol
      # If available use the Open SSH keygen tool since
      # hostnames may be hashed.
      if [ -n $(which ssh-keygen) ] ; then
        hostre=$(raleigh_ip $re)
        ssh-keygen -q -f ~/.ssh/known_hosts -R $hostre 2>/dev/null 1>/dev/null
      elif [ -n "$re" -a -f ~/.ssh/known_hosts ] ; then
        perl -ni -e "print unless /$re/" ~/.ssh/known_hosts
      fi
      shift
    done
  fi
}

root(){
  quick_ssh root $1
}

routes(){
  rake routes | grep "$1"
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
