#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

load grephis

check_sqlite3 >&2 || exit

@test "Given cmdline then persist to sqlite3" {
	run save_cmdline "test_cmd arg1 2 3 4" $(($(date +%s) - 3)) "$PWD"
    [ "$status" -eq 0 ]
	run grephs test_cmd
    [ "$status" -eq 0 ]
}
