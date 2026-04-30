FROM ghcr.io/mi-dpla/combine-docker/django

# Arguments
ARG SCALA_VERSION
ARG ELASTICSEARCH_HADOOP_CONNECTOR_VERSION
ENV SCALA_VERSION=$SCALA_VERSION
ENV ELASTICSEARCH_HADOOP_CONNECTOR_VERSION=$ELASTICSEARCH_HADOOP_CONNECTOR_VERSION

# Download and install Livy
RUN apt-get install -y r-base \
  && cd /opt \
  && git clone https://github.com/MI-DPLA/livy \
  && cd livy \
  && git checkout combine-livy \
  && pip install -r requirements.txt \
  && mkdir logs
COPY combinelib/ingestion3_${SCALA_VERSION}-0.0.1.jar /opt/livy/rsc/target/jars/ingestion3.jar
COPY combinelib/elasticsearch-hadoop-${ELASTICSEARCH_HADOOP_CONNECTOR_VERSION}.jar /opt/livy/rsc/target/jars/elasticsearch-hadoop-${ELASTICSEARCH_HADOOP_CONNECTOR_VERSION}.jar

COPY livy/spark-2.4.5-bin-hadoop2.7.tgz /opt/livy/target/spark-2.4.5-bin-hadoop2.7.tgz
#RUN cd /opt/livy && mvn validate
RUN cd /opt/livy && mvn package

# Copy configurations
COPY livy/livy.conf /opt/livy/conf/livy.conf
RUN cat /opt/livy/conf/livy.conf
COPY livy/livy-env.sh /opt/livy/conf/livy-env.sh
COPY livy/log4j.properties /opt/livy/conf/log4j.properties

# Remove ivy cache directory
# https://github.com/MI-DPLA/combine-docker/issues/5
RUN rm -r /root/.m2
