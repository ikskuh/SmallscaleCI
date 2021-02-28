#!/bin/bash

set -eo pipefail

function die()
{
	echo "$@" >&2
	exit 1
}

ROOT=/media/backup/ci
JOB="$1"

if test "${JOB}" == ""; then
	die "Requires the job name as argument 1"
fi

JOB_ROOT="${ROOT}/jobs/${JOB}"

if ! test -d "${JOB_ROOT}"; then
	die "Job ${JOB} does not exist!" 
fi

source "${JOB_ROOT}/jobinfo.sh"

if test "${RUNNER}" == ""; then
	die "\$RUNNER is not defined!"
fi

RUNNER_ROOT="${ROOT}/runners/${RUNNER}"

if ! test -d "${RUNNER_ROOT}"; then
	die "Runner ${RUNNER} does not exist!" 
fi

JOB_INSTANCE_ID="$(date "+%Y%m%d-%H%M%S-%3N")"

JOB_INSTANCE_ROOT="${ROOT}/results/${JOB}/${JOB_INSTANCE_ID}"

if test -d "${JOB_INSTANCE_ROOT}"; then
	die "The task ${JOB_INSTANCE_ID} already exists. This is a serious failure!"
fi
mkdir -p "${JOB_INSTANCE_ROOT}/artifacts"

function virt()
{
	virsh -c qemu:///system "$@"
}

echo "Start ${JOB} on ${RUNNER}"

date > "${JOB_INSTANCE_ROOT}/start"

echo "Create volume..."

virt vol-create \
	--pool default \
	--file "${RUNNER_ROOT}/volume.xml"

virt vol-info --pool default transient-volume.qcow2

echo "Start FTZ service"

"${ROOT}/host/ftz-linux-x86_64" host \
	--get-dir "${JOB_ROOT}" \
	--put-dir "${JOB_INSTANCE_ROOT}/artifacts" &
FTZ_PID="$!"

{(
	set -eo pipefail
	echo "Create virtual machine..."
	virt create --file "${RUNNER_ROOT}/vm.xml" || exit 1
	
	while virt domstate ci > /dev/null 2> /dev/null; do
		echo "is alive"
		sleep 5s
	done
	
	echo "Task done."
)} || echo "CI failed!"

date > "${JOB_INSTANCE_ROOT}/end"

echo "Destroy virtual machine"

# destroy the virtual machine, or if this fails, just
# ignore it.
virt destroy ci 2> /dev/null || true

echo "Destroy volume"

virt vol-delete \
	--pool default \
	--vol transient-volume.qcow2

echo "Shut down FTZ"
kill "${FTZ_PID}"

mv "${JOB_INSTANCE_ROOT}/artifacts/result" "${JOB_INSTANCE_ROOT}/result" || echo "failure" > "${JOB_INSTANCE_ROOT}/result"

RESULT="$(echo $(cat "${JOB_INSTANCE_ROOT}/result"))"

if test "${RESULT}" == "success"; then
	if test -x "${JOB_ROOT}/postprocess.sh"; then
		export CI_OUTPUT="${JOB_INSTANCE_ROOT}/artifacts"
		"${JOB_ROOT}/postprocess.sh"
	fi
	echo "CI run successful!"
else
	echo "Failed to run CI!"
fi

echo "Link latest CI run"
rm -f "${ROOT}/results/${JOB}/latest"
ln -s "${JOB_INSTANCE_ROOT}" "${ROOT}/results/${JOB}/latest"
