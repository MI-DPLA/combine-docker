# generic bash shell given container
SERVICE=$1
CONTAINER=`docker-compose ps | grep $SERVICE | awk '{ print $1 }'`
docker exec -it $CONTAINER bash