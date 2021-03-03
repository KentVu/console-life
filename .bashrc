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
	# always the first line
	last_sts=$?
	# Whenever displaying the prompt, write the previous line to disk
	history -a
	if [ -z "$last_timestamp" ]; then
		last_time=0
	else
		last_time=$((`gdate +%s` - ${last_timestamp:-0}))
	fi
	[ $last_time -gt 5 ] && echo -ne \\a
	# set wintitle
	last_time_HMS=`gdate --date=@${last_timestamp:-0} +%H%M%S`
	#isBashVers4Up &&
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

if isBashVers4Up; then # xterm terminal
	#bpx
	source $HOME/gits/bpx/bpx.bash
	bind 'RETURN: "\C-x\C-x1"'
	preexec_functions=(command_enter_function)
	PROMPT_COMMAND=__bpx_hook_prompt
	prompt_functions=(prompt_command_function)
else # mac terminal
	#bind 'RETURN: "\C-x\C-f"'
	#bind -x '"\C-x\C-f": command_enter_function'
	preexec_functions+=(command_enter_function)
	precmd_functions+=(prompt_command_function)
	#PROMPT_COMMAND=prompt_command_function
	source ~/gits/bash-preexec/bash-preexec.sh
fi
# Put your fun stuff here.
#complete -cf sudo

# Copy current line on Alt-E
bind -x '"\eE": echo -n "$READLINE_LINE" | xsel -b'

# Enable completion
if [ -f /etc/bash/bashrc.d/bash_completion.sh ]; then
    source /etc/bash/bashrc.d/bash_completion.sh
fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# auto attach tmux session
if [[ ! -n "$WINDOW" && -z "$TMUX" && ! "$TERM" =~ "screen" && ! "$TERM" = linux && "$SHLVL" -eq 1 && -z "$BYPASS_TMUX" ]]; then
    if [[ -n "$SSH_CONNECTION" ]]; then
		: screen
		#sudo sh -c "echo 0 > /sys/class/rtc/rtc0/wakealarm" && sudo sh -c "echo ` date '+%s' -d '+ 3 hours'` > /sys/class/rtc/rtc0/wakealarm" &&
		#DISPLAY=:0 xdotool mousemove_relative 5 5
		tmux attach -t mobile
    fi
fi
