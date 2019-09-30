# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

HISTSIZE=2000
HISTFILESIZE=10000
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth:erasedups

# Functions
#
# Some people use a different file for functions
if [ -f "${HOME}/.bash_functions" ]; then
  source "${HOME}/.bash_functions"
fi

command_enter_function ()
{
	last_timestamp=`date +%s`
	last_line=${rl0:-$READLINE_LINE}
	last_line=$1
	# set wintitle
	last_time_MS=`date --date=@${last_timestamp:-0} +%M%S`
	echo -ne "\e]0;${last_line/\\/^}|$PWD [${last_time_MS}]\a"
}

prompt_command_function () {
	# Whenever displaying the prompt, write the previous line to disk
	history -a
	last_sts=$?
	if [ -z "$last_timestamp" ]; then
		last_time=0
	else
		last_time=$((`date +%s` - ${last_timestamp:-0}))
	fi
	[ $last_time -gt 5 ] && echo -ne \\a
	# set wintitle
	last_time_HMS=`date --date=@${last_timestamp:-0} +%H%M%S`
	#isBashVers5 &&
	echo -ne "\e]0;${last_line/\\/^}|`basename "$PWD"`\a"
	# History log
	if [ "$(id -u)" -ne 0 ]; then
	   echo "$(date "+%Y-%m-%d.%H:%M:%S") $(pwd) $(history 1)" >> ~/.logs/bash-history-$(date "+%Y-%m-%d").log
		typed=$(history 1 | sed -r 's/^\s*[0-9]+\s*//')
		hist_cmd=$(history 1 | cut -d\  -f 2)
		last_timestamp=${last_timestamp:-`date +%s`}
		histool save "$last_timestamp" "$typed"
	fi
}

test -f ~/.bash_prompt && . ~/.bash_prompt

#bind 'RETURN: "\C-x\C-f"'
#bind -x '"\C-x\C-f": command_enter_function'
source ~/gits/bash-preexec/bash-preexec.sh
preexec_functions+=(command_enter_function)
precmd_functions+=(prompt_command_function)
#PROMPT_COMMAND='prompt_command_function'

# Put your fun stuff here.
complete -cf sudo

bind -x '"\eE": echo -n "$READLINE_LINE" | xsel -b'

# Enable completion
if [ -f /etc/bash/bashrc.d/bash_completion.sh ]; then
    source /etc/bash/bashrc.d/bash_completion.sh
fi

