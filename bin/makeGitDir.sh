#!/bin/bash
from=$1
to=$2
common=$3
branch=${4:+-b $4}
base=$(basename $common)
rfrom=$from/$common
rto=$to/$common
if [ -d $base ]; then
    echo $base exists!
    exit 1
elif [ ! -d $rfrom/.git ]; then
    echo $rfrom is not a git repository!
    exit 1
elif [ -d $rto/.git ]; then
    echo $rto is already a git repository!
    exit 1
fi
#cp $from/.git $to
#if [ -n "$branch" ]; 
git clone --no-checkout $rfrom $branch &&
  mv -vi $base/.git $rto/.git &&
  rm -r $base &&
  #mitigate --no-checkout: make index keep up with current source tree
  cd $rto && git reset HEAD
