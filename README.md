# Base Docker environment for the SERVO project
This is a Docker environment for a MQTT broker in SERVOLive.

## Building and Running the Docker Environment
[Docker](https://www.docker.com/) must be installed on the machine before anything can proceed.

In order to create a SERVOLive Docker container run the command

> make build

And let Docker do it's magic from there. Once the build is complete check that the Docker image is available with

> docker images

Should see an image called servo/mosquitto.

In order to run this image as a container for the first time run the script in the tools folder

> ./dockerrun.sh

In order to enter this Docker container type

> docker exec -it servo-msgbroker /bin/sh

You will be landed in to shell of the container and the main directory were the broker will be running.

In order to exit from the shell, CRTL-D.

In order to shutdown the running container use the command

> docker stop servo-msgbroker

To start the container again just type

> docker start servo-msgbroker 
