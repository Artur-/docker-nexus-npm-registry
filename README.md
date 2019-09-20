# docker-nexus-npm-registry

A Docker image with a local npm and Maven repository for Vaadin projects, populated by the dependencies needed for Vaadin 14. 

It contains an extension of the **Dockerfile** of [Nexus3](https://github.com/sonatype/docker-nexus) for [Docker](https://www.docker.com/)'s.

## Installation

1. Install [Docker](https://www.docker.com/).

2. Clone this repository 
    `git clone https://github.com/Artur-/docker-nexus-npm-registry`

3. Build the image   
    `docker build -t nexus .`

4. Create a folder where the Nexus cache is stored
    `mkdir data`

5. Start the proxy and populate the cache
    `docker run -p 8081:8081 --mount type=bind,source="$(pwd)/data",target=/nexus-data nexus`

6. Wait for the build process to complete. It can take a while. It is done when you see
```
================

Caches populated

================
```

7. Export the container to a file and stop it
```
CONTAINER_ID=`docker ps|grep nexus|cut -f1 -d' '`
docker commit $CONTAINER_ID nexus-populated
docker save nexus-populated -o nexus-proxy.tgz
docker kill $CONTAINER_ID
```

8. Compress the `data` folder for transfer to an offline host
```
tar zcvf data.tgz data/
```

9. Copy data.tgz && nexus-proxy.tgz to the offline machine

On the offline machine in a selected target folder

1. Uncompress the data folder
```
tar zxvf data.tgz
```
2. Setup Docker from the stored container
```
docker load -i nexus-proxy.tgz
```
3. Start the offline Docker
```
docker run -dit -p 8081:8081 --mount type=bind,source="$(pwd)/data",target=/nexus-data nexus-populated
```
4. After a while, the Nexus proxy will be running at http://localhost:8081

## Using the proxy

### npm

To configure the same machine or another machine in the offline network to use the npm proxy:

```
npm config set registry http://localhost:8081/repository/npmjs-org/
```

Use the ip address instead of "localhost" if using from another machine

### Maven
To configure the same machine or another machine in the offline network to use the Maven proxy add the following to ~/.m2/settings.xml

```
<settings>
  <mirrors>
    <mirror>
      <id>internal-nexus</id>
      <name>Internal Nexus</name>
      <url>http://localhost:8081/repository/maven-central/</url>
      <mirrorOf>*</mirrorOf>
    </mirror>
  </mirrors>
</settings>
```

Use the ip address instead of "localhost" if using from another machine

## Checking the available dependencies

To check the content of the npm registry you can go to [localhost:8081](http://localhost:8081/) and login with username "admin" and password "admin123".
