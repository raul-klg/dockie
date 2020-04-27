# shellcheck shell=sh
_bootstrap_error() {
	echo "Error response: pull access denied for $1" >&2
	rm -rf "$2"
	exit 1
}

_bootstrap() {
	[ ! -d "$POCKER_IMAGES/$1" ] && sh "$POCKER_LIBS/pull.sh" "$1"

	mkdir -p "$2"/rootfs


	date '+%Y-%m-%d %H:%M:%S' >"$2/date"
	printf '%s%s\n' "$*" "$(date)" | sha1sum | cut -c -12 >"$2/id"
	echo "$1" >"$2/image"

	cd "$2/rootfs" || exit 1

	sh "$POCKER_IMAGES/$1/bootstrap.sh" || true
	echo "export PS1='\u@$(basename "$2"):\w\\$ '" >>etc/profile
	rm etc/resolv.conf
	cat /etc/resolv.conf etc/resolv.conf
}