# Combine-Docker


## Overview

This repository provides a "Dockerized" version of [Combine](https://github.com/wsulib/combine.git).

### Hoes does it work?

Major components that support Combine -- all installed on a single server when building via the [Combine-Playbook](https://github.com/wsulib/combine-playbook.git) ansible route -- have been broken out into distinct Docker images and containers.  Using [Docker Compose](https://docs.docker.com/compose/), each of these major components is associated with a **service**.  Some share base images, others are pulled from 3rd party Docker images (like ElasticSearch and Mongo).

Docker compose provides a way to interact with all the containers that support Combine at once, even providing some improved ability to view logs, restart services, etc.


## Configuration

Modify Combine app configurations before Docker images are built.  While the file is already tailored to look for Docker containers, users may still want to add values like S3 or DPLA API keys:
```
./combine/localsettings.py
```


## Installation and First Build

The first step is to clone this repository and move into it:
```
git clone https://github.com/wsulib/combine-docker.git
cd combine-docker
```

Next, run the `first_build.sh` script:
```
./first_build.sh
```

**Note:** This script may take some time, anywhere from 5-20 minutes depending on your hardware.  This script accomplishes a few things:

  * initializes Combine Django app as Git submodule at `./combine/combine`
  * builds all required docker images
  * runs one-time database initializations and migrations


## Running and Managing

Ensuring that `first_build.sh` (or `update_build.sh` if appropriate) has been run, fire up all containers with the following:
```
docker-compose up -d
```

As outlined in the [Combine-Docker Containers](#docker-images-and-containers) section all services, or a subset of, can be restarted as follows:
```
# e.g. restart Combine Django app, background tasks Celery, and Livy
docker-compose restart combine-django combine-celery

# e.e. restart everything
docker-compose restart
```

Logs can be viewed with the `logs` command, again, selecting all services, or a subset of:
```
# tail all logs
docker-compose logs -f

# tail logs of specific services
docker-compose logs -f combine-django combine-celery livy

```

## Updating

This dockerized version of Combine supports, arguably, easier version updating becaues major components, broken out as images and containers, can be readily rebuilt.  Much like the repository Combine-Playbook, this repository follows the same versioning as Combine.  So checking out the tagged release `v0.7` for this repository, will build Combine version `v0.7`.

To update, follow these steps from the Combine-Docker repository root folder:

```
# pull new changes
git pull

# checkout desired release, e.g. v0.7
git checkout v0.7

# run update build script
./update_build.sh
```

Finally, start Combine-Docker as normal with:
```
docker-compose up -d
```


## Docker Images and Containers

This dockerized version of Combine includes the following containers:

| Service Name          | Internal Network IP | Notes                                                      |
| --------------------- | ------------------- | ---------------------------------------------------------- |
| **host machine**      | `10.5.0.1`          | not a container, but part of internal network              |
| `elasticsearch`       | `10.5.0.2`          |                                                            |
| `mongo`               | `10.5.0.3`          |                                                            |
| `mysql`               | `10.5.0.4`          |                                                            |
| `redis`               | `10.5.0.5`          |                                                            |
| `hadoop-namenode`     | `10.5.0.6`          |                                                            |
| `hadoop-datanode`     | `10.5.0.7`          |                                                            |
| `spark-master`        | `10.5.0.8`          | not currently used                                         |
| `spark-worker`        | `10.5.0.9`          | not currently used                                         |
| `combine-django`      | `10.5.0.10`         |                                                            |
| `livy`                | `10.5.0.11`         | location of spark application running in `local[*]` mode   |
| `combine-celery`      | `10.5.0.12`         |                                                            |


## Troubleshooting

### ElasticSearch container dies because of `vm.max_map_count`

Depending on machine and OS (Linux, Mac, Windows), might need to bump `vm.max_map_count` on Docker host machine (seems to be particulary true on older ones):
[https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode)

### Port collision error: `port is already allocated`

By default, nearly all relevant ports are exposed from the containers that conspire to run Combine, but these can turned off selectively (or changed) if you have services running on your host that conflict.  Look for the `ports` section for each service in the `docker-compose.yml` file you're running.


## Development

The Combine Django application, where most developments efforts are targeted, is a [bind mount volume](https://docs.docker.com/storage/bind-mounts/) from the location of this cloned repository on disk at `./combine/combine`.  Though the application is copied to the docker images during build, to support the installation of dependencies, the location `/opt/combine` is overwritten by this bind volume at `docker-compose up` or `run`.  This allows live editing of the local folder `./combine/combine`, which is updating the folder `/opt/combine` in services `combine-django`, `combine-celery`, and `livy`.



