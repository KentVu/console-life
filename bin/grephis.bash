#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8 -*-

histdb='C:/Users/core-kien/.history.db'

check_sqlite3() {
	#which sqlite3 &> /dev/null
	command -v sqlite3 > /dev/null
	return $?
}

save_cmdline() {
	local cmd="$1"
	local date="$2"
	local pwd="$3"
	echo cmd:\"$cmd\" date:$date pwd:$pwd
	sqlite3 $histdb <<<"INSERT INTO history (pwd,hispos,typed,expanded,sha1) VALUES ($last_timestamp,$last_time,'$cwd','$hist_cmd','${last_line//\'/\'\'}','$typed','$shatag')"
	return $?
}
