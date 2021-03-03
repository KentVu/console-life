wakealarm() {
    wakeafter="$*"
    wakeat=`date '+%s' -d "+ $wakeafter"`
    echo $wakeafter: $wakeat
    #sudo sh -c "echo 0 > /sys/class/rtc/rtc0/wakealarm" && sudo sh -c "echo `date '+%s' -d "+ $wakeafter"` > /sys/class/rtc/rtc0/wakealarm"
    echo 0 > /sys/class/rtc/rtc0/wakealarm && echo $wakeat > /sys/class/rtc/rtc0/wakealarm
}

wakealarm "$@"
