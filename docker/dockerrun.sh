#!/bin/bash

# Run the command with a parameter
# > ./dockerrun.sh

# Give the container a meaningful name
NAME_SERVO=servo-msgbroker

# Run the main container.
docker run \
    --name $NAME_SERVO \
    -p 1883:1883 -p 9001:9001 \
    -v $(pwd)/../src/cloud/conf/mosquitto.conf:/mosquitto/config/mosquitto.conf \
    -v $(pwd)/../src/cloud/log/:/mosquitto/log/ \
    -d -t servo/mosquitto
