#!/usr/bin/env bash
# Written by Stephan van der Putten s1528459

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
  declare -a nodes=()
  preserve -# $2 -t 00:$3:00
  # during testing
  #preserve -# $2 -t 00:00:30
  sleep 1
  declare -a nodes=(`preserve -llist | grep $USER | awk '{for (i=9; i<NF; i++) printf $i " "; if (NF >= 9+$2) printf $NF;}'`)

  echo "We have reserverd node(s): ${nodes[@]}"

  printf "\n"
  echo > $SPARK_HOME/conf/spark-env.sh
  printf "The master is node: ${nodes[0]}"
  echo "SPARK_MASTER_HOST=\"${nodes[0]}\"" >> $SPARK_HOME/conf/spark-env.sh 
  echo "SPARK_MASTER_PORT=1337" >> $SPARK_HOME/conf/spark-env.sh 
  echo "SPARK_MASTER_WEBUI_PORT=6789" >> $SPARK_HOME/conf/spark-env.sh 
  echo "$node" >> $SPARK_HOME/conf/spark-env.sh

  printf "\n"


  echo > $SPARK_HOME/conf/slaves
  for node in "${nodes[@]:1}"
  do 
    echo "$node" >> $SPARK_HOME/conf/slaves
    #echo "node: " $node 
    #printf "\n"
  done 


  # start the remote master
  ssh ${nodes[0]} '$SPARK_HOME/sbin/start-master.sh'
  $SPARK_HOME/sbin/start-all.sh

  echo "We are done"
  
  exit 0
fi

if [[ $1 = "--local" ]]
then
  echo "Setting up a node cluster of size 1"

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
stop_all () {
  ssh ${nodes[0]} "$SPARK_HOME/sbin/stop-all.sh"
  # ~/.local/bin/spark/sbin/stop-all.sh
}

if [[ $1 = "--stop_all" ]]
then
    stop_all
    wait
    exit 0
fi
