# Runner Directory

This directory contains one folder per CI Runner. Each runner declares a virtual machine that is executed

## Creating a runner

1. Create a new virtual machine with libvirt.
2. Prepare the virtual machine with the help of the `system-setup` folder of the two example runners (or just to your own liking!)
3. Dump the virtual machine with `libvirt dumpxml ${MY_VM_NAME}` and save it to `${ROOT}/${MY_RUNNER}/vm.xml`
4. Copy `volume.xml` from below to `${ROOT}/${MY_RUNNER}/volume.xml`
5. Adjust `file` for `<backingStore>` in both `vm.xml` and `volume.xml` to the path of the virtual machine created before.

## `vm.xml`

This file declares a virtual machine in *libvirt* format that is executed as the runner. Note that this vm declaration requires to replace the original `<disk>` declaration that was created by *libvirt* with this:

```xml
  ...
   <disk type='file' device='disk'>
    <!-- Set `file` to the path of your `default` pool. This should usually be fine on *all* systems -->
    <source file="/var/lib/libvirt/images/transient-volume.qcow2"/>
    <backingStore type="file">
      <format type="qcow2"/>
      <!-- Set this `file` to the path of your original VM image. -->
      <source file="/media/backup/virtual-machines/ubuntu20.04-base.qcow2"/>
      <backingStore/>
    </backingStore>
  </disk>
  ...
```

## `volume.xml`

This file declares a *libvirt* volume which we use to temporarily store the CI runner state. It will be deleted after the runner is finished.

```xml
<volume>
  <!-- This is the name of virtual machine disk which provides the copy-on-write features for the CI -->
  <name>transient-volume.qcow2</name>
  <capacity>85899345920</capacity>
  <allocation>0</allocation>
  <target>
    <format type="qcow2"/>
  </target>
  <backingStore>
    <format type='qcow2'/>
    <!-- This is the same path as in `vm.xml` which points to the original VM image. -->
    <path>/media/backup/virtual-machines/ubuntu20.04-base.qcow2</path>
  </backingStore>
</volume>


```