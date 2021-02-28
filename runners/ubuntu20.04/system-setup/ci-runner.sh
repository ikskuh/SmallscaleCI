#!/bin/bash

ROOT="/home/user/ci"

function die()
{
	echo "$@" 1>&2
	gnome-terminal --wait --title "Smallscale CI Rescue Shell"
}

export "PATH=${ROOT}/bin:$PATH"

rm -rf "${ROOT}/work" || die "failed to cleanup previous work directory!"
mkdir -p "${ROOT}/work" || die "failed to create work directory!"

rm -rf "${ROOT}/artifacts" || die "failed to cleanup previous artifacts directory!"
mkdir -p "${ROOT}/artifacts" || die "failed to create artifacts directory!"

ftz get -o "${ROOT}/work/task.sh" ftz://192.168.122.1/task.sh || die "failed to download task.sh"
chmod +x "${ROOT}/work/task.sh"

pushd "${ROOT}/work" >/dev/null || die "failed to change into work dir!"

export CI_ROOT="${ROOT}/work"
export CI_OUTPUT="${ROOT}/artifacts"

echo "failure" > "${ROOT}/result"
"${ROOT}/work/task.sh" && echo "success" > "${ROOT}/result"

popd >/dev/null

for file in $(find "${ROOT}/artifacts" -maxdepth 1 -type f); do
	ftz put "${file}" "ftz://192.168.122.1/$(basename ${file})" || die "failed to upload artifact!"
done

ftz put "${ROOT}/result" ftz://192.168.122.1/result || die "failed to upload result!"

poweroff
