default_command() {
  if [ -z "$1" ]; then
    command=$DEFAULT_COMMAND
  else
    command=$@
  fi

  echo $command
}
