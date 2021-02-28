#!/bin/bash

ROOT="$(dirname "$(dirname "$(realpath "$0")")")"

set -e

which redis-cli > /dev/null

while true; do
	CURRENT_JOB=$(redis-cli  BLPOP smallscale:task-queue 0 | tail -n1)
	echo "${ROOT}/jobs/${CURRENT_JOB}"
	if test -d "${ROOT}/jobs/${CURRENT_JOB}" ; then
		echo "Start task '${CURRENT_JOB}'"
		redis-cli INCR "smallscale:task:${CURRENT_JOB}:total"
		"${ROOT}/host/execute-single-job.sh" "${CURRENT_JOB}" && redis-cli INCR "smallscale:task:demo:success" || echo "Failed to run task!" # ignore errors here
	else
		echo "Task '${CURRENT_JOB}' not found!"
	fi
done
