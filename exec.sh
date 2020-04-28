# shellcheck shell=sh
_exec_get_uid() {
	passwd="$POCKER_GUESTS/$2/rootfs/etc/passwd"

	[ ! -f "$passwd" ] && echo 0 && return

	awk -F ':' "\$1 == \"$1\" {print \$3}" \
		"$POCKER_GUESTS/$2/rootfs/etc/passwd"

}

_exec_usage() {
	echo '"pocker exec" requires at least 2 arguments.

Usage:  pocker exec [OPTIONS] ROOTFS COMMAND [ARG...]

Run a command in an existing rootfs

Options:
	--gui      Use when a GUI is going to be run
	--install  Use when packages need to be installed
	--user     Username'
	exit 1
}

_is_opt() {
	case x"$1" in
	x-*) return 0 ;;
	*) return 1 ;;
	esac
}

_exec() {
	[ "$#" -lt 2 ] && _exec_usage

	_user=root
	_type='-r'

	c="$1" && shift
	while _is_opt "$c"; do
		case x"$c" in
		x--gui) _gui='-b /proc -b /dev' ;;
		x--user) _user="$1" && shift ;;
		x--install) _type='-S' ;;
		esac

		c="$1" && shift
	done

	_guest_name="$c"

	_id="$(_exec_get_uid "$_user" "$_guest_name")"

	[ -z "$_id" ] &&
		_log_fatal "could not find user '$_user' in $_guest_name"

	[ ! -d "$POCKER_GUESTS/$_guest_name" ] &&
		echo "Error: No such container: $_guest_name" >&2 && exit 1

	[ "$#" -eq 0 ] && _usage

	cat <<'EOF' >&2

Tip: to get the proper prompt, always run sh/bash with the '-l' option

EOF

	# shellcheck disable=SC2086
	env -i proot $_gui -w / $_type "$POCKER_GUESTS/$_guest_name/rootfs" -i "$_id" "$@"
}
