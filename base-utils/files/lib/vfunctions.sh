#!/bin/sh

include_vendor()
{
	local vendor

	# shellcheck source=/dev/null
	. /lib/functions.sh
	# shellcheck source=/dev/null
	. /usr/share/libubox/jshn.sh

	include /lib/vendor

	vendor=$(get_vendor)
	[ -n "$vendor" ] && [ -d "/lib/vendor/$vendor" ] && include /lib/vendor/"$vendor"
}
