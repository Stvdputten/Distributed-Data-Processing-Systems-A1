#!/usr/bin/env bash

root_dir=$(pwd)

if [ -z "$SPARK_HOME" ]
then 
  SPARK_HOME=~/lib/spark
fi

if [ -z "$HADOOP_HOME" ]
then 
  HADOOP_HOME=~/lib/hadoop
fi

initial_setup() {
    echo "Starting setup"
    # echo "$root_dir"
    mkdir -p ~/lib
}

# ssh keys to all nodes
setup_nodes(){
  for node in "${nodes[@]}"
  do
    ssh-copy-id -i ~/.ssh/id_rsa.pub "$node"
    echo "$node"
  done

}

# used on the das5
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
  for node in "${nodes[@]}"
  do
    ssh node 'cd $SPARK_HOME && sbin/start-slave.sh spark://fs1.cm.cluster:7082'
    echo "$node"
  done
  
  exit 0
fi

# Mostly for local debugging
if [[ $1 = "--local" ]]
then
  echo "Setting up a node cluster of size 1"
  echo "Setting up Hadoop & Spark"
  #initial_setup
  $SPARK_HOME/sbin/start-all.sh 
  $HADOOP_HOME/sbin/start-all.sh 

  exit 0
fi

stop_all () {
    $SPARK_HOME/sbin/stop-all.sh
    $HADOOP_HOME/sbin/stop-all.sh
}

if [[ $1 = "--stop-all" ]]
then
  echo "Stopping all"
  stop_all
  exit 0
fi

start_all () {
    $SPARK_HOME/sbin/start_all.sh
    $HADOOP_HOME/sbin/start_all.sh
}

if [[ $1 = "--start-all" ]]
then
  echo "Stopping all"
  start_all
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

