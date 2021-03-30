#!/bin/bash
# Copyright (C) 2021 Vu Tran Kien <vutrankien.vn@gmail.com>

# way to determine if we're on Mac's builtin bash or otherwise
isBashVers4Up() {
	[[ $BASH_VERSION =~ ^[45].* ]]
}

if ! isBashVers4Up; then
	export MAC=true
else
	unset MAC
fi

isMac() {
	[ -n "$MAC" ]
}

if ! isMac; then
	alias gdate=date
	alias gsed=sed
	alias gecho=echo
fi

# Some example alias instructions
# If these are enabled they will be used instead of any instructions
# they may mask.  For example, alias rm='rm -i' will mask the rm
# application.  To override the alias instruction use a \ before, ie
# \rm will call the real rm not the alias.
#
# Interactive operation...
# alias rm='rm -i'
alias rm='rm -v'
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -v'
#alias chmod='chmod -c'
#alias chown='chown -c'

# some more ls aliases
if isBashVers4Up; then
    alias ll='ls -lFh'
    alias lla='ls -alFh'
    alias la='ls -A'
    alias l='ls -CF'
else
    alias ls='ls -hF'                 # classify files in colour
    alias ll='ls -lFh'                              # long list
    alias la='ls -A'                              # all but . and ..
    alias lla='ls -lA'                            # all long but . and ..
    alias l='ls -CF'                              #
fi
alias egrep='egrep --color'

# git
alias gs='git status'
alias gss='git status --short'
# git pretty
alias gl1='git log --graph --date-order --date=default -C -M --pretty=format:"%Cred[%h]%Creset [%ad] %Cgreen%d%Creset %s"'
alias gl='git log --graph --date-order --date=default -C -M --pretty=format:"%Cred[%h]%Creset [%ad] %Cgreen%d%Creset %n          [%an] %s"'
alias gll='git log'
alias gla='git log --graph --date-order --date=default -C -M --pretty=format:"%Cred[%h]%Creset [%ad] %Cgreen%d%Creset %n          [%an] %s" --all'
alias gd='git diff'
alias gdc='git diff --cached'
#alias gh="git log --pretty=format:'%h' -n 1"
function __git_wrap_git_log() { __git_func_wrap _git_log; }
complete -o bashdefault -o default -o nospace -F __git_wrap_git_log gh

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# b) function cd_func
# This function defines a 'cd' replacement function capable of keeping, 
# displaying and accessing history of visited directories, up to 10 entries.
# To use it, uncomment it, source this file and try 'cd --'.
# acd_func 1.0.5, 10-nov-2004
# Petar Marinov, http:/geocities.com/h2428, this is public domain
# usage:	cd -- : list dirstack
#	 	cd -N : cd to dirstack
#		cd -  : == cd -1
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
#if isBashVers4Up; then
#	bind -x '"\eOS":cd --'
#else
	#bind '"\eOS":"\C-acd --\C-k\n"'
	bind -x '"\C-^":"cd -; cd --"'
#fi

### misc
latestFileOfDir() {
	dir=$1
	glob=${2:-'*.logcat'}
	ls -1 $dir/$glob |tail -1
}

process_cmdline() {
	pname=$1
	WMIC PROCESS WHERE "Name LIKE '$pname%'" GET commandLine /format:list |sed '/^$/d'
}
function mkcd { mkdir -pv $1 && cd $1 ;}

function has {
	local cmd=$1
	which $cmd >/dev/null
}
	
has unzip && function unzipToDir {
	zippath=$(realpath $1)
	zipfile=$(basename $1)
	#zipdir=$(bashname $1 | sed 's/\.[^.]*$//' )
	zipdir=${zipfile%.*}
	basedir=$(dirname ${zippath})
	mkdir $basedir/$zipdir
	pushd $basedir/$zipdir &&
		unzip $zippath
	popd
}

function changeToTildedPath() {
	#[[ -z "$1" ]] && return 1
	if [ -e "$1" ]; then
		newtok=`realpath "$1" | sed -r "s=$HOME=~="`
		echo "$newtok"
	else
		return 1
	fi
}

function readlineChangeToTildedPath() {
	[[ -z "$READLINE_LINE" || -z "$READLINE_POINT" ]] && return 1
	for tok in $READLINE_LINE; do
		if newtok=`changeToTildedPath $tok`; then
			READLINE_LINE=${READLINE_LINE/"$tok"/"$newtok"}
		fi
	done
}
bind -x '"\e~":readlineChangeToTildedPath'

function changeToRelativePath() {
	tok=${1/\~/~}
	realpath=`realpath ${tok}`
	if [ -e "$realpath" ]; then
		pwd=`pwd`/
		#[[ "$cygpath" =~ "^$pwd" ]]
		#echo $cygpath $pwd $? > /dev/stderr
		if [[ "$realpath" =~ "$pwd" ]]; then
			#echo $cygpath in $pwd > /dev/stderr
			newtok=${realpath/$pwd/}
			echo "$newtok"
			return 0
		else
			changeToTildedPath $realpath
			return $?
		fi
	fi
	return 1
}

function readlineChangeToRelativePath() {
	[[ -z "$READLINE_LINE" || -z "$READLINE_POINT" ]] && return 1
	for tok in $READLINE_LINE; do
		if newtok=`changeToRelativePath $tok`; then
			READLINE_LINE=${READLINE_LINE/"$tok"/$newtok}
		fi
	done
}
# Alt-F1
bind -x '"\e[17~": readlineChangeToRelativePath'

function mpvthunar() {
    local login=vutrankien:k
    i=0
    while [ "$i" -lt "$#" ]; do
	set -- "$@" "$( node -e "console.log(decodeURI(process.argv[1].replace('smb://','smb://$login@')))" -- "$1" )"
	shift
	i=$(( i + 1 ))
    done

    mpv "$unes" "$@"
}

wakealarm() {
    wakeat="$*"
    sudo sh -c "echo 0 > /sys/class/rtc/rtc0/wakealarm" && sudo sh -c "echo `date '+%s' -d "+ $wakeat"` > /sys/class/rtc/rtc0/wakealarm"
}

suspend-for() {
    dur=${*:-"1 min"}
    suspendcmd=${suspendcmd:-s2ram --force}
    sh -c "sleep 30 && echo $dur > /tmp/pm-suspend-duration && sudo $suspendcmd"
}

## Git

function gitIsDetaching() {
	branch=`git rev-parse --abbrev-ref HEAD`
	[ "$branch" = "HEAD" ]
	return $?
}

function gitDetachAndResetTo {
	local branch=`git describe --contains --all HEAD`
	echo 'current ref: '$branch
	echo 'git checkout --detach && git reset '$@
	sha1=${1}
	br=${2:-$sha1}
	if ! git rev-parse --quiet --verify "$br"; then
		# Branch not exists
		br=$sha1
	fi
	echo git reset $br
	if ! gitIsDetaching ; then
		echo Detach!
		git checkout --detach
	fi
	echo -n "Checkout [$br] after reset? "
	read a
	git reset --soft $br &&
		if [[ "$a" = y ]]; then
			git checkout "$br"
		fi
}
function __git_wrap_git_reset() { __git_func_wrap _git_reset; }
complete -o bashdefault -o default -o nospace -F __git_wrap_git_reset gitDetachAndResetTo

function rebase {
	mergebase=$(git merge-base $1 $2)
	echo "Rebasing $1 onto $2 from common ancestor($mergebase)? (Ctrl-C)"
	read
	git rebase $3 $4 $5 --onto $2 $mergebase $1
}
function __git_wrap_git_rebase() { __git_func_wrap _git_rebase; }
complete -o bashdefault -o default -o nospace -F __git_wrap_git_rebase rebase

function rebasen {
	onto=$1 ; shift
	b=$1 ; shift
	n=$1 ; shift
	echo "Rebase $b onto $onto with $n commits? (Ctrl-C) [$@]"
	read 
	git rebase $@ --onto $onto $b~$n $b
}
complete -o bashdefault -o default -o nospace -F __git_wrap_git_rebase rebasen

git_comparePatch() {
	hash1=$1
	hash2=$2
	diff --color <(git show $hash1) <(git show $hash2) 
}

gitGetFileVersion() {
	local rev=$1
	local path=$2
	git show $rev:$path > $path
}
function __git_wrap_git_checkout() { __git_func_wrap _git_checkout; }
complete -o bashdefault -o default -o nospace -F __git_wrap_git_checkout gitGetFileVersion

### adb
logcat_findProc() {
	regex=$1
	file=$2
	egrep -i "am_proc_start.*$regex" $file |sed -r 's/^.*\[0,([0-9]+),.*$/\1/' |tail -1
}

logcat_findProcs() {
	regex=$1
	#file=$(latestFileOfDir)
	file=$2
	tail=${3:+|tail -$3}
	#sed=${4:+|sed \"N;s/\\n/$4/\"}
	sed=${4:+|"awk \"{print}\" ORS=$4 |sed s/.$//"}
	eval "egrep -i \"am_proc_start.*($regex)\" $file |sed -r 's/^.*\[0,([0-9]+),.*$/\1/' $tail $sed"	#"
}

logcat_filterApp() {
	regex=$1
	#dir=$2
	#latestFile=$(latestFileOfDir $dir)
	file=$2
	pid=`logcat_findProc "$regex" "$file"`
	grep "$pid" "$file"
}

alias adb_='adb ${ADB_DEVICE:+-s $ADB_DEVICE}'
#function adb_ {
#	adb ${ADB_DEVICE:+-s $ADB_DEVICE} "$@"
#}

adb_runAs() {
	TEMP=`getopt s: $*`
	if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
	eval set -- "$TEMP"
	while true ; do
    case "$1" in
        -s) echo "Option s"; ser=${2} ; shift 2 ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; return 1 ;;
    esac
	done
	echo "Remaining arguments:"
	for arg do echo '--> '"\`$arg'" ; done
	app=$1
	shift
	adb ${ser:+-s $ser} shell run-as $app "$@"
}

adb_pullAppFile() {
	#com.kddi.android.auemail
	app=$1
	path=$2
	base=$(basename $path)
	ser=${3:-$ADB_DEVICE}
	# replace with install -D?
	localpath=./$ser/$app/$path
	mkdir -pv $(dirname $localpath)
	adb_="adb ${ser:+-s $ser}"
	#adb ${ser:+-s $ser} shell run-as $app "cat /data/user/0/$app/$path" > $app/$path
	$adb_ shell run-as $app "cat $path" > $localpath
	echo file pulled to $localpath
}

adb_pushAppFile() {
	#com.kddi.android.auemail
	app=$1
	fpath=$2
	dpath=$3
	tmppath=/data/local/tmp
	base=$(basename $fpath)
	ser=${4:-$ADB_DEVICE}
	adb_="adb ${ser:+-s $ser}"
	$adb_ push $fpath $tmppath/ &&
		$adb_ shell run-as $app cp -v $tmppath/$base $dpath
	echo "file pushed to $dpath of $app (via $tmppath)"
}

function adb_firstDevice {
	adb_getDevice 1
}

function adb_getDevice {
	local ord=${1:-1}
	ord=$(($ord + 1))
	adb devices |gsed -En $ord's/^([a-zA-Z0-9.:-]+).*/\1/p'
}

function adb_getIp {
	adb_ shell ip addr show dev wlan0 |sed -En 's/.*inet ([0-9.]+).*/\1/p' 
}

function adb_findPid {
    case "$1" in
        -r) 
			regex_syntax=$1 ; shift ;;
    esac
	sed="awk \"{print}\" ORS=\| |sed s/.$//"
	#echo $sed
	eval "adb_ shell ps -ef |grep -Ei \"$1\" |awk '{print \$2}'" "${regex_syntax:+|$sed}"
}

#ssh
# https://stackoverflow.com/a/18915067/1562087
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add
}

# Source SSH settings, if applicable
function load_or_start_agent {
    if [ -f "${SSH_ENV}" ]; then
        . "${SSH_ENV}" > /dev/null
        #ps ${SSH_AGENT_PID} doesn't work under cywgin
        ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
            start_agent
        }
    else
        start_agent
    fi
}

