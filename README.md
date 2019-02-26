# Combine-Docker


## Configuration

Modify Combine app configurations before Docker images are built.  While the file is already tailored to look for Docker containers, users may still want to add values like S3 or DPLA API keys:
```
./combine/localsettings.py
```


## Initial Build

The end goal is a single `docker-compose up`, but in the interim there might be a couple additional steps.

Build images:
```
docker-compose build
```

Run first build script
```
./first_build.sh
```


## Running and Managing

  * Run with `up` and detatch:
  `docker-compose up -d`

  * Restart select services, e.g.:
  `docker-compose restart combine-django combine-celery`


## Troubleshooting

### ElasticSearch container dies because of `vm.max_map_count`

Depending on machine and OS (Linux, Mac, Windows), might need to bump `vm.max_map_count` on Docker host machine (seems to be particulary true on older ones):
[https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode)

### Port collision error: `port is already allocated`

By default, nearly all relevant ports are exposed from the containers that conspire to run Combine, but these can turned off selectively (or changed) if you have services running on your host that conflict.  Look for the `ports` section for each service in the `docker-compose.yml` file you're running.


## Development

Building and running for development, for convenience sake, is a bit different.  As development likely includes working on the Combine Django app, it is handy to have the app on the host machine, then bound to the `combine-django`, `combine-celery`, and `livy` containers that require its code.  In this way, code from the app can be modified locally, while simultaneously updating the code in the containers via the bind mount.

To run Combine in a more dev-friendly environment, follow these steps:

```
# navigate to ./mnt directory
cd ./mnt

# clone Combine GitHub repository
git clone https://github.com/wsulib/combine.git

# check out relevant branch or tag

# e.g. to checkout v0.5
git checkout tags/v0.5

# e.g. checkout dev branch
git checkout dev

# ensure combine/localsettings.py exists and is correct,
# create using Docker template if not
cp combine/localsettings.py.docker combine/localsettings.py
```

An example of `localsettings.py` that Docker copies to the containers for production deploys can be found here, relative to the `combine-docker` repo root: `./combine/localsettings.py`

Now you're ready to run -- and build if necessary -- containers using the `docker-compose.docker.yml` file (this compose file should be similar to `docker-compose.yml`, but differs primarily in ports exposed and volume mounts):
```
docker-compose -f docker-compose.dev.yml up -d
```

**Note:** If you tire of adding that extra `-f` flag each time, consider backing up `docker-compose.yml` to something like `docker-compose.prod.yml`, and moving `docker-compose.dev.yml` to `docker-compose.yml`, the default file that Docker Compose looks for.






















