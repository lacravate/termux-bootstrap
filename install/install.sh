[ -z "$(which rsync)" ] && pkg install rsync

install_dir=$(echo $PATH|tr ':' "\n"|grep com.termux|sort|head -1)
executable_dir=$(dirname $0)

for file in $(ls $executable_dir/* | grep -v install.sh); do
  cp $file $install_dir
done
