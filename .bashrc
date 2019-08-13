histdb="$HOME/.history.db"

prompt_command_function ()
{
	last_sts=$?
	if [ -z "$last_timestamp" ]; then
		last_time=0
	else
		last_time=$((`date +%s` - ${last_timestamp:-0}))
	fi
	[ $last_time -gt 5 ] && echo -ne \\a
	# Whenever displaying the prompt, write the previous line to disk
	history -a
	# set wintitle
	last_time_HMS=`date --date=@${last_timestamp:-0} +%H%M%S`
	echo -ne "\e]0;$last_line|`basename $PWD`\a"
	# History log
	if [ "$(id -u)" -ne 0 ]; then
	    #echo "$(date "+%Y-%m-%d.%H:%M:%S") $(pwd) $(history 1)" >> ~/.logs/bash-history-$(date "+%Y-%m-%d").log
		typed=$(history 1 | sed -r 's/^\s*[0-9]+\s*//')
		hist_cmd=$(history 1 | cut -d\  -f 2)
		#sqlite3 ~/.history.db 'INSERT INTO history (timestamp,duration,pwd,hispos,typed,expanded) VALUES ('$last_timestamp','$last_time',"'$(pwd)'","'$HISTCMD'","'$last_line'","'$typed'")'
		if [ -n "$last_line" ]; then
			if [ "$last_line" != "$typed" ]; then
				sqlite3 $histdb "INSERT INTO history (timestamp,duration,pwd,hispos,typed,expanded) VALUES ($last_timestamp,$last_time,'$(pwd)',$HISTCMD,'${last_line//\'/\'\'}','${typed//\'/\'\'}')"
			else
				sqlite3 $histdb "INSERT INTO history (timestamp,duration,pwd,hispos,typed) VALUES ($last_timestamp,$last_time,'$(pwd)','$hist_cmd','${last_line//\'/\'\'}')"
			fi
		fi
	fi
}
command_enter_function ()
{
	last_timestamp=`date +%s`
	last_line=$READLINE_LINE
	# set wintitle
	last_time_MS=`date --date=@${last_timestamp:-0} +%M%S`
	#echo -ne "\e]0;$READLINE_LINE|$PWD [${last_time_MS}]\a\e[A"
	echo -e "\e]0;$READLINE_LINE|$PWD [${last_time_MS}]\a"
}

export HISTSIZE=2000
export HISTFILESIZE=10000
export HISTCONTROL=ignoreboth:erasedups
#
# Whenever displaying the prompt, write the previous line to disk
#last_timestamp=0
#export PROMPT_COMMAND='prompt_command_function'
export PROMPT_COMMAND='history -a'

export EDITOR='vim'
# Functions
#
# Some people use a different file for functions
if [ -f "${HOME}/.bash_functions" ]; then
  source "${HOME}/.bash_functions"
fi

# F4: print dir stack (require cd_func())
bind -x '"\eOS": cd_func --'
bind '"\eOS": " cd --\n"'

source $(git --exec-path)/../../share/git-core/git-completion.bash
