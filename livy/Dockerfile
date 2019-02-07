FROM combine-docker_spark-master:latest

# Arguments
ARG LIVY_TAGGED_RELEASE
ARG SCALA_VERSION
ENV LIVY_TAGGED_RELEASE=$LIVY_TAGGED_RELEASE
ENV SCALA_VERSION=$SCALA_VERSION

# Download and install Livy
RUN cd /opt \
 && git clone https://github.com/apache/incubator-livy livy \
 && cd livy \
 && git checkout -b tags/${LIVY_TAGGED_RELEASE} ${LIVY_TAGGED_RELEASE} \
 && mvn package -DskipTests \
 && mkdir logs \
 && ln -s /combinelib/ingestion3_${SCALA_VERSION}-0.0.1.jar /opt/livy/rsc/target/jars/ingestion3.jar