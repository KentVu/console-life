#!/bin/bash
function gitIsDetaching() {
	branch=`git rev-parse --abbrev-ref HEAD`
	[ "$branch" = "HEAD" ]
	return $?
}

function gitDetachAndResetTo {
	local branch=`git describe --contains --all HEAD`
	echo 'current ref: '$branch
	echo 'git checkout --detach && git reset '$@
	sha1=${1}
	br=${2:-$sha1}
	if ! git rev-parse --quiet --verify "$br"; then
		# Branch not exists
		br=$sha1
	fi
	echo git reset $br
	if ! gitIsDetaching ; then
		echo Detach!
		git checkout --detach
	fi
	echo -n "Checkout [$br] after reset? "
	read a
	git reset --soft $br &&
		if [[ "$a" = y ]]; then
			git checkout "$br"
		fi
}
gitDetachAndResetTo $1 $2
read -t3
