#!/bin/bash

# Run the command with a parameter
# > ./dockerrun.sh

# Give the container a meaningful name
NAME_SERVO=servo-msgbroker

sudo ln -s /etc/letsencrypt/live/servomsgbroker.tssg.org/cert.pem $(pwd)/../src/cloud/conf/cert.pem
sudo ln -s /etc/letsencrypt/live/servomsgbroker.tssg.org/chain.pem $(pwd)/../src/cloud/conf/chain.pem
sudo ln -s /etc/letsencrypt/live/servomsgbroker.tssg.org/privkey.pem $(pwd)/../src/cloud/conf/privkey.pem

# Run the main container.
docker run \
    --name $NAME_SERVO \
    -p 1883:1883 -p 8883:8883 -p 9001:9001 \
    -u `id -u $USER` \
    -v $(pwd)/../src/cloud/conf/mosquitto.conf:/mosquitto/config/mosquitto.conf \
    -v $(pwd)/../src/cloud/conf/passwd:/mosquitto/config/passwd \
    -v $(pwd)/../src/cloud/conf/cert.pem:/mosquitto/config/cert.pem \
    -v $(pwd)/../src/cloud/conf/chain.pem:/mosquitto/config/chain.pem \
    -v $(pwd)/../src/cloud/conf/privkey.pem:/mosquitto/config/privkey.pem \
    -v $(pwd)/../src/cloud/log/:/mosquitto/log/ \
    -d -t servo/mosquitto
