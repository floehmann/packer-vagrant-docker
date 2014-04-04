Packer, Vagrant and Docker
==========================

Set up a docker vagrant box using packer
----


The following write up was instrumental in getting started and most of the configs and scripts are based on it.
http://blog.codeship.io/2013/11/07/building-vagrant-machines-with-packer.html


For this excercise, I tested on OSX and installed [Packer](http://www.packer.io/intro/getting-started/setup.html), [Vagrant](https://docs.vagrantup.com/v2/installation/) and [Virtualbox](https://www.virtualbox.org/wiki/Downloads).

If you want to jump right to checking out docker this is a good place to start: [Getting started with Docker](https://www.docker.io/gettingstarted/)

To start testing Docker and the other tools, you can clone this repo, change to the repo directory and run the create_box script.

Using Packer this script  will download an Ubuntu 13.10 iso, create a Virtualbox image preconfigured for Docker, export it and register it as a Vagrant box.

NOTE: Virtualbox has been configured with a Host-only Network (vboxnet0) of 192.168.56.0/24 with no DHCP enabled.

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

Exploring docker
----


Most of these examples are directly from the docker site where there is an endless adventure of good docs.
http://docs.docker.io/en/latest/examples/hello_world/


To get info on your docker install run ```docker info```


**- hello world**

Pull down a busybox image and check installed images.

```
docker pull busybox
docker images
```

Fire up a container and echo hello world.

```
docker run busybox /bin/echo hello world
```

Here is an explanation of the above command: 

* "docker run" run a command in a new container
* "busybox" is the image we are running the command in.
* "/bin/echo" is the command we want to run in the container
* "hello world" is the input for the echo command


**- hello world daemon**

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


**- interactive bash shell**

We are going to run /bin/bash with the -i and the -t flags. -i tells Docker to keep stdin open even if not attached, and -t is to allocate a pseudo-tty. Once we run the command, we will be connected into the container, and all commands at this point are running from inside the container.

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


**- django app**

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


**- create an image** 

Ref: http://kencochrane.net/blog/2013/08/the-docker-guidebook/

A couple definitions to clarify:
* An "image" is a read only layer used to build a container. They do not change.
* A "container" is basically a self contained runtime environment that is built using one or more images. You can commit your changes to a container and create an image.

This exercise will demonstrate creating an image by commitng changes made to a container. 

As above run a container with an interactive bash shell  

```
$ docker run -i -t ubuntu /bin/bash  
root@10d9a4ca1750:/# hostname  
root@8c0a8dcbef7e:/# apt-get update  
root@8c0a8dcbef7e:/# apt-get install redis-server  
root@8c0a8dcbef7e:/# ps aux  
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND  
root         1  0.0  0.0  18048  1960 ?        Ss   10:05   0:00 /bin/bash  
root       123  0.0  0.0  15276  1132 ?        R+   10:11   0:00 ps aux  
root@8c0a8dcbef7e:/# exit
```

You can check the diffs in the container with ```docker diff```  
Files with (C) are changed and files with (A) are additions.

```
$ docker diff 8c0a8dcbef7e | head -15
A /.bash_history
C /dev
C /dev/console
C /dev/core
C /dev/fd
C /dev/ptmx
C /dev/stderr
C /dev/stdin
C /dev/stdout
C /etc
C /etc/bash_completion.d
A /etc/bash_completion.d/redis-cli
C /etc/group
C /etc/group-
C /etc/gshadow
```

Let's create the image with docker commit.  

```
$ docker commit <container id> <your username>/redis  
```

Here is that in action. You can see the new image id below.  

```
$ docker ps -a  
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES  
8c0a8dcbef7e        ubuntu:12.04        /bin/bash           12 minutes ago      Exit 0                                  thirsty_lumiere  
$ docker commit 8c0a8dcbef7e floehmann/redis  
453bf1dd96fcf069cf37806f5bcd5ca76c1af1da92a46fab306e77aaa4098f4b  
```
  
The new images will now be available to start new containers.   

```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
floehmann/redis     latest              453bf1dd96fc        21 minutes ago      225.8 MB
```

Let's test it out.

The -d tell docker to run it in the background, just like our Hello World daemon above. -p 6379 says to use 6379 as the port for this container.


```
$ docker run -d -p 6379 floehmann/redis /usr/bin/redis-server  
3e85a22fd31b69fa1c99d36f40bff6f8e07a0d9b6d2a747a338019400aac9625  
```

Connect to the public ip.

```
$ docker ps  
CONTAINER ID        IMAGE                    COMMAND                CREATED              STATUS              PORTS                     NAMES  
3e85a22fd31b        floehmann/redis:latest   /usr/bin/redis-serve   About a minute ago   Up About a minute   0.0.0.0:49154->6379/tcp   high_hawking  
```

Get the container ip address and connect with redis-cli.   

```
# docker inspect <container_id> | grep IPAddress
$ docker inspect 3e85a22fd31b | grep IPAddress  
        "IPAddress": "172.17.0.2",  
$ redis-cli -h 172.17.0.2 -p 6379    
172.17.0.2:6379> set docker awesome    
OK   
172.17.0.2:6379> get docker  
"awesome"  
172.17.0.2:6379> exit  
```


Connect to the public IP of the container.  

```
# docker port <container_id> 6379 
$ docker port 3e85a22fd31b 6379  
0.0.0.0:49154  
# grab the docker host ip addr
vagrant@docker-test:~$ ip addr show | grep 192.168.56  
    inet 192.168.56.5/24 brd 192.168.56.255 scope global eth1  
# connect to the docker host ip  
$ redis-cli -h 192.168.56.5 -p 49154  
192.168.56.5:49154> get docker  
"awesome"  
192.168.56.5:49154> exit  
```


**- removing all docker images and containers**

It may be handy after a while to clean up.

Remove all docker images:

```
docker rmi `docker images -a -q`
```

Remove all docker containers:

```
docker rm `docker ps -a -q`
```
