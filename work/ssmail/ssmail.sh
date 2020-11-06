m=simple/01.txt

function send1mail() {
	i=$1
	sed -Ei~ "s/Subject:[0-9]+/Subject:$i/" $m
	perl ssmail.pl `dirname $m` 
}

function send30mail() {
	s=$1
	for i in `seq $s $(($s + 29))`
	do
		echo $i
		send1mail $i
	done
}

function sendnmail() {
	n=$1
	s=$2
	for i in `seq $s $(($s + $n))`
	do
		echo $i
		send1mail $i
	done
}

