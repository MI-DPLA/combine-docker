# DRAFT COMBINE-DOCKER v0.11.1.   Installation Instructions DRAFT  
  
## TOC  
1.  Introduction  
2.  Requirements  
3.  Installing Combine-Docker and dependencies  
4.  Migrating data from previous versions of Combine  
5.  Troubleshooting  


## 1.  INTRODUCTION  
Combine is a metadata aggregator; an application designed to facilitate the harvesting, transformation, analysis, and republishing of metadata records.  Combine can be used by Service Hubs for inclusion in the Digital Public Library of America (DPLA).  

Combine-Docker is a version of Combine that has been "dockerized"; preconfigured to run in a set of Docker containers.  

These technical instructions are for metadata experts or system administrators who wish to install Combine-Docker on their institution's servers to process and publish metadata records to DPLA. This version of Combine (v0.11.1) includes a number of bug fixes and improvements. The [version change documentation](https://github.com/fruviad/combine-docker/blob/master/combine_version_change_log.pdf) is available with details about the release.  

These installation instructions have been tested on Ubuntu Server 20.04.  

These instructions are for installing v0.11.1 of Combine-Docker, and include steps for migrating from an earlier version of Combine.  Docker is now required; the Vagrant/Ansible installation options are no longer supported.  

You can add support issues for Combine via github at [https://github.com/fruviad/combine](https://github.com/fruviad/combine).  


## 2.  REQUIREMENTS

To install Combine-Docker in your own environment, you must have:  

* A Linux server on which you have superuser privileges (i.e. you can run sudo commands or have the `root` password).  In the instructions that follow, a non-`root` user is assumed to be the user account you'll use for running Combine.  
* A new Combine installation will consume ~10 Gb of drive storage.  You will need additional storage proportional to the amount of data you're working with.  (`adduser combine`, `usermod -a -G sudo combine`)
* Virtual Memory / `vm.max_map_count` set to at least 262144.  
    * To check the current setting for this value on your server, run:  `sysctl vm.max_map_count`
    * To change the value on your server, update the `/etc/sysctl.conf` file and reboot  
* If you are migrating from an older release of Combine, then plan to have enough storage to run the old and new Combine instances in parallel while migrating data, plus the space needed for the exported state data files from the older version. Note that some of the Docker images are large!


## 3.  INSTALLING COMBINE-DOCKER AND DEPENDENCIES
  
We start by cloning the git repository `https://github.com/fruviad/combine-docker.git` to the location on your server where you wish to install the Combine application.  (Choosing `/opt/combine-docker` is not required, but it offers consistency with the old installation methods.  The documentation which follows uses `/opt/combine-docker` as the installation location.)

After you login to the server as the user who will be running the Combine application...  

        $ sudo mkdir /opt/combine-docker
        $ sudo chown ${USER}:${USER} /opt/combine-docker
        $ cd /opt/
        $ git clone https://github.com/fruviad/combine-docker.git

Next, install Docker as described here:  https://docs.docker.com/engine/install/ubuntu/

Add the current user to the docker group.  This allows docker commands to be run without sudo, and is needed for docker-compose:

        $ sudo usermod -aG docker ${USER}

More dependencies:  Install Docker-Compose:  

        $ sudo apt install docker-compose

Still more dependencies:  Install Subversion, which is needed to pull down the spark/livy static files without pulling down the entire repository:  

        $ sudo apt install subversion

Logout, then login again as the user running your Combine service.  This forces the changes to the user account to take effect:  

        $ logout

Now we begin installing Combine-Docker.  Go back to the Combine installation directory and setup our git environment.  This is needed by the `build.sh` shell script which we run next:

        $ cd /opt/combine-docker
        $ git checkout master
        $ git submodule init
        $ git submodule update

Finally, we run the `build.sh` script which retrieves the appropriate Docker images and sets everything up on the local system.  This script can run for quite a while (it's downloading a bunch of data which can be a bottleneck) and it produces a ton of output:

        $ ./build.sh

The output produced by `build.sh` can contain many warnings that are safe to ignore (for instance, Livy wants to build off a Zinc server, throws a warning when it doesn't find one).  Additionally, the first time `build.sh` is run you will see several "No such volume" errors in the output at the beginning of the process (e.g. "Error: No such volume: combine-docker_combine_python_env"); these are not problematic.

Assuming all went well (knock on wood) Combine is now installed and needs to be configured.

The Nginx web server used as the Combine user interface will, by default, only answer requests made to "127.0.0.1" a.k.a. "localhost"; you will need to update the configuration to expose additional IPs/ports to allow other systems to access Combine.  Edit the `/opt/combine-docker/docker-compose.yml` file.  The "nginx:" section (around line 240 of the file) contains a "ports:" section that looks like:

        ports:
        - "127.0.0.1:80:80"
        - "127.0.0.1:443:443"

If your server has an IP address 11.12.13.14, and you also wish to make Combine available on ports 80 and 28080 of that IP address, you would adjust that "ports" section accordingly:

        ports:
        - "127.0.0.1:80:80"
        - "127.0.0.1:443:443"
        - "11.12.13.14:28080:80"
        - "11.12.13.14:80:80"

That's it.  You now just need to start the Docker containers to get Combine running:

        $ docker-compose up

Docker will attempt to run the containers, and the containers will dump output to this terminal window; Closing this window or hitting Control-C will kill the Combine application.  (The output dumped to this window is a firehose of debugging information that can be handy when you're trying to solve problems.)

Point a web browser at the IP/hostname & port you configured Nginx to listen to (e.g. http://11.12.13.14:28080).

If all is working well, then you should be presented with a login screen; Login with username `combine` and password `combine`.


## 4  MIGRATING DATA FROM PREVIOUS VERSIONS OF COMBINE

Background: Exporting and Importing of "States" in Combine is the ability to select various level of hierarchy (Organizations, Record Groups, and/or Jobs), and optionally Configuration Scenarios (OAI Endpoints, Transformations, Validations, etc.), and export to a fully serialized, downloadable, archive file.  This file can then be imported into the same, or another, instance of Combine and reconstitute all the pieces that would support those Jobs and Configurations.

NOTE:  If your old Combine has more than one user account, make sure you create the SAME NUMBER OF USERS for your new Combine. This is an unfortunate required workaround for the moment to import your existing Combine data.  

To add users to the new Combine, you have a few options:

- Use the "Configuration" menu item in the top navigation bar then the "Django Admin Console" button at the top of the page. Then click "Home" in the breadcrumbs bar to get to the Django administration page and click the "Users" link, or
- Enter ${url}:28080/admin into your browser's address bar to get to the Django administration page and click the Users link.


If everything's working, try exporting everything from your old Combine.  Your options are:

- You can get to State Export/Import using the "Configuration" menu item in the top navigation bar then scroll down to the bottom of the page to find the “State Export/Import” button, or
- At ${url}/combine/stateio/export (type this into your browser address bar).

Click the "Export State" button and on the next page select everything you want to export and again click the "Export State" button. The export process may take a while or get stuck if it runs out of space.  (NOTE:  This is a point at which you might run out of disk space and may need to work with your system support to have more allocated.)

Now you will need to find the export on disk and put it somewhere that the new Combine can see.

In theory, with all settings at default, the following should work:

1. docker exec -it combine-docker_combine-django_1 /bin/bash  
2. cd /home/combine/data/combine/stateio/exports (or the STATEIO_EXPORT_DIR from localsettings.py)  
3. Find the .zip file you just created  
4. cp ${blah}.zip /opt/combine (/opt/combine in both combine-django and combine-celery should be the same mapped docker volume)  
5. Go to import page and import from filesystem with path /opt/combine/${blah}.zip  

IF your version of Combine is old enough that it still has the bug where jobs with no upstream or downstream job can't be exported, you can work around that by creating a meaningless Analysis job that takes all the singletons as inputs.

Each imported job has a button that allows you to rebuild the elasticsearch index for that job. (U. Michigan is looking into a more global way to do this.)


## 5  TROUBLESHOOTING

__Problem:  Seeing "waiting for MySQL container to be ready", but it never becomes ready?__

__Tip:__  That MySQL Docker container is being started by the script `/opt/combine-docker/combine/combine_db_prepare.sh`.  Try running the commands listed in that script interactively to see where it errors out, and if any more useful error information is displayed when running it interactively.

---

__Problem:  Port collision error: port is already allocated__

__Tip:__  By default, nearly all relevant ports are exposed from the containers that conspire to run Combine, but these can turned off selectively (or changed) if you have services running on your host that conflict. Look for the ports section for each service in the docker-compose.yml to enable or disable them.

---

__Problem:  When I point my browser at Combine, I get a "Connection Refused" error.__

__Tip:__  Check the nginx configuration in the `/opt/combine/docker-compose.yml` file.  

By default, the Combine web service is only available to "localhost", so IF you haven't updated the "ports" section for nginx in the `docker-compose.yml` file AND you are not pointing your web browser at either "localhost" or "127.0.0.1" for the Combine URL, then this will occur.  

From `/opt/combine/docker-compose.yml`, in which Combine has been opened up to the 192.168.122.224 IP address:

        240 
        241   nginx:
        242     image: nginx:latest
        243     container_name: nginx
        244     volumes:
        245       - ./nginx/nginx.conf:/etc/nginx/nginx.conf
        246       - ./nginx/mime.types:/etc/nginx/mime.types
        247       - ./nginx/error.log:/etc/nginx/error_log.log
        248       - ./nginx/cache/:/etc/nginx/cache
        249       - ./combine/combine/static:/static
        250 # when using not certbot for SSL, uncomment this line:
        251 #      - /etc/ssl:/etc/ssl
        252 # when using certbot for SSL, uncomment these lines:
        253 #      - ./certbot/conf:/etc/letsencrypt
        254 #      - ./certbot/www:/var/www/certbot
        255     ports:
        256       - "192.168.122.224:80:80"
        257       - "192.168.122.224:443:443"
        258       - "127.0.0.1:80:80"
        259       - "127.0.0.1:443:443"
        260     depends_on:
        261       - combine-django
        262       - combine-celery

Note:  When you're entering a new `ports` option, be aware that the port is listed twice.  It's easy to make the mistake of automatically entering `host:port`, in which case the `docker-compose up` command will error out with:

        ERROR: The Compose file './docker-compose.yml' is invalid because:
        services.nginx.ports contains an invalid type, it should be a number, or an object

---

__Problem:  java.lang.ClassNotFoundException: org.elasticsearch.hadoop.mr.LinkedMapWritable__

__Fix:__  Make sure that the elasticsearch-hadoop-x.y.z.jar in combinelib matches the version
specified in the ELASTICSEARCH_HADOOP_CONNECTOR_VERSION environment variable
configured in your .env.

---

__Problem:  Seeing DNS errors__

__Fix:__  It is possible that Docker isn't aware of your DNS server.  Edit the `/etc/docker/daemon.json` file (or add it, if it doesn't exist already) and add the following to the file:

        {
            "dns": ["{your DNS server address}"]
        }

Then make the docker service read the new service configuration with:

        sudo systemctl reload docker


You can test if DNS is even kind of working with:

        docker run busybox /bin/sh -c "nslookup github.com"

If that times out, nothing at all is working.  Search Google for the terms "docker resolved" for a set of results that might prove helpful.
