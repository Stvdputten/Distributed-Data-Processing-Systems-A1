#!/usr/bin/env bash
# Written by Stephan van der Putten s1528459

root_dir=$(pwd)

# Setups SPARK_HOME and HADOOP_HOME and JAVA_HOME
check_requirements(){
  if [ -z "$SPARK_HOME" ]
  then 
    #export SPARK_HOME=~/lib/spark
    echo 'No SPARK_HOME set'
    echo 'Set Spark env variable'
  fi
  
  if [ -z "$HADOOP_HOME" ]
  then 
    #export HADOOP_HOME=~/lib/hadoop
    echo 'No HADOOP_HOME set'
    echo 'Set Hadoop env variable'
  fi

  if [ -z "$JAVA_HOME" ]
  then 
    #export JAVA_HOME=~/lib/hadoop
    echo 'No JAVA_HOME set'
    echo 'Set JAVA_HOME env variable'
  fi

  source ~/.bashrc
}


# Setups up the hadoop and spark
initial_setup() {
  echo "Starting setup"
  # TODO UPDATE to correct versions
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

initial_setup_hadoop() {
  declare -a nodes=(`preserve -llist | grep $USER | awk '{for (i=9; i<NF; i++) printf $i " "; if (NF >= 9+$2) printf $NF;}'`)
  ssh ${nodes[0]} 'mkdir -p /local/ddps2006/hadoop/'
  echo > $HADOOP_HOME/etc/hadoop/slaves
  for node in "${nodes[@]:1}"
  do 
    ssh $node 'ifconfig' | grep 'inet 10.149.*' | awk '{print $2}' >> $HADOOP_HOME/etc/hadoop/slaves
    ssh $node 'mkdir -p /local/ddps2006/hadoop/'
  done

  ssh ${nodes[0]} '$HADOOP_HOME/sbin/start-dfs.sh'
  ssh ${nodes[0]} '$HADOOP_HOME/sbin/start-yarn.sh'
}

initial_setup_spark() {
  declare -a nodes=(`preserve -llist | grep $USER | awk '{for (i=9; i<NF; i++) printf $i " "; if (NF >= 9+$2) printf $NF;}'`)
  echo > $SPARK_HOME/conf/spark-env.sh
  echo "SPARK_MASTER_HOST=\"${nodes[0]}\"" >> $SPARK_HOME/conf/spark-env.sh 
  #ssh ${nodes[0]} 'ifconfig' | grep 'inet 10.149.*' | awk '{print $2}' >> $SPARK_HOME/conf/slaves
  echo "SPARK_MASTER_PORT=1337" >> $SPARK_HOME/conf/spark-env.sh 
  echo "SPARK_LOCAL_DIRS=/local/ddps2006/spark" >> $SPARK_HOME/conf/spark-env.sh 
  #echo "SPARK_MASTER_WEBUI_PORT=6789" >> $SPARK_HOME/conf/spark-env.sh 
  echo "$node" >> $SPARK_HOME/conf/spark-env.sh
  ssh ${nodes[0]} 'mkdir -p /local/ddps2006/spark/'

  echo "$node" >> $SPARK_HOME/conf/spark-env.sh

  printf "\n"

  echo > $SPARK_HOME/conf/slaves
  for node in "${nodes[@]:1}"
  do 
    #old band
    #$echo "$node" >> $SPARK_HOME/conf/slaves

    #highbang connection
    ssh $node 'ifconfig' | grep 'inet 10.149.*' | awk '{print $2}' >> $SPARK_HOME/conf/slaves
    ssh $node 'mkdir -p /local/ddps2006/spark/'
    #echo "node: " $node 
    #printf "\n"
  done 

  # start the remote master
  ssh ${nodes[0]} '$SPARK_HOME/sbin/start-all.sh'
  #ssh ${nodes[0]} '$SPARK_HOME/sbin/start-master.sh'
  #$SPARK_HOME/sbin/start-all.sh

}

# Setups the amount of nodes and takes flag amount of minutes
if [[ $1 = "--nodes" ]]
then
  echo "Setting up a node cluster of size $2"
  declare -a nodes=()
  preserve -# $2 -t 00:$3:00
  # during testing
  #preserve -# $2 -t 00:00:30
  sleep 1
  declare -a nodes=(`preserve -llist | grep $USER | awk '{for (i=9; i<NF; i++) printf $i " "; if (NF >= 9+$2) printf $NF;}'`)

  #if [[ $1 = "-"]]
  #  
  #fi
  echo "We have reserverd node(s): ${nodes[@]}"

  # TODO Hadoop setup
  #initial_setup_hadoop

  initial_setup_spark

  printf "\n"
  printf "The master is node: ${nodes[0]}"
  printf "\n"

  echo "Cluster is setup for spark and hadoop!"
  
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

start_all () {
    initial_setup_spark
    #$SPARK_HOME/sbin/start_all.sh
    #$HADOOP_HOME/sbin/start_all.sh
}

# Start up SPARK and HADOOP daemons/processes
if [[ $1 = "--start-all" ]]
then
  echo "Starting all"
  start_all
  wait
  exit 0
fi

stop_all () {
  # ssh ${nodes[0]} "$SPARK_HOME/sbin/stop-all.sh"
  #declare -a nodes=(`preserve -llist | grep $USER | awk '{for (i=9; i<NF; i++) printf $i " "; if (NF >= 9+$2) printf $NF;}'`)
  #ssh ${nodes[0]} '$SPARK_HOME/sbin/stop-all.sh'
  $HADOOP_HOME/sbin/stop-dfs.sh
  $HADOOP_HOME/sbin/stop-yarn.sh
  $SPARK_HOME/sbin/stop-all.sh
}

if [[ $1 = "--stop-all" ]]
then
    echo "Stopping all"
    stop_all
    wait
    exit 0
fi

# TODO
if [[ $1 = "--local" ]]
then
  echo "Setting up a node cluster of size 1"

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
#start () {
#    ~/.local/bin/spark/sbin/start-master.sh
#    ~/.local/bin/spark/sbin/start-slaves.sh
#}
#

