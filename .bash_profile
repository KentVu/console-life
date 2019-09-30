JAVA_HOME=/Users/vutran.kien/Library/Developer/Xamarin/jdk/microsoft_dist_openjdk_1.8.0.25
ANDROID_HOME=/Users/vutran.kien/Library/Developer/Xamarin/android-sdk-macosx
PATH=$PATH:$ANDROID_HOME/platform-tools
if [ -d ~/bin ]; then
	PATH=~/bin:$PATH
fi
SHELL_SESSION_HISTORY=0
EDITOR=vim

# generated by Git for Windows
test -f ~/.profile && . ~/.profile
# This file is sourced by bash for login shells.  The following line
# runs your .bashrc and is recommended by the bash info pages.
if [[ -f ~/.bashrc ]] ; then
	. ~/.bashrc
fi
