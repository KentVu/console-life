#!/bin/bash

# generated by Git for Windows
test -f ~/.profile && . ~/.profile

# Launch ssh-agent upon login
#ssh-add
# This file is sourced by bash for login shells.  The following line
# runs your .bashrc and is recommended by the bash info pages.
if [[ -f ~/.bashrc ]] ; then
	. ~/.bashrc
fi
