# run combine django shell
CONTAINER=`docker-compose ps | grep combine-django | awk '{ print $1 }'`
docker exec -it $CONTAINER bash /opt/combine/pyspark_shell.sh