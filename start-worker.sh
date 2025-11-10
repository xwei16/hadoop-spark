#!/bin/bash

####################################################################################
# DO NOT MODIFY THE BELOW ##########################################################

/etc/init.d/ssh start
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/shared_rsa

# DO NOT MODIFY THE ABOVE ##########################################################
####################################################################################

# Start HDFS/Spark worker here
export JAVA_HOME=/usr/local/openjdk-8/jre
export HADOOP_HOME=/opt/hadoop
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

# Start DataNode service
$HADOOP_HOME/bin/hdfs --daemon start datanode

echo "=== HDFS Worker (DataNode) started and registered with master ==="


# Start Spark Worker connecting to master
export SPARK_HOME=/opt/spark
$SPARK_HOME/sbin/start-worker.sh spark://main:7077
# $SPARK_HOME/sbin/start-slave.sh spark://main:7077
echo "=== Spark Worker connected to spark://main:7077 ==="

# Keep interactive shell alive
bash