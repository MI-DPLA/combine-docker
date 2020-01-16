#!/bin/sh
if [ ! -f /hdfs/namenode/.formatted ]; then
  ${HADOOP_PREFIX}/bin/hdfs namenode -format
fi
