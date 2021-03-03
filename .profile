#!/bin/bash
# TODO adapt to local environment
#JAVA_HOME=/Users/vutran.kien/Library/Developer/Xamarin/jdk/microsoft_dist_openjdk_1.8.0.25
#ANDROID_HOME=~/Android/Sdk
#PATH=$PATH:$ANDROID_HOME/platform-tools
if [ -d ~/bin ]; then
	PATH=~/bin:$PATH
fi
if [ -d ~/.local/bin ]; then
	PATH=~/.local/bin:$PATH
fi

#SHELL_SESSION_HISTORY=0
#EDITOR=vim

#export ANDROID_HOME

#export GTK_IM_MODULE=ibus
#export QT_IM_MODULE=ibus
#export XMODIFIERS=@im=ibus

#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

