# Smallscale CI

A *simple* and *small* CI solution.

## Packages Required

- `bash`
- `libvirt`
- `qemu`
- `redis`
- [`ftz`](https://github.com/MasterQ32/ftz)
- cron (for nightlies/scheduled builds)
- way to run services (systemd)

## Architecture

> Insert missing architecture image.

### Daemon


### Task Queue
The task queue is implemented with Redis and is just a simple list you can append new  tasks to:

```redis
RPUSH smallscale:task-queue qemo
```

### Enqueue Script

### `libvirt` Runners

## File System Hierarchy

