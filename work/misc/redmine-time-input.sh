# comment
cat >/dev/null <<EOF
/*
<select name="time_entry[activity_id]" id="time_entry_activity_id"><option value="">--- 選んでください ---</option>
<option value="8">Design</option>
<option value="9">Implementation</option>
<option value="11">Design Review</option>
<option value="10">Code Review</option>
<option value="21">Test requirements analysis</option>
<option value="18">Test design, implementation</option>
<option value="19">Review for test suite</option>
<option value="20">Testing</option>
<option value="22">Release</option></select>
*/
EOF
function redmine_fill_time_entry {
	#javascript: time_entry_spent_on 2020-03-18
	cat <<EOF
(function() {
    \$("#time_entry_hours").val($1);
    \$("#time_entry_comments").val("$2");
    \$("#time_entry_activity_id").val($3);
})()
EOF
}

redmine_fill_time_entry "$@"
