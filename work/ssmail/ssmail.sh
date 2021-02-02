t=template.txt
#d=`dirname $t` 
d=sendnmail

function send1mail() {
	i=$1
	sed -Ei~ "s/Subject:[0-9]+/Subject:$i/" $t
	perl ssmail.pl $d
}

function sendnmail() {
	n=$1
	s=$2
	to=$3
	#for f in $d/*; do
	#	#if ! [ $f = $t ]; then
	#		rm -v $f
	#	#fi
	#done
	rm -v $d/*
	for i in `seq $s $(($s + $n - 1))`
	do
		echo $i
		sed -E "s/Subject:[0-9]+/Subject:$i/" $t > $d/$(printf %02d $i).txt ||
			return
	done
	perl ssmail.pl $d $to
}

