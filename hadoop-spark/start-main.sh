#!/bin/bash

####################################################################################
# DO NOT MODIFY THE BELOW ##########################################################

# Exchange SSH keys.
/etc/init.d/ssh start
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/shared_rsa
ssh-copy-id -i ~/.ssh/id_rsa -o 'IdentityFile ~/.ssh/shared_rsa' -o StrictHostKeyChecking=no -f worker1
ssh-copy-id -i ~/.ssh/id_rsa -o 'IdentityFile ~/.ssh/shared_rsa' -o StrictHostKeyChecking=no -f worker2

# DO NOT MODIFY THE ABOVE ##########################################################
####################################################################################

# Start HDFS/Spark main here

export JAVA_HOME=/usr/local/openjdk-8/jre
export HADOOP_HOME=/opt/hadoop
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH
export SPARK_HOME=/opt/spark

# Make sure workers file is in place
cat > $HADOOP_HOME/etc/hadoop/workers <<EOF
worker1
worker2
EOF

# Start HDFS daemons (namenode + datanodes via SSH)
# $HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/bin/hdfs --daemon start namenode
$HADOOP_HOME/bin/hdfs --daemon start datanode

echo "=== HDFS Master (NameNode) started at hdfs://main:9000 ==="


# Start Spark Master

mkdir -p $SPARK_HOME/conf
echo "export SPARK_MASTER_HOST=main" >> $SPARK_HOME/conf/spark-env.sh
echo "export SPARK_MASTER_PORT=7077" >> $SPARK_HOME/conf/spark-env.sh
echo "export JAVA_HOME=$JAVA_HOME" >> $SPARK_HOME/conf/spark-env.sh

$SPARK_HOME/sbin/start-master.sh --host main --port 7077
$SPARK_HOME/sbin/start-worker.sh spark://main:7077
echo "=== Spark Master started at spark://main:7077 ==="


# Keep interactive shell alive
bash