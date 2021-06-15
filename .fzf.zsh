# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/vutran.kien/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/Users/vutran.kien/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/Users/vutran.kien/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/Users/vutran.kien/.fzf/shell/key-bindings.zsh"
