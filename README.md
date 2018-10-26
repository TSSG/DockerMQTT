# Base Docker environment for the Eclipse Mosquitto MQTT broker
This is a Docker environment for the Eclipse Mosquitto MQTT broker to be deployed as a docker container with some special configurations for running it in a default mode and a fully secure mode.

## Building and Running the Docker Environment
[Docker](https://www.docker.com/) must be installed on the machine before anything can proceed.

In order to create this MQTT Docker container you must be in the <docker> folder and run the command

> make build

And let Docker do it's magic from there. Once the build is complete check that the Docker image is available with

> docker images

Should see an image called reserve/mosquitto.

In order to run this image as a container for the first time run the script in the tools folder

> ./dockerrun.sh

The output from this command will show that the container can be run in a development mode "dev" and a production mode "prod". I both cases a server name needs to be provided.
In the development mode setting the servername as localhost is fine and of note port 1883 will be exposed for the MQTT connection.
In production mode username / password and SSL access is set on the instancei and port 8883 is exposed for MQTT client connections.
It is key that the correct FQDN for the server is provided on this line when deploying in production mode too as only those certs will be taken in and set on the MQTT configuration.
This docker container also assumes that the SSL certs have been generated using Let's Encrypt.

Now run the command in the preferred mode

> ./dockerrun.sh -e dev localhost

or

> ./dockerrun.sh -e prod reservemsgbroker.tssg.org

-e bridge localhost means it runs as a broker bridge to another mqtt broker with default port 1885 open.

-e prod reservemsgbroker.tssg.org means the broker is run in full secure mode, with password file enabled and the SSL certs need to be in place.

To see whether the broker is up and running have a look in the log files

> less ../src/cloud-bridge/log/mosquitto.log

In order to enter this Docker container when in development mode type the command

> docker exec -it reserve-msgbroker-local /bin/sh

In order to enter this Docker container when in production mode type the command

> docker exec -it reserve-msgbroker-ssl /bin/sh

You will be landed in to shell of the container and the main directory were the broker will be running.

In order to exit from the shell, CRTL-D.

In order to shutdown the running development container use the command

> docker stop reserve-msgbroker-local

To start the container again just type

> docker start reserve-msgbroker-local

When in production mode use the container name reserve-msgbroker-ssl instead.

> docker stop reserve-msgbroker-ssl

To start the container again just type

> docker start reserve-msgbroker-ssl

There is also a Python based test framework for the broker.

It might be worth running this in a Python virtual environment.

> pip install virtualenv

> virtualenv reserve-mqtt-env

> source reserve-mqtt-env/bin/activate

To check for the Python dependancies do

> pip install -r requirements.txt

To initialise the test framework run this command once

> behave --tags=bootstrap

You must have built a Docker version of the openfmb client as a container in your environment for this test to work.

To run the first tests do

> behave --tags=verifymessagebroker

Copyright Waterford Institute of Technology 2017, Telecommunications Software and Systems Group (TSSG), Author Miguel Ponce de Leon <miguelpdl@tssg.org>
