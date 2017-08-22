default_command() {
  if [ -z "$1" ]; then
    command=$DEFAULT_COMMAND
  else
    command=$@
  fi

  echo $command
}

file_lookup() {
  if [ ! -e $2 ]; then
    for path in $HOME/bootstrap/$2 /sdcard/bootstrap/$2; do
      [ -e $path ] && eval "$1=$path"
    done
  fi
}
