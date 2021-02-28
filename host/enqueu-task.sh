#!/bin/bash

ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
TASK_ID="$1"

if test "${TASK_ID}" == ""; then
	echo "$(basename $0) [task-id]" 1>&2
	exit 1
fi

if ! test -d "${ROOT}/jobs/${TASK_ID}"; then
	echo "The task '${TASK_ID}' does not exist!" 1>&2
	exit 1
fi

redis-cli RPUSH "smallscale:task-queue" "${TASK_ID}"
