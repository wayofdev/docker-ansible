#!/usr/bin/env bash

set -eu
set -o pipefail

USE_NON_ROOT=0

update_uid_gid() {
	local user="${1}"
	local group="${2}"
	local uid="${3}"
	local gid="${4}"

    echo "[INFO] Adjusting local user with uid: ${uid} and gid: ${gid}"

	# Remove previous user/group
	if ! deluser "${user}"; then
		>&2 echo "[ERROR] Failed to delete user: ${user}"
		exit 1
	fi

	# Add new user/group
	if ! addgroup -g "${gid}" "${group}"; then
		>&2 echo "[ERROR] Failed to add group ${group} (gid:${gid})"
		exit 1
	fi
	if ! adduser -h /home/ansible -s /bin/bash -G "${group}" -D -u "${uid}" "${user}"; then
		>&2 echo "[ERROR] Failed to add user ${user} (uid:${uid})"
		exit 1
	fi
}

# Run with root or ansible user?
if env | grep -q '^USER='; then
	if [ "${USER}" = "ansible" ]; then
		echo "[INFO] Running container with user 'ansible'"
		USE_NON_ROOT=1
	else
		>&2 echo "[ERROR] \$USER can only be set to 'ansible'. If you want to run as root, omit the env var."
		exit 1
	fi
fi

# Gather new UID/GID
if env | grep -q '^UID='; then
	# Change UID
	MY_UID="$( env | grep '^UID=' | sed 's/^UID=//g' )"
	echo "[INFO] Changing UID to ${MY_UID}"
	# Change GID (maybe)
	if env | grep -q '^GID='; then
		echo "[INFO] Changing GID to ${MY_GID}"
		MY_GID="$( env | grep '^GID=' | sed 's/^GID=//g' )"
	fi
elif env | grep -q '^GID='; then
	# Change GID
	MY_GID="$( env | grep '^GID=' | sed 's/^GID=//g' )"
	echo "[INFO] Changing GID to ${MY_GID}"
fi

# Entrypoint Configuration
if [ "${USE_NON_ROOT}" = "1" ]; then
	update_uid_gid "${MY_USER}" "${MY_GROUP}" "${MY_UID}" "${MY_GID}"
	echo "[INFO] ansible> ${*}"
	exec su "${MY_USER}" -c "${*}"
else
	echo "[INFO] root> ${*}"
	exec "${@}"
fi
