#!/bin/bash
export JAVA_HOME=/usr/local/openjdk-8/jre
export HADOOP_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
# export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

####################################################################################
# DO NOT MODIFY THE BELOW ##########################################################

ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys

# DO NOT MODIFY THE ABOVE ##########################################################
####################################################################################

# Setup HDFS/Spark worker here

# Hadoop environment setup
echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
echo "export HADOOP_HOME=$HADOOP_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
echo "export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:\$PATH" >> ~/.bashrc

# Configure core-site.xml (point to master)
cat > $HADOOP_HOME/etc/hadoop/core-site.xml <<EOF
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://main:9000</value>
  </property>
</configuration>
EOF

# Configure hdfs-site.xml (local datanode storage)
cat > $HADOOP_HOME/etc/hadoop/hdfs-site.xml <<EOF
<configuration>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file:/hdfs/datanode</value>
  </property>
</configuration>
EOF


# =========================
# Setup Spark (Worker)
# =========================

# Spark environment setup
echo "export JAVA_HOME=$JAVA_HOME" >> $SPARK_HOME/conf/spark-env.sh
echo "export HADOOP_HOME=$HADOOP_HOME" >> $SPARK_HOME/conf/spark-env.sh
echo "export PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:\$PATH" >> ~/.bashrc