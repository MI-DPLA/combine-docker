FROM combine-docker_spark-cluster-base:latest

# Arguments
ARG HADOOP_VERSION
ENV HADOOP_VERSION=$HADOOP_VERSION

# Download and install Hadoop
RUN mkdir /opt/hadoop \
 && cd /opt/hadoop \
 && wget https://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
 && tar --strip-components=1 -xvf hadoop-${HADOOP_VERSION}.tar.gz \
 && rm /opt/hadoop/hadoop-${HADOOP_VERSION}.tar.gz

# Copy configurations
COPY core-site.xml /opt/hadoop/etc/hadoop/core-site.xml
COPY hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xml

# Envs
ENV HADOOP_PREFIX=/opt/hadoop
ENV HADOOP_HOME=${HADOOP_PREFIX}
ENV HADOOP_COMMON_HOME=${HADOOP_PREFIX}
ENV HADOOP_CONF_DIR=${HADOOP_PREFIX}/etc/hadoop
ENV HADOOP_HDFS_HOME=${HADOOP_PREFIX}
ENV HADOOP_MAPRED_HOME=${HADOOP_PREFIX}
ENV HADOOP_YARN_HOME=${HADOOP_PREFIX}
