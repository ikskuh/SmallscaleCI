# Job Directory

Each folder in this directory contains a job description.

Jobs require at least two files, one is `jobinfo.sh`, the other one is a runner-dependent init file that will contain the task logic and will be executed inside the virtual machine.

Files used by the host are:

## `jobinfo.sh`

`jobinfo.sh` is a script that is sourced by `execute-single-job.sh` to obtain a variable called `RUNNER`. This variable will need to point to directory in `${ROOT}/runners`.

**Example:**
```sh
# Runs a job on ubuntu20.04
RUNNER=ubuntu20.04
```

## `postprocess.sh`

`postprocess.sh` is run after a job completed successfully and can be used to upload artifacts placed in the `${CI_OUTPUT}` folder.

**Example:**
```sh
#!/bin/bash

echo "Upload all artifacts to a remote location:"
for file in $(ls ${CI_OUTPUT}); do
	scp "${file}" ci@example.com:/opt/service/nightly/
done
```