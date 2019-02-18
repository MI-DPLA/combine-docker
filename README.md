# combine-docker

## Configuration

Where will this happen?  How can this most closely align with 

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


## [TODO](TODO.md)