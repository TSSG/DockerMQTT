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

> ./dockerrun.sh -e dev localhost

There are options environment options with the dockerrun.sh, for development mode and production.

-e dev localhost means it runs in a development mode with default port 1883 open.

-e prod servomsgbroker.tssg.org means the broker is run in full secure mode, with password file enabled and the SSL certs need to be in place.

To see whether the broker is up and running have a look in the log files

> less ../src/cloud/log/mosquitto.log

In order to enter this Docker container type

> docker exec -it servo-msgbroker-local /bin/sh

You will be landed in to shell of the container and the main directory were the broker will be running.

In order to exit from the shell, CRTL-D.

In order to shutdown the running container use the command

> docker stop servo-msgbroker-local

To start the container again just type

> docker start servo-msgbroker-local

There is also a Python based test framework for the broker.

It might be worth running this in a virtual environment.

> pip install virtualenv
> virtualenv servo-mqtt-env
> source servo-mqtt-env/bin/activate

To check for the Python dependancies do

> pip install -r requirements.txt

To initialise the test framework run this command once

> behave --tags=bootstrap

You must have built a Docker version of the openfmb client as a container in your environment for this test to work.

To run the first tests do

> behave --tags=verifymessagebroker
