## Docker Workshop 1

1. Review remaining aspects of the Lab on Chapter 1

[https://github.com/PacktPublishing/Docker-for-Developers-Handbook](https://github.com/PacktPublishing/Docker-for-Developers-Handbook)

2. Complete the following steps

- Run a hello world container
- Modify the storage driver. The default storage driver is overlay2. Let’s change it to devicemapper if we had to. Tip: modify the /etc/docker/daemon.json
- After running a container and checking the modification, change it back to overlay2.
- Execute a nginx with a particular version, such as 1.18.0
- Now, modify it to run it in the background
- Configure the Nginx to be named ngnix18, restart on failures and map the por 443 to the 80 on the container. Also, have 250M reserved and use an 18 version of Ngnix.
- Check the loggin drivers and change it to journald

3. Review examples and follow the Lab on Chapter 2  
   [https://github.com/PacktPublishing/Docker-for-Developers-Handbook](https://github.com/PacktPublishing/Docker-for-Developers-Handbook)
