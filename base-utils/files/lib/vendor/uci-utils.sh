#!/bin/sh

uci_sections() {
	[ $# -lt 2 ] && return 1

	local CONFIG=$1
	shift
	local TYPE=$1

	/sbin/uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} show "$CONFIG" | awk -F'[.=]' '{if ($3 == "'"$TYPE"'") {print $2};}'
}

uci_section_options() {
	[ $# -lt 2 ] && return 1

	local PACKAGE="$1"
	local CONFIG="$2"

	/sbin/uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} show "$PACKAGE.$CONFIG" | awk -F'[.=]' '{if (NR!=1) {printf("%s\n",$3)};}'
}

uci_sections_from_option_value() {
	[ $# -lt 2 ] && return 1

	local OPTION="$1"
	local VALUE="'$2'"
	local PACKAGE="$3"

	/sbin/uci -p /var/state ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} show "$PACKAGE" | awk -F[.=] '{if (($3 == "'"$OPTION"'") && ($4 ~ "'"$VALUE"'")) {print $2};}' | sort -u
}

uci_sections_from_value() {
	[ $# -lt 1 ] && return 1

	local VALUE="'$1'"
	local PACKAGE="$2"

	/sbin/uci -p /var/state ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} show "$PACKAGE" | awk -F[.=] '{if ($4 ~ "'"$VALUE"'") {print $2};}' | sort -u
}

uci_option_references() {
	[ $# -lt 2 ] && return 1

	local OPTION="$1"
	local VALUE="'$2'"
	local PACKAGE="$3"

	/sbin/uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} show "$PACKAGE" | awk -F'[.=]' '{if ((NR!=1) && ($3 ~ "'"_ref_$OPTION"'$") && ($4 ~ "'"$VALUE"'")) {printf("%s.%s.%s\n", $1, $2, $3)};}' | sort -u
}

uci_section_idx() {
	[ $# -lt 3 ] && return 1

	local PACKAGE=$1
	local TYPE=$2
	local SECTION=$3
	local sections

	sections=$(uci_sections "$CONFIG" "$TYPE")
	get_index sections "$SECTION"
}

run_uci_cmd() {
	[ $# -lt 4 ] && return 1

	local PACKAGE="$1"
	shift
	local SECTION="$1"
	shift
	local OPTION="$1"
	shift
	local VALUE="$*"
	local data

	data=$(uci_get "$PACKAGE" "$SECTION" "$OPTION")
	[ "$data" == "$VALUE" ] && return 1

	uci_set "$PACKAGE" "$SECTION" "$OPTION" "$VALUE"
}

add_uci_cmd() {
	[ $# -lt 4 ] && return 1

	local PACKAGE=$1
	shift
	local SECTION=$1
	shift
	local OPTION=$1
	shift
	local VALUE="$*"

	uci_set "$PACKAGE" "$SECTION" "$OPTION" "$VALUE"
}

run_uci_cmd_list() {
	[ $# -lt 4 ] && return 1

	local PACKAGE=$1
	shift
	local SECTION=$1
	shift
	local OPTION=$1
	shift
	local NVALUES="$*"

	local flag=1
	local OVALUES v o

	OVALUES=$(uci_get "$PACKAGE" "$SECTION" "$OPTION")

	for v in $NVALUES; do
		if ! echo "$OVALUES" | grep -q -w "$v"; then
			uci_add_list "$PACKAGE" "$SECTION" "$OPTION" "$v" && flag=0
		fi
	done

	for o in $OVALUES; do
		if ! echo "$NVALUES" | grep -q -w "$o"; then
			uci_remove_list "$PACKAGE" "$SECTION" "$OPTION" "$o" && flag=0
		fi
	done

	return "$flag"
}

uci_init() {
	[ $# -ne 1 ] && return 1

	local PACKAGE="$1"
	local CONFIG_DIR="/etc/config"
	local CONFIG="$CONFIG_DIR/$PACKAGE"

	[ ! -d "$CONFIG_DIR" ] && mkdir -p "$CONFIG_DIR"
	[ ! -f "$CONFIG" ] && touch "$CONFIG"
}
