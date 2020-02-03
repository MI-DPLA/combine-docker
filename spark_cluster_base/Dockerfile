FROM openjdk:8-jdk-slim-buster

RUN apt-get update \
 && apt-get install -y locales \
 && dpkg-reconfigure -f noninteractive locales \
 && locale-gen C.UTF-8 \
 && /usr/sbin/update-locale LANG=C.UTF-8 \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Users with other locales should set this in their derivative image
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install OS libraries
RUN apt-get update \
 && mkdir -p /usr/share/man/man1 \
 && apt-get install -y curl unzip lsof wget unzip maven \
    python3 python3-setuptools python3-pip \
 && ln -s /usr/bin/python3 /usr/bin/python \
 && pip3 install py4j \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

# Arguments
ARG FOO
ARG SPARK_VERSION
ENV SPARK_VERSION=$SPARK_VERSION
ARG HADOOP_VERSION_SHORT
ENV HADOOP_VERSION_SHORT=$HADOOP_VERSION_SHORT
ARG ELASTICSEARCH_HADOOP_CONNECTOR_VERSION
ENV ELASTICSEARCH_HADOOP_CONNECTOR_VERSION=$ELASTICSEARCH_HADOOP_CONNECTOR_VERSION

# Download and install Spark
RUN cd /tmp \
 && curl https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT}.tgz -o /tmp/spark.tgz \
 && tar -xvf spark.tgz \
 && mv /tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT} /opt/spark \
 && rm /tmp/spark.tgz
ENV SPARK_HOME=/opt/spark

# Copy configurations
ARG BAR
COPY spark-defaults.conf /opt/spark/conf/spark-defaults.conf
