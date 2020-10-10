#!/usr/bin/env bash

root_dir=$(pwd)

initial_setup() {
    echo "Starting setup"
    # echo "$root_dir"
    mkdir -p ~/lib
}

setup_nodes(){
  for node in "${nodes[@]}"
  do
    ssh-copy-id -i ~/.ssh/id_rsa.pub "$node"
    echo "$node"
  done

}

if [[ $1 = "--nodes" ]]
then
  echo "Setting up a node cluster of size $2"
  preserve -# $2 -t 00:01:00
  sleep 1
  declare -a nodes=(`preserve -llist | grep $USER | awk '{for (i=9; i<NF; i++) printf $i " "; if (NF >= 9+$2) printf $NF;}'`)
  echo "${nodes[@]}"
  printf "\n"

  echo "Configuring nodes. Please enter your password."
  ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
  setup_nodes
  
  exit 0
fi

if [[ $1 = "--local" ]]
then
  echo "Setting up a node cluster of size 1"

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
