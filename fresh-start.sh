# must create all the containers first
docker compose create

# make sure nginx.conf is there
cp ./nginx/nginx.conf.template ./nginx/nginx.conf
