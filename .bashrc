# -*- tab-width: 4; encoding: utf-8 -*-
# F1: change mintty directory (new sessions will default to $PWD)
bind -x '"\eOP": perl -s -e '\''$sl=length($s);print "mintty remembers ";if($sl>$l){print substr($s,0,$l/2),"...",substr($s,-$l/2)}else{print $s}print "!\n\e]7;$s\a"'\'' -- -s="$PWD" -l=40'
# Ctrl-Return:cd last dir
bind -x '"\C-^":cd - && pwd'
# Shift-F10: Restore vim session. (Press F10 in vim to store session - see ~/.vimrc)
bind -x '"\e[21;2~": vim -S Session.vim'
# F2: remember `now`
function now { now=`date +%Y%m%d%H%M`; echo "now is [$now]" ; }
bind -x '"\eOQ": now'
# Shift-F2: set $now to latest log on device (requires adb_)
bind -x '"\e[1;2Q": now=`adb_ exec-out "ls ./sdcard/log-*" | tail -1 | grep -Eo "[0-9]{4,}"`; echo "now is [$now]"'

# (ripped from cygwin profile.bash)
# b) function cd_func
# This function defines a 'cd' replacement function capable of keeping, 
# displaying and accessing history of visited directories, up to 10 entries.
# To use it, uncomment it, source this file and try 'cd --'.
# cd_func 1.0.5, 10-nov-2004
# Petar Marinov, http:/geocities.com/h2428, this is public domain
cd_func ()
{
  local x2 the_new_dir adir index
  local -i cnt

  if [[ $1 ==  "--" ]]; then
    dirs -v
    return 0
  fi

  the_new_dir=$1
  [[ -z $1 ]] && the_new_dir=$HOME

  if [[ ${the_new_dir:0:1} == '-' ]]; then
    #
    # Extract dir N from dirs
    index=${the_new_dir:1}
    [[ -z $index ]] && index=1
    adir=$(dirs +$index)
    [[ -z $adir ]] && return 1
    the_new_dir=$adir
  fi

  #
  # '~' has to be substituted by ${HOME}
  [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

  #
  # Now change to the new dir and add to the top of the stack
  pushd "${the_new_dir}" > /dev/null
  [[ $? -ne 0 ]] && return 1
  the_new_dir=$(pwd)

  #
  # Trim down everything beyond 11th entry
  popd -n +11 2>/dev/null 1>/dev/null

  #
  # Remove any other occurence of this dir, skipping the top of the stack
  for ((cnt=1; cnt <= 10; cnt++)); do
    x2=$(dirs +${cnt} 2>/dev/null)
    [[ $? -ne 0 ]] && return 0
    [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
    if [[ "${x2}" == "${the_new_dir}" ]]; then
      popd -n +$cnt 2>/dev/null 1>/dev/null
      cnt=cnt-1
    fi
  done

  return 0
}
alias cd=cd_func
# F4: print dir stack (require cd_func())
bind -x '"\eOS":cd --'

# The following adb-related functions use this.
# define ADB_DEVICE if multiple devices are connecting.
function adb_ {
	if [ -n "$ADB_DEVICE" ]; then
		adb -s $ADB_DEVICE "$@"
	else
		adb "$@"
	fi
}
# Wakeful adb
alias adbw='adb_ shell input keyevent KEYCODE_WAKEUP ; adb_'

function adbFindPid() {
	local tag=$1
	local prefix=${2} #:+"-e "
	local delim=${3:-\|}
	local awk='BEGIN{first=1}/@tag@/{if(first==1){printf "@prefix@";first=0}print $2}' 
	awk="${awk/@tag@/$tag}"
	awk="${awk/@prefix@/$prefix}"
	adb_ exec-out ps | awk "$awk" | paste -sd "$delim" - | tee /dev/stderr
}

function adb_edit {
	name=`basename $1`
	adb_ pull $1 /tmp && vim /tmp/$name && {
		adb_ exec-out cat $1 | tee >(diff -u --color - /tmp/$name >&2) | cmp - /tmp/$name || {
			#cmp /tmp/$name <(adb exec-out cat $1)
			adb_ push /tmp/$name //data/local/tmp/$name && adb_ exec-out "cat //data/local/tmp/$name > $1"
		}
	}
	#rm -v /tmp/$name
}
