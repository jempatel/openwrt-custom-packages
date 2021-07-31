#!/bin/sh

MAX_INPUT_JSON_DEPTH=5

dump_success() {
	local data="$*"
	echo "{ \"result\" : \"success\" ${data:+, \"data\" : $data } }"
	exit 0
}

dump_fail() {
	local data="$*"
	echo "{ \"result\" : \"fail\" ${data:+, \"data\" : $data } }"
	exit 1
}

read_request_data() {
	read -r input
	export input
}

get_request_data() {
	echo "$input"
}

add_subcommand() {
	export subcommands
	append subcommands "$1"
}

get_subcommands() {
	echo "$subcommands"
}

load_request_data() {
	local data

	data="$(get_request_data)"

	JSON_PREFIX="$(__program__)"
	json_load "$data"
	unset JSON_PREFIX
}

get_request_param() {
	local data len _value
	export _json_no_warning JSON_PREFIX

	len=$#
	len="$((len - 1))"

	[ $len -gt $MAX_INPUT_JSON_DEPTH ] && return 1

	_json_no_warning=1
	JSON_PREFIX="$(__program__)"

	if [ "$len" -eq 1 ]; then
		json_get_var _value "$1"
	else
		i=1

		while [ $i -lt $len ]; do
			json_select "$1"
			((i++))
			shift
		done

		json_is_a "$1" object && return

		if json_is_a "$1" array; then
			json_get_values _value "$1"
		else
			json_get_var _value "$1"
		fi

		while [ "$i" -ne 1 ]; do
			json_select ..
			((i--))
		done
	fi

	echo "$_value"

	unset _json_no_warning JSON_PREFIX
}

json_help_object() {
	[ $# -ne 1 ] && return 1

	json_add_object "$1"
	json_close_object
}

list_methods() {
	local cmds
	cmds="$(get_subcommands)"

	json_init

	for cmd in $cmds; do
		fname="json_help_${cmd}"
		if __function__ "$fname"; then
			json_add_object "$cmd"
			eval "$fname"
			json_close_object
		else
			json_help_object "$cmd"
		fi
	done

	json_dump
}

wait_for_rpc_plugin() {
	[ $# -lt 1 ] && return

	local timeout counter c_plugin plugin
	plugin="$1"
	timeout="${2:-30}"
	counter=0

	while [ "$timeout" -gt "$counter" ]; do
		sleep 1
		c_plugin="$(ubus list "$plugin" 2> /dev/null)"
		[ "$c_plugin" == "$plugin" ] && break
		((counter++))
	done
}

call_method() {
	[ $# -lt 1 ] && return 1

	local func_name=$1
	shift

	if ! __function__ "$func_name"; then
		echo "{ \"error\" : \"no such method: $func_name\" }"
		return 1
	fi

	$func_name "$@"
}

init_rpcd() {
	case "$1" in
		list)
			list_methods
			;;
		call)
			read_request_data
			load_request_data
			shift
			call_method "$@"
			;;
	esac
}
