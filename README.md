# Distributed Data Processing Systems A1

This project presents the benchmarking on the das5 cluster for the course DDPS (2020). We are reproducing the results of the paper mentioned below and report our findings.

This repository contains code runnable on the das5 system, see [info](https://www.cs.vu.nl/das5/) for more information. 

Based on the paper [Resilient Distributed Datasets](https://www.usenix.org/conference/nsdi12/technical-sessions/presentation/zaharia) which are the fundamentals of the popular [spark](https://spark.apache.org/) framework. 

## DAS-5 access
> This deploy script is setup for `fs1.das5.liacs.nl`

First login to `fs1.das5.liacs.nl` through one of the universities networks and ssh into the cluster.
```
# example s1528459@ssh.liacs.nl
ssh <ACCCOUNT>@ssh.liacs.nl

# ssh to das5 cluster from ssh.liacs.nl with your DAS5 login credentials
ssh <DAS5_ACCOUNT>@fs1.das5.liacs.nl
```

## Requirements

This repository has been tested for local usage on Debian 10 and is run on the linux system of das5.

## Setup 

**1. Clone the repo**
```
git clone https://github.com/Stvdputten/Distributed-Data-Processing-Systems-A1.git
```

**2. Deploy setup**
```
cd Distributed-Data-Processing-Systems-A1
./das5setup --setup
```

## Usage example

## Acknowledgements

This repository is open-source and created for the course Distributed Data Processing Systems (2020) of University Leiden, given by Alex Uta. 

This readme is inspired by https://github.com/facebookarchive/Audio360 
