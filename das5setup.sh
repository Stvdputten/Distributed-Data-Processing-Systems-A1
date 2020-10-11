#!/usr/bin/env bash

root_dir=$(pwd)

# Setups SPARK_HOME and HADOOP_HOME
check_requirements(){
  if [ -z "$SPARK_HOME" ]
  then 
    export SPARK_HOME=~/lib/spark
    echo 'No SPARK_HOME set'
    echo 'Set Spark env variable'
  fi
  
  if [ -z "$HADOOP_HOME" ]
  then 
    export HADOOP_HOME=~/lib/hadoop
    echo 'No HADOOP_HOME set'
    echo 'Set Hadoop env variable'
  fi
}

source ~/.bashrc

initial_setup() {
  echo "Starting setup"
  echo "Downloading Hadoop & Spark"
  wget https://apache.mirror.wearetriple.com/spark/spark-3.0.1/spark-3.0.1-bin-hadoop3.2.tgz
  wget https://apache.mirror.wearetriple.com/hadoop/common/hadoop-3.3.0/hadoop-3.3.0.tar.gz

  # create lib where hadoop and spark will be stored
  mkdir -p ~/lib/hadoop ~/lib/spark

  echo "Extracting files to lib"
  # extract to correct folders
  tar zxf hadoop-3.3.0.tar.gz -C ~/lib/spark --strip-components=1
  tar zxf spark-3.0.1-bin-hadoop3.2.tgz -C ~/lib/spark --strip-components=1

  echo "Cleaning up"
  # rm tgz
  rm hadoop-3.3.0.tar.gz spark-3.0.1-bin-hadoop3.2.tgz
  echo "Setup done"
}

if [[ $1 = "--setup" ]]
then
  initial_setup
  exit 0
fi

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
    # Goal is to connect workers to a master node TODO
    ssh node 'cd $SPARK_HOME && sbin/start-slave.sh spark://fs1.cm.cluster:7082'
    echo "$node"
  done
  
  exit 0
fi

# Mostly for local debugging assuming HDFS is correctly setup and SPARK knows how to connect to HDFS
# TODO Needs to be expanded to only choose 1 worker node, which is most likely localhost
if [[ $1 = "--local" ]]
then
  check_requirements
  echo "Setting up a node cluster of size 1"
  echo "Setting up Hadoop & Spark"

  start_all
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

# Start up SPARK and HADOOP daemons/processes
if [[ $1 = "--start-all" ]]
then
  echo "Starting all"
  start_all
  exit 0
fi

if [[ $1 = "--help" || $1 = "-h" ]]
then
    echo "Usage: $0 [option]"
    echo "setup                     Setup all initial software and packages."
    echo "start-all                 Start all current nodes."
    echo "local                     Start all current nodes."
    echo "stop-all                  Stop all current nodes."
    echo "nodes                     Followg by number of nodes to setup in das5"
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

