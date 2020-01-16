# run combine django shell
CONTAINER=`docker-compose ps | grep combine-django | awk '{ print $1 }'`
docker exec -it $CONTAINER python /opt/combine/manage.py shell_plus