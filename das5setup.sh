#!/usr/bin/env bash

root_dir=$(pwd)

initial_setup() {
    echo "Starting setup"
    # echo "$root_dir"
    mkdir -p ~/lib
}

if [[ $1 = "-nodes" ]]
then
  echo $2

  # preserve -# $2 -t 00:15:00
  # preserve -llist | grep $USER |
  exit 0
fi

# start script
# initial_setup
#start_master () {
#    ~/lib/bin/spark/sbin/start-master.sh
#}
#
#start_worker () {
#    ~/lib/bin/spark/sbin/start-slave.sh "${*:2}"
#}
#
#start_workers () {
#    ~/.local/bin/spark/sbin/start-slaves.sh
#}
#
#start () {
#    ~/.local/bin/spark/sbin/start-master.sh
#    ~/.local/bin/spark/sbin/start-slaves.sh
#}
#
#stop_all () {
#    ~/.local/bin/spark/sbin/stop-all.sh
#}
