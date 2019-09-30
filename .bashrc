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
	last_timestamp=`gdate +%s`
	last_line=${rl0:-$READLINE_LINE}
	last_line=$1
	# set wintitle
	last_time_MS=`gdate --date=@${last_timestamp:-0} +%M%S`
	gecho -ne "\e]0;${last_line/\\/^}|$PWD [${last_time_MS}]\a"
}

prompt_command_function () {
	# Whenever displaying the prompt, write the previous line to disk
	history -a
	last_sts=$?
	if [ -z "$last_timestamp" ]; then
		last_time=0
	else
		last_time=$((`gdate +%s` - ${last_timestamp:-0}))
	fi
	[ $last_time -gt 5 ] && echo -ne \\a
	# set wintitle
	last_time_HMS=`gdate --date=@${last_timestamp:-0} +%H%M%S`
	#isBashVers5 &&
	gecho -ne "\e]0;${last_line/\\/^}|`basename "$PWD"`\a"
	# History log
	if [ "$(id -u)" -ne 0 ]; then
		echo "$(gdate "+%Y-%m-%d.%H:%M:%S") $(pwd) $(history 1)" >> ~/.logs/bash-history-$(gdate "+%Y-%m-%d").log
		typed=$(history 1 | gsed -r 's/^\s*[0-9]+\s*//')
		hist_cmd=$(history 1 | cut -d\  -f 2)
		last_timestamp=${last_timestamp:-`gdate +%s`}
		histool save "$last_timestamp" "$typed"
	fi
}

test -f ~/.bash_prompt && . ~/.bash_prompt

if isBashVers5; then
	PATH=/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/gnu-sed/libexec/gnubin:$PATH
	#bpx
	source $HOME/gits/bpx/bpx.bash
	bind 'RETURN: "\C-x\C-x1"'
	preexec_functions=(command_enter_function)
	PROMPT_COMMAND=__bpx_hook_prompt
	prompt_functions=(prompt_command_function)
else
	#bind 'RETURN: "\C-x\C-f"'
	#bind -x '"\C-x\C-f": command_enter_function'
	source ~/gits/bash-preexec/bash-preexec.sh
	preexec_functions+=(command_enter_function)
	precmd_functions+=(prompt_command_function)
	#PROMPT_COMMAND=prompt_command_function
fi
