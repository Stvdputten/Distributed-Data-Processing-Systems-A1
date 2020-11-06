#!/usr/bin/env bash
# Written by Stephan van der Putten s1528459

# Check requirements SPARK_HOME and HADOOP_HOME and JAVA_HOME and HIBENCH_HOME
check_requirements() {
  if [ -z "$SPARK_HOME" ]; then
    echo 'No SPARK_HOME set'
    echo 'Set Spark env variable'
  fi

  if [ -z "$HADOOP_HOME" ]; then
    echo 'No HADOOP_HOME set'
    echo 'Set Hadoop env variable'
  fi

  if [ -z "$JAVA_HOME" ]; then
    echo 'No JAVA_HOME set'
    echo 'Set JAVA_HOME env variable'
  fi

  if [ -z "$HIBENCH_HOME" ]; then
    echo 'No HIBENCH_HOME set'
    echo 'Set HIBENCH_HOME env variable'
  fi
  source ~/.bashrc
}

#  Setups hadoop and spark and Hibench
initial_setup() {
  echo "Starting setup"
  echo "Downloading Hadoop & Spark & HiBench & Maven "
  wget https://apache.mirrors.nublue.co.uk/hadoop/common/hadoop-2.10.1/hadoop-2.10.1.tar.gz
  wget https://mirror.novg.net/apache/spark/spark-2.4.7/spark-2.4.7-bin-hadoop2.7.tgz
  wget https://mirror.lyrahosting.com/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
  git clone https://github.com/Intel-bigdata/HiBench.git ~/lib/hibench

  # create lib where hadoop and spark will be stored
  mkdir -p ~/lib/hadoop ~/lib/spark ~/lib/maven

  echo "Extracting files to lib"
  # extract to correct folders
  tar zxf hadoop-3.3.0.tar.gz -C ~/lib/hadoop --strip-components=1
  tar zxf spark-3.0.1-bin-hadoop3.2.tgz -C ~/lib/spark --strip-components=1
  tar zxf apache-maven-3.6.3-bin.tar.gz -C ~/lib/maven --strip-components=1

  echo "Cleaning up"
  # rm tgz
  rm hadoop-3.3.0.tar.gz spark-3.0.1-bin-hadoop3.2.tgz apache-maven-3.6.3-bin.tar.gz
  echo "Setup done"
  check_requirements
  echo "Don't forget to setup the environment variables manually" 
}

if [[ $1 == "--setup" ]]; then
  initial_setup
  exit 0
fi

# Finds nodes on das5 and setups Hadoop
initial_setup_hadoop() {
  # declare reserved nodes
  declare -a nodes=($(preserve -llist | grep $USER | awk '{for (i=9; i<NF; i++) printf $i " "; if (NF >= 9+$2) printf $NF;}'))

  # setups master node
  ssh "${nodes[0]}" 'mkdir -p /local/ddps2006/hadoop/'
  #  master=$(ssh ${nodes[0]} 'ifconfig' | grep 'inet 10.149.*' | awk '{print $2}')
  sed -i "s/hdfs:\/\/.*:/hdfs:\/\/${nodes[0]}:/g" $HADOOP_HOME/etc/hadoop/core-site.xml
  sed -i "22s/<value>.*:/<value>${nodes[0]}:/g" $HADOOP_HOME/etc/hadoop/yarn-site.xml
  sed -i "26s/<value>.*</<value>${nodes[0]}</g" $HADOOP_HOME/etc/hadoop/yarn-site.xml

  # setup worker nodes
  echo >$HADOOP_HOME/etc/hadoop/slaves
  for node in "${nodes[@]:1}"; do
    ssh "$node" 'ifconfig' | grep 'inet 10.149.*' | awk '{print $2}' >>$HADOOP_HOME/etc/hadoop/slaves
    #    echo $node >>$HADOOP_HOME/etc/hadoop/slaves

    # Clean up local and setups up local directory
    ssh "$node" 'rm -rf /local/ddps2006/hadoop/*'
    ssh "$node" 'mkdir -p /local/ddps2006/hadoop/data'
  done

  # Setup namenode
  ssh "${nodes[0]}" 'yes | $HADOOP_HOME/bin/hadoop namenode -format'

  # Start daemons
  ssh "${nodes[0]}" '$HADOOP_HOME/sbin/start-dfs.sh'
  ssh "${nodes[0]}" '$HADOOP_HOME/sbin/start-yarn.sh'
}

# Finds nodes on das5 and setups HiBench
initial_setup_spark() {
  # declare reserved nodes
  declare -a nodes=($(preserve -llist | grep $USER | awk '{for (i=9; i<NF; i++) printf $i " "; if (NF >= 9+$2) printf $NF;}'))

  # setup driver node of spark (running next to yarn) in standalone and configs of spark in standalone
  echo >$SPARK_HOME/conf/spark-env.sh
  echo "SPARK_MASTER_HOST=\"${nodes[0]}\"" >>$SPARK_HOME/conf/spark-env.sh
  # ssh ${nodes[0]} 'ifconfig' | grep 'inet 10.149.*' | awk '{print $2}' >> $SPARK_HOME/conf/slaves
  echo "SPARK_MASTER_PORT=1336" >>$SPARK_HOME/conf/spark-env.sh
  echo "SPARK_LOCAL_DIRS=/local/ddps2006/spark/" >>$SPARK_HOME/conf/spark-env.sh
  echo "SPARK_MASTER_WEBUI_PORT=1335" >>$SPARK_HOME/conf/spark-env.sh
  #echo "SPARK_WORKER_INSTANCES="$(expr ${#nodes[@]} - 1)"" >> $SPARK_HOME/conf/spark-env.sh
  echo "SPARK_WORKER_MEMORY=15G" >>$SPARK_HOME/conf/spark-env.sh

  # Necessary for working with yarn
  echo "HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop" >>$SPARK_HOME/conf/spark-env.sh

  ssh "${nodes[0]}" 'rm -rf /local/ddps2006/spark/*'
  ssh "${nodes[0]}" 'mkdir -p /local/ddps2006/spark/'

  printf "\n"
  # setup worker nodes of spark
  echo >$SPARK_HOME/conf/slaves
  for node in "${nodes[@]:1}"; do
    # slower connection
    #$echo "$node" >> $SPARK_HOME/conf/slaves

    #highbang connection
    ssh "$node" 'ifconfig' | grep 'inet 10.149.*' | awk '{print $2}' >>$SPARK_HOME/conf/slaves
    ssh "$node" 'rm -rf /local/ddps2006/spark/*'
    ssh "$node" 'mkdir -p /local/ddps2006/spark/'
  done

  # start the remote master
  ssh "${nodes[0]}" '$SPARK_HOME/sbin/start-all.sh'
}

# Setup for HiBench
initial_setup_hibench() {
  # declare nodes
  declare -a nodes=($(preserve -llist | grep $USER | awk '{for (i=9; i<NF; i++) printf $i " "; if (NF >= 9+$2) printf $NF;}'))

  # declare hdfs address to hibench
  sed -i "11s/hdfs:\/\/.*:/hdfs:\/\/${nodes[0]}:/g" $HIBENCH_HOME/conf/hadoop.conf

  # build hibench benchmarks, currently only ml and micro
  cd "$HIBENCH_HOME" && mvn -Phadoopbench -Psparkbench -Dmodules -Pmicro -Pml -Dspark=2.4 clean package

}

# Setups the amount of nodes and takes flag amount of minutes
if [[ $1 == "--nodes" ]]; then
  echo "Setting up a node cluster of size $2"
  declare -a nodes=()

  # actual preserving, normally 15 minutes, can be more
  preserve -# $2 -t 00:$3:00
  sleep 1
  declare -a nodes=($(preserve -llist | grep $USER | awk '{for (i=9; i<NF; i++) printf $i " "; if (NF >= 9+$2) printf $NF;}'))

  # if nodes got reserved we can run otherwise we have to wait
  if [ ${nodes[0]} = "-" ]; then
    echo "Nodes are waiting to be reserved, try --start-all when ready"
  else
    echo "We have reserved node(s): ${nodes[@]}"

    # setup hadoop/spark/HiBench
    initial_setup_hadoop
    initial_setup_spark
    initial_setup_hibench
  fi

  printf "\n"
  echo "We have reserved node(s): ${nodes[@]}"
  printf "The master is node: ${nodes[0]}"
  printf "\n"

  echo "Cluster is setup for spark and hadoop!"

  exit 0
fi

# Runs the experiments and $2 is the amount of times
if [[ $1 == "--experiments" ]]; then
  # declare nodes
  declare -a nodes=($(preserve -llist | grep $USER | awk '{for (i=9; i<NF; i++) printf $i " "; if (NF >= 9+$2) printf $NF;}'))

  # setup configured dataset size from hibench.conf
  ssh ${nodes[0]} "$HIBENCH_HOME/bin/workloads/micro/wordcount/prepare/prepare.sh" 
  #echo "" > $HIBENCH_HOME/report/hibench.report

  start=1
  for i in $(eval echo "{$start..$2}")
  do
    printf "\n"
    echo "Running experiment: $i"

    ssh "${nodes[0]}" "$HIBENCH_HOME/bin/workloads/micro/wordcount/hadoop/run.sh"
    wait
    sh "${nodes[0]}" "$HIBENCH_HOME/bin/workloads/micro/wordcount/spark/run.sh"
    wait
  done

  # show results
  echo "Results are shown:"
  cat $HIBENCH_HOME/report/hibench.report
  wait
  exit 0
fi


# Mostly for local debugging assuming HDFS is correctly setup and SPARK knows how to connect to HDFS
# TODO Needs to be expanded to only choose 1 worker node, which is most likely localhost
if [[ $1 == "--local" ]]; then
  check_requirements
  echo "Setting up a node cluster of size 1"
  echo "Setting up Hadoop & Spark"

  start_all
  exit 0
fi

# Starts all and builds Hibench
start_all() {
  initial_setup_spark
  initial_setup_hadoop
  initial_setup_hibench
}

# Start up SPARK and HADOOP daemons/processes with Hibench
if [[ $1 == "--start-all" ]]; then
  echo "Starting all"
  start_all
  wait
  exit 0
fi
# Stops all drivers and workers
stop_all() {
  # declare node
  declare -a nodes=($(preserve -llist | grep $USER | awk '{for (i=9; i<NF; i++) printf $i " "; if (NF >= 9+$2) printf $NF;}'))

  # send message to drivers to stop
  ssh ${nodes[0]} '$HADOOP_HOME/sbin/stop-dfs.sh'
  ssh ${nodes[0]} '$HADOOP_HOME/sbin/stop-yarn.sh'
  ssh ${nodes[0]} '$SPARK_HOME/sbin/stop-all.sh'

  # deallocates reservation
  #scancel "$(preserve -llist | grep ddps2006 | awk '{print $1}')"
}

# Stops all drivers and workers
if [[ $1 == "--stop-all" ]]; then
  echo "Stopping all"
  stop_all
  wait
  exit 0
fi

# Help option
if [[ $1 == "--help" || $1 == "-h" ]]; then
  echo "Usage: $0 [option]"
  echo "--setup                     Setup all initial software and packages."
  echo "--start-all                 Start cluster hadoop/spark default."
#  echo "local                     Start all current nodes."
  echo "--stop-all                  Stop cluster."
  echo "--experiments n             Runs the default experiments n times."
  echo "--nodes n t                 Followed by (n) number of nodes to setup in das5 and (t) time allocation."
  exit 0
fi

