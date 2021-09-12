#!/bin/sh

__program__() {
	basename "$0"
}

__function__() {
	type "$1" > /dev/null 2>&1
}

log() {
	priority=$1
	shift
	logger -t "$(__program__)" -p "$priority" "$@"
}

log_info() {
	log "info" "$@"
}

log_err() {
	log "error" "$@"
}

log_warn() {
	log "warn" "$@"
}

log_crit() {
	log "crit" "$@"
}

die() {
	log_err "FATAL: $*"
	exit 1
}

do_run() {
	local verbose="${__verbose__:-0}"
	local cmd

	[ "$verbose" != "1" ] && cmd="$* 2>/dev/null" || cmd="$*"

	if ! $cmd; then
		log_err "\"$cmd\""
		return $?
	fi
}

call_function() {
	[ $# -lt 1 ] && return 1

	local method=$1
	shift

	__function__ "$method" || return 1
	$method "$@"
}

get_lockfile() {
	[ -z "${__lockfile__}" ] && __lockfile__="/var/lock/_shfunc_$(__program__).lock"
	echo "${__lockfile__}"
}

acquire_lock() {
	local lockfile

	lockfile="$(get_lockfile)"
	echo "$$" > "${lockfile}"
}

release_lock() {
	local lockfile

	lockfile="$(get_lockfile)"

	__function__ cleanup && cleanup
	[ -f "${lockfile}" ] && rm -f "${lockfile}"
}

locked() {
	local lockfile

	lockfile="$(get_lockfile)"
	[ -n "${lockfile}" ] && [ -f "${lockfile}" ]
}

init_signals() {
	trap release_lock INT TERM EXIT
}

init_lock_signals() {
	locked && return 1
	init_signals
	acquire_lock
}

get_index() {
	[ $# -lt 2 ] && return 1

	local var=$1
	local str=$2
	local ele
	local i=1

	eval "val=\"\${$var}\""

	for ele in ${val}; do
		if [[ "$ele" = "$str" ]]; then
			echo "$i"
			return 0
		fi
		((i++))
	done

	return 1
}
