# Distributed Data Processing Systems A1

This project presents the benchmarking on the DAS-5 cluster for the course DDPS (2020). We are reproducing the results of the paper mentioned below and report our findings.

This repository contains code runnable on the DAS-5 system, see [info](https://www.cs.vu.nl/das5/) for more information. 

Based on the paper [Resilient Distributed Datasets](https://www.usenix.org/conference/nsdi12/technical-sessions/presentation/zaharia) which are the fundamentals of the popular [spark](https://spark.apache.org/) framework. 

## DAS-5 access
> This deploy script is setup for `fs1.das5.liacs.nl`

First login to `fs1.das5.liacs.nl` through one of the universities networks and ssh into the cluster.
```
# example s1528459@ssh.liacs.nl
ssh <ACCCOUNT>@ssh.liacs.nl

# ssh to DAS-5 cluster from ssh.liacs.nl with your DAS5 login credentials
ssh <DAS5_ACCOUNT>@fs1.das5.liacs.nl
```

## 

This repository has been tested in DAS-5

##  Set Environment 
Make sure to `export` and `source` the variables and save it in your .bashrc 

Environment Variable        |      Meaning
----------------|--------------------------------------------------------
$SPARK_HOME    |      The Spark installation location
$HADOOP_HOME  |   The Hadoop installation location. 
$JAVA_HOME | The Java installation location. Usually somewhere on /usr/lib/jvm/
$HIBENCH_HOME | The Hibench installation location. 

## Setup 

**1. Clone the repo**
```
git clone https://github.com/Stvdputten/Distributed-Data-Processing-Systems-A1.git
```

**2. Deploy setup** (optional)
| Make sure you set your settings in yarn-site.xml in the $HADOOP_HOME/etc/hadoop/ is set correctly when starting up, otherwise you have to restart.

```
cd Distributed-Data-Processing-Systems-A1
./das5setup --setup 
source ~/.bashrc
```

**3. Startup multi cluster**
```
# First variable is the node count and second variable is the reserved amount of time
./das5setup --nodes 5 15
```

## Run experiments
> In case you want to use the same configurations as we used see /configurations/hadoop , /configurations/spark , /configurations/hibench do not forget to rebuild Hibench 
> The settings can be changed in yarn-site.xml in the $HADOOP_HOME/etc/hadoop/ and $HIBENCH_HOME/conf/spark.conf for the experiments
> Otherwise you can change the settings in the /configurations directory and run ./das5setup --update-configs

Now that the cluster is setup and Hibench has been built, we can run the experiments n times

```
./das5setup --experiments-1 20 # set to large dataset size
#
./das5setup --experiments-2 20 huge # last flag can be changed to try other setups
```
The results are copied to `experiments/hibench.report`

## Deallocate cluster
This deallocates the cluster on DAS-5
```
./das5setup --stop-all
```
## Options

Run to see the different options and explanation
```
./das5setup --h
```
## Acknowledgements

This repository is open-source and created for the course Distributed Data Processing Systems (2020) of University Leiden.
