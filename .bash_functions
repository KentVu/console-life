#!/bin/bash

alias cp='cp -vi'
alias mv='mv -vi'
alias mkdir='mkdir -v'
alias chmod='chmod -c'
alias chown='chown -c'

# git
alias gd="git diff"
alias gd2="git diff --ignore-all-space"
#alias gdw="git diff --color-words"
alias gdc="git diff --cached"
#alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
#alias gla="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
alias gl='git log --graph --date-order --date=default -C -M --pretty=format:"%Cred[%h]%Creset [%ad] %Cgreen%d%Creset %n          [%an] %s"'
#alias gl1='git log --graph --date-order --date=default -C -M --pretty=format:"%Cred[%h]%Creset [%ad] %Cgreen%d%Creset %s"'
alias gla='git log --graph --date-order --date=default -C -M --pretty=format:"%Cred[%h]%Creset [%ad] %Cgreen%d%Creset %n          [%an] %s" --all'
alias gsn='git status -uno'
alias gs='git status'
alias gss='git status --short'

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

# some more ls aliases
alias ll='ls -lFh'
alias lla='ls -alFh'
alias la='ls -A'
alias l='ls -CF'

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
