DISABLE_AUTO_TITLE="true"
echo -n -e "\033]0;$0\007"

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
#zle -N adb_input_back
declare -A keys
keys[BACK]="b"
keys[UP]="OA"
keys[DOWN]="OB"
keys[LEFT]="OD"
keys[RIGHT]="OC"
keys[HOME]="h"
keys[ENDCALL]="c"
keys[F3]="OR"
keys[F4]="OS"
keys[CENTER]="d"
keys[CAPTURE]="t"
typeset -A reversed_keys
for k v ("${(@kv)keys}") reversed_keys[$v]=$k
bindkey "$keys[BACK]" adb_input_
bindkey "$keys[UP]" adb_input_
bindkey "$keys[DOWN]" adb_input_
bindkey "$keys[LEFT]" adb_input_
bindkey "$keys[RIGHT]" adb_input_
bindkey "$keys[HOME]" adb_input_
bindkey "$keys[ENDCALL]" adb_input_
bindkey "$keys[F3]" adb_input_
bindkey "$keys[F4]" adb_input_
bindkey "$keys[CENTER]" adb_input_
bindkey "$keys[CAPTURE]" adb_input_
zle -N adb_input_
function adb_input_ {
    keyname=$reversed_keys[$KEYS]
    date +%H%M%S-$keyname-${(qqqq)KEYS}
    if [ "$KEYS" = $keys[UP] ]; then
        adb_ shell input keyevent KEYCODE_DPAD_UP
    elif [ "$KEYS" = $keys[DOWN] ]; then
        adb_ shell input keyevent KEYCODE_DPAD_DOWN
    elif [ "$keyname" = LEFT ]; then
        adb_ shell input keyevent KEYCODE_DPAD_$keyname
    elif [ "$KEYS" = $keys[RIGHT] ]; then
        adb_ shell input keyevent KEYCODE_DPAD_RIGHT
    elif [ "$KEYS" = $keys[ENDCALL] ]; then
        adb_ shell input keyevent KEYCODE_ENDCALL
    elif [ "$KEYS" = $keys[F3] ]; then
        adb_ shell input keyevent KEYCODE_F3
    elif [ "$KEYS" = $keys[F4] ]; then
        adb_ shell input keyevent KEYCODE_F4
    elif [ "$KEYS" = $keys[CENTER] ]; then
        adb_ shell input keyevent KEYCODE_DPAD_CENTER
    elif [ "$KEYS" = $keys[CAPTURE] ]; then
        date=$(date +%Y%m%d-%H%M%S)
        filename=cap-$date.png
        file=./sdcard/$filename
        adb_ shell screencap $file
        adb_ pull $file
    elif [ -n "$keyname" ]; then
        adb_ shell input keyevent KEYCODE_$keyname
    else
        adb_ shell input keyevent KEYCODE_$KEYS
    fi
}
bindkey "1" adb_input_
bindkey "2" adb_input_
