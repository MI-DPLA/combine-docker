# run combine bash
CONTAINER=`docker-compose ps | grep combine-django | awk '{ print $1 }'`
docker exec -it $CONTAINER bash -c "cd /opt/combine && bash"