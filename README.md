Notes on using Packer, Vagrant and Docker
-----------------------------------------

#### Set up a docker vagrant box using packer

----

The following write up was instrumental in getting started and most of the configs and scripts are based on it.
http://blog.codeship.io/2013/11/07/building-vagrant-machines-with-packer.html


For this excercise, I tested on OSX and installed [Packer](http://www.packer.io/intro/getting-started/setup.html), [Vagrant](https://docs.vagrantup.com/v2/installation/) and [Virtualbox](https://www.virtualbox.org/wiki/Downloads).

If you want to jump right to checking out docker this is a good place to start: [Getting started with Docker](https://www.docker.io/gettingstarted/)

To start testing Docker and the other tools, you can clone this repo, change to the repo directory and run the create_box script.

Using Packer this script  will download an Ubuntu 13.10 iso, create a Virtualbox image preconfigured for Docker, export it and register it as a Vagrant box.


```
git clone git@github.com:floehmann/packer-vagrant-docker.git
cd packer-vagrant-docker/
./create_box
```

Once all that happens, one can verify the new box in vagrant, then fire it up and ssh in.


```
vagrant box list
vagrant up
vagrant ssh
```

#### Exploring docker

----

Most of these examples are directly from the docker site where there is an endless adventure of good docs.
http://docs.docker.io/en/latest/examples/hello_world/


To get info on your docker install run ```docker info```


**hello world**

Pull down a busybox image and check installed images.

```
docker pull busybox
docker images
```

Fire up a container and echo hello world.

```
docker run busybox /bin/echo hello world
```

The command above perform the following:

* "docker run" run a command in a new container
* "busybox" is the image we are running the command in.
* "/bin/echo" is the command we want to run in the container
* "hello world" is the input for the echo command


**hello world daemon**

```
ID=$(docker run -d ubuntu /bin/sh -c "while true; do echo hello world; sleep 1; done")
docker logs $ID
docker attach --sig-proxy=false $ID
```

Exit from the container attachment by pressing Control-C. And check out the container status.

```
docker ps
docker stop $ID
docker ps
```


**interactive bash shell**

```
docker run -i -t ubuntu /bin/bash
```

Use this chance to highlight the different name spaces between the container and the host with some commands like those below.

Ref: http://www.slideshare.net/jpetazzo/docker-introduction-meet-up-whats-new-0-9

```
hostname
uname -a
lsb_release -a
ps wwaxu  | wc -l
wc -l /proc/mounts
ip addr
ipcs
```


**django app**

Ref:
* http://developer.rackspace.com/blog/zero-to-peanut-butter-docker-time-in-78-seconds.html
* https://github.com/kencochrane/django-docker

```
docker pull kencochrane/django-docker
ID=$(docker run -d -p :8000 kencochrane/django-docker)
```

Inspect the container:

```
docker inspect $ID
```

Figure out the port mapping docker uses for NAT

```
docker port $ID 8000
```

Aside from being an awesome presentation following has some great info on networking:
http://www.slideshare.net/CohesiveFT/docker-meetup-london


Now you can start up a browser on your host and connect to the docker vm on the port returned above.


