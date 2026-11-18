#!/bin/sh
# Container entrypoint: fills in credentials before starting webdav.
#
# - WEBDAV_USERNAME defaults to "admin".
# - If WEBDAV_PASSWORD is not set, a random password is generated on the first
#   start, saved to $WEBDAV_STATE_DIR/password and printed to the log. Later
#   starts reuse the saved password. The state directory must not be inside
#   the served directory, or the password file would be readable over WebDAV.
set -eu

state_dir="${WEBDAV_STATE_DIR:-/state}"
password_file="$state_dir/password"

export WEBDAV_USERNAME="${WEBDAV_USERNAME:-admin}"

if [ -z "${WEBDAV_PASSWORD:-}" ]; then
	if [ -s "$password_file" ]; then
		WEBDAV_PASSWORD="$(cat "$password_file")"
		echo "webdav: using the saved password from $password_file (set WEBDAV_PASSWORD to override)"
	else
		mkdir -p "$state_dir"
		umask 077
		WEBDAV_PASSWORD="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 24)"
		printf '%s' "$WEBDAV_PASSWORD" >"$password_file"
		echo "=============================================================="
		echo " webdav: generated login on first start"
		echo "   username: $WEBDAV_USERNAME"
		echo "   password: $WEBDAV_PASSWORD"
		echo " Saved to $password_file. Delete that file to generate a new"
		echo " one, or set WEBDAV_PASSWORD to choose your own."
		echo "=============================================================="
	fi
	export WEBDAV_PASSWORD
fi

exec webdav "$@"
