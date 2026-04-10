#!/bin/sh
if [ ! -d /hdfs/namenode ]; then
  ${HADOOP_PREFIX}/bin/hdfs namenode -format -nonInteractive
else
  find /hdfs/namenode -empty -type d -exec echo {} is empty \;
fi
