#!/bin/bash

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
alias chmod='chmod -c'
alias chown='chown -c'

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

alias ls='ls -hF'                 # classify files in colour
alias ll='ls -lFh'                              # long list
alias la='ls -A'                              # all but . and ..
alias lla='ls -lA'                            # all long but . and ..
alias l='ls -CF'                              #

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

isBashVers5() {
	[[ $BASH_VERSION =~ ^5.* ]]
}

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
# F4: view dir stack
if isBashVers5; then
	bind -x '"\eOS":cd --'
else
	bind '"\eOS":"\C-acd --\C-k\n"'
fi

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
# Ctrl-.
bind -x '"\eOP": readlineChangeToRelativePath'

## git

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
