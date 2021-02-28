# Host Directory

This directoy contains all binaries for the CI.

## `daemon.sh`

The *Smallscale CI* daemon. Will poll the redis list `smallscale:task-queue` for jobs and will execute them via `execute-single-job.sh`

## `execute-single-job.sh`

The task runner. Will take a single argument which is a job name (a folder in `${ROOT}/jobs`) which will then be executed.

Task execution follows this sketch:

1. Create unique job id and the `${OUTPUT}` directory
2. Spawn a `ftz` server that will host the `${JOB}` directory for `get` operations and the `${OUTPUT}` directory for `put` operations.
3. Create a temporary copy-on-write volume based on `${RUNNER}/volume.xml`
4. Spawn a temporary virtual machine based on `${RUNNER}/vm.xml`
5. Wait until the virtual machine is done
6. Check `${OUTPUT}/result` if the contents are `success`
  1. If successful and `${JOB}/postprocess.sh` exists, execute it.

## `enqueu-task.sh`

Enqueues a task into the command queue. The task name is passed as the first argument.

## `ftz-linux-x86_64`

The [`ftz`](https://github.com/MasterQ32/ftz/) implementation for the host.

## `smallscale.service`

A *systemd* service file that can be used to execute `daemon.sh` with systemd. Adjust this file to your system and copy to to `/etc/systemd/system/`, then run `systemd enable smallscale; systemd start smallscale` 