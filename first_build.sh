
# echo
echo "Running Combine-Docker first build, this should be run only once!"

# format Hadoop namenode
docker-compose run hadoop-namenode /bin/bash -c "mkdir -p /hdfs/namenode && echo 'Y' && ${HADOOP_PREFIX}/bin/hdfs namenode -format"

# Combine db migrations and superuser create
# TODO: pass mysql root password with run command
docker-compose run combine-django /bin/bash -c "bash /tmp/combine_db_prepare.sh"
