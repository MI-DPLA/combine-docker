# combine-docker

## Configuration

Modify Combine app configurations before Docker images are built.  While the file is already tailored to look for Docker containers, users may still want to add values like S3 or DPLA API keys:
```
./combine/localsettings.py
```


## Initial Build

The end goal is a single `docker-compose up`, but in the interim there might be a couple additional steps.

Build images:
```
docker-compose -p combine-docker build
```

Run first build script
```
./first_build.sh
```


## Running and Managing

  * Run with `up` and detatch:
  `docker-compose -p combine up -d`

  * Restart select services, e.g.:
  `docker-compose restart combine-django combine-celery`


## Troubleshooting

### ElasticSearch container dies because of `vm.max_map_count`

Depending on machine and OS (Linux, Mac, Windows), might need to bump `vm.max_map_count` (seems to be particulary true on older machines):
[https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode)

