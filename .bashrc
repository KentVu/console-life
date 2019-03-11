# Ctrl-Return:cd last dir
bind -x '"\C-^":cd - && pwd'
# Shift-F10: Restore vim session. (Press F10 in vim to store session - see ~/.vimrc)
bind -x '"\e[21;2~": vim -S Session.vim'
