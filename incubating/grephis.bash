#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8 -*-

check_sqlite3() {
	#which sqlite3 &> /dev/null
	command -v sqlite3 > /dev/null
	return $?
}
