set_options() {
  name=$1
  root=$2
  command=$3
}

define_image_root() {
  image=$root
  root=$TERMUX_BOOTSTRAP_INSTALL_DIR/root/$name/img
  printf "$root"
}

mount_image_root() {
  define_image_root > /dev/null 2>&1

  if [ ! -d $root ] || [ -z "$(ls $root)" ]; then
    mkdir -p $root

    loop="/dev/block/bootstrap/$name"
    [ -e $loop ] || create_loop_device $loop

    losetup $loop $image > /dev/null 2>&1
    type=$(blkid -o value -s TYPE $loop)
    mount -t $type $loop $root
  fi
}

create_loop_device() {
  mkdir -p /dev/block/bootstrap
  id=$(expr 100 + $(ls /dev/block/bootstrap/|wc -l))
  mknod $1 b 7 $id
}

define_ram_root() {
  fs=$root
  root=$TERMUX_BOOTSTRAP_INSTALL_DIR/root/$name/ram
  printf "$root"
}

mount_ramfs_root() {
  mkdir -p $root
  mount -t tmpfs tmpfs $root
}

finalize_root() {
  for dir in etc home media mnt opt run root srv tmp var; do
    mkdir -p $root/$dir
  done
}

bind_fs() {
  for dir in etc home root var; do
    mount -o bind $fs/$dir $root/$dir
  done
}

sync_root() {
  for dir in bin boot lib sbin usr; do
    rsync -a $fs/$dir $root
  done
}

ram_fs() {
  define_ram_root > /dev/null 2>&1

  if [ ! -d $root ] || [ -z "$(ls $root)" ]; then
    mount_ramfs_root
    finalize_root
    bind_fs
    sync_root
  fi
}

bind_device() {
  for f in dev dev/pts proc sys sdcard; do
    mkdir -p $root/$f
    mount -o bind /$f $root/$f
  done
}

unbind_device() {
  for mount in $(root_mountpoints|tac); do
    umount $mount
  done
}

root_mountpoints() {
  cat /proc/*/mounts 2>/dev/null|awk '{print $2}'|sort|uniq|grep $root
}

has_processes() {
  ls -lad /proc/*/root 2>/dev/null|grep $root
}

if [ ! -z "$1" ]; then
  set_options $@
fi

if [ ! -z "$command" ]; then
  $command
fi
