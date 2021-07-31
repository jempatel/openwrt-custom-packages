#!/bin/sh

ETH_IFNAME="eth1"
WLAN_IFNAME="wlan0"

get_router_id() {
	local ifname="$1"
	ifname="${ifname:-$ETH_IFNAME}"
	[ ! -d "/sys/class/net/$ifname" ] && return 1

	cat "/sys/class/net/$ifname/address"
}

get_wlan_id() {
	local ifname="$1"
	ifname="${ifname:-$WLAN_IFNAME}"

	[ ! -d "/sys/class/net/$ifname" ] && return 1

	cat "/sys/class/net/$ifname/address"
}

get_uptime() {
	awk -F. '{print $1}' /proc/uptime
}

get_timestamp() {
	date +%s
}

get_machine_id() {
	local mac

	mac=$(get_router_id)
	uuidgen -m -n @oid --name "$mac"
}

get_cpu_count() {
	grep ^processor /proc/cpuinfo
}

get_nic_count() {
	ls -1 /sys/class/net/ | grep -c '^eth\|^lan\|^wan'
}

get_cpu_usage() {
	awk '/^cpu/{usage=($2+$4)*100/($2+$4+$5)} END {print usage}' /proc/stat
}

get_memory_usage() {
	free | awk '/Mem/{print $3/$2 * 100.0}'
}

get_connected_clients() {
	local ifname="$1"
	ifname="${ifname:-$WLAN_IFNAME}"
	[ ! -d "/sys/class/net/$ifname" ] && return 1
	iw dev "$ifname" station dump | awk 'BEGIN {count = 0;} /^Station/{count++;} END {printf("%d", count)}'
}

add_conf_to_file() {
	[ $# -lt 3 ] && return 1

	local _id="$1"
	local id="# $1"
	shift
	local config_file=$1
	shift
	local record="$* $id"
	sep="${sep:-/}"

	if grep -q "$id" "$config_file" > /dev/null 2>&1; then
		if [ "$force_conf" == "1" ]; then
			remove_conf_from_file "$_id" "$config_file"
			echo "$record" >> "$config_file"
			chmod 644 "$config_file"
		else
			sed -i -e "s${sep}.*$id${sep}$record${sep}g" "$config_file" || return 1
		fi
	else
		echo "$record" >> "$config_file"
		chmod 644 "$config_file"
	fi
}

append_conf_to_file() {
	[ $# -lt 3 ] && return 1

	local id="# $1"
	shift
	local config_file=$1
	shift
	local record="$* $id"

	echo "$record" >> "$config_file"
}

remove_conf_from_file() {
	[ $# -lt 2 ] && return 1

	local id="# $1"
	shift
	local config_file=$1
	shift

	if grep -q "$id" "$config_file" > /dev/null 2>&1; then
		sed -i -e '/ '"$id"'$/d' "$config_file" || return 1
	fi

	return 0
}

curl_request() {
	export curl_http_rcode curl_error_code
	local max_time=${__curl_max_time__:-300}
	local connect_timeout=${__curl_timeout__:-30}
	local retry=${__curl_retry__:-3}

	# shellcheck disable=SC1083
	curl_http_rcode=$(curl -w %{http_code} --retry "${retry}" --connect-timeout "${connect_timeout}" --max-time "${max_time}" -k "$@" 2> /dev/null)
	curl_error_code=$?
}

curl_download() {
	[ $# -lt 2 ] && return 1

	local url=$1
	local target=$2

	log_info "Downloading from ${url} to ${target}"
	curl_request -L "${url}" -o "${target}"

	if [ $curl_error_code -eq 0 ] && [ "$curl_http_rcode" == "200" ]; then
		unset curl_error_code curl_http_rcode
		return 0
	else
		unset curl_error_code curl_http_rcode
		return 1
	fi
}

api_request() {
	local type resp_file bodyFile

	type=$1
	shift
	resp_file="/tmp/last_${type}_response.json"
	bodyFile="$(mktemp)"

	curl_request -o "$bodyFile" -H "Content-Type: application/json" "$@"

	if [ "$curl_error_code" -eq 0 ] && [ -s "$bodyFile" ]; then
		if [ "$array_bool" == "yes" ]; then
			jsonfilter -e '@[*]' < "$bodyFile" > "${bodyFile}.tmp"
			mv "${bodyFile}.tmp" "${bodyFile}"
		fi

		json_load_file "$bodyFile"
	else
		json_init
	fi

	json_add_int httpCode "$curl_http_rcode"
	json_add_int errorCode "$curl_error_code"

	json_dump > "$resp_file"

	rm -f "$bodyFile"

	[ "$curl_error_code" -ne 0 ] && log_err "$type (error=${curl_error_code})"

	if [ "$curl_http_rcode" -lt 200 ] || [ "$curl_http_rcode" -ge 500 ]; then
		log_err "$type http error: $curl_http_rcode"
	fi

	if [ "$curl_http_rcode" -eq 304 ]; then
		unset curl_error_code curl_http_rcode
		return 0
	fi

	if [ "$curl_http_rcode" -eq 403 ]; then
		unset curl_error_code curl_http_rcode
		return 1
	fi

	unset curl_error_code curl_http_rcode
	return 0
}
