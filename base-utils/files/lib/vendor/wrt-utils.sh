#!/bin/sh

get_model() {
	model=$(cat /tmp/sysinfo/board_name)
	echo "${model##*,}"
}

get_hostname() {
	uci_get system "@system[0]" hostname
}

default_hostname() {
	hostname="$(get_hostname)"
	[ "$hostname" == "OpenWrt" ]
}

get_ssid() {
	local id="${1:-0}"
	uci_get wireless "@wifi-iface[$id]" ssid
}

get_firmware_version() {
	# shellcheck source=/dev/null
	. /etc/os-release
	echo "$VERSION_ID"
}

get_vendor() {
	# shellcheck source=/dev/null
	. /etc/os-release
	echo "$ID"
}
