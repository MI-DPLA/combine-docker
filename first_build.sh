# echo
echo "Running Combine-Docker first build, this should be run only once!"

# init Combine app submodule and use localsettings docker template
git submodule init
git submodule update
cp ./combine/combine/combine/localsettings.py.docker ./combine/combine/combine/localsettings.py

# format Hadoop namenode
docker-compose run hadoop-namenode /bin/bash -c "mkdir -p /hdfs/namenode && echo 'Y' && /opt/hadoop/bin/hdfs namenode -format"

# Combine db migrations and superuser create
docker-compose run combine-django /bin/bash -c "bash /tmp/combine_db_prepare.sh"
