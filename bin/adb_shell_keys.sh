function adb_ {
    if [ -z "$ADB_DEVICE" ]; then
        adb "$@"
    else
        adb -s $ADB_DEVICE "$@"
    fi
}

adb_input_F1() { adb_ shell input keyevent KEYCODE_F1 ;}
zle -N adb_input_F1
#bindkey '^[[17~' adb_input_F1
bindkey '^[OP' adb_input_F1
adb_input_F2() { adb_ shell input keyevent KEYCODE_F2 ;}
zle -N adb_input_F2
#Alt-F2
#bindkey '^[[18~' adb_input_F2
bindkey '^[OQ' adb_input_F2
function adb_input_dpad_center { adb_ shell input keyevent 23; }
zle -N adb_input_dpad_center
bindkey "^j" adb_input_dpad_center
function adb_input_back { adb_ shell input keyevent KEYCODE_BACK; }
zle -N adb_input_back
bindkey "^[b" adb_input_back
declare -A keys
keys[UP]="OA"
keys[DOWN]="OB"
function adb_input_ {
   if [ "$KEYS" = $keys[UP] ]; then
	   adb_ shell input keyevent KEYCODE_DPAD_UP
   elif [ "$KEYS" = $keys[DOWN] ]; then
	   adb_ shell input keyevent KEYCODE_DPAD_DOWN
   else
   	   adb_ shell input keyevent KEYCODE_$KEYS
   fi
}
zle -N adb_input_
bindkey "1" adb_input_
bindkey "2" adb_input_
bindkey "$keys[UP]" adb_input_
bindkey "$keys[DOWN]" adb_input_
