#!/bin/bash

# Copyright Waterford Institute of Technology 2017
# Telecommunications Software and Systems Group (TSSG)
# Author Miguel Ponce de Leon <miguelpdl@tssg.org>

# Run the command with a parameter
# > ./dockerrun.sh -e prod reservemsgbroker.tssg.org

function iHelp () {
# Using a help doc with standard out.
cat <<-END
Usage:
------
  -e environment servername
    e.g. -e dev localhost, -e bridge localhost, -e prod reservemsgbroker.tssg.org
END
}

function run_container () {

# Run the main container.
docker run \
    --name ${CONTAINER_NAME} \
    --restart always \
    ${PORT} \
    -u `id -u $USER` \
    ${VOLUMES} \
    -d -t reserve/mosquitto

}


if [ -z "$1" ] ; then
 iHelp
 exit
else
 while [ -n "$1" ]; do
   case "$1" in
       -h | --help)
           iHelp
           exit
           ;;
       -e )
           if [ "$2" == "prod" ] ; then
             if [ -z "$3" ] ; then
              iHelp
              exit
            else
              # Since its a production deploy Secure SSL mode needs to link in the servers keys
              sudo ln -s /etc/letsencrypt/live/$3/cert.pem $(pwd)/../src/cloud-bridge/conf/certs/cert.pem
              sudo ln -s /etc/letsencrypt/live/$3/chain.pem $(pwd)/../src/cloud-bridge/conf/certs/chain.pem
              sudo ln -s /etc/letsencrypt/live/$3/privkey.pem $(pwd)/../src/cloud-bridge/conf/certs/privkey.pem

              # Give the container a meaningful name
              CONTAINER_NAME=reserve-msgbroker-ssl

              # Set the Secure MQTT port
              PORT="-p 8883:8883"

              # Set up the volumes to be attached
              VOLUMES="-v $(pwd)/../src/cloud-bridge/conf/mosquitto.conf:/mosquitto/config/mosquitto.conf -v $(pwd)/../src/cloud-bridge/conf/passwd:/mosquitto/config/passwd -v $(pwd)/../src/cloud-bridge/conf/certs/cert.pem:/mosquitto/config/certs/cert.pem -v $(pwd)/../src/cloud-bridge/conf/certs/chain.pem:/mosquitto/config/certs/chain.pem -v $(pwd)/../src/cloud-bridge/conf/certs/privkey.pem:/mosquitto/config/certs/privkey.pem -v $(pwd)/../src/cloud-bridge/log/:/mosquitto/log/ "

              #Run this Container
              run_container
              exit
            fi
           elif [ "$2" == "dev" ] ; then
             if [ -z "$3" ] ; then
              iHelp
              exit
            else
              # Give the container a meaningful name
              CONTAINER_NAME=reserve-msgbroker-local

              # Set the default MQTT port
              PORT="-p 1883:1883"

              # Set up the volumes to be attached
              VOLUMES="-v $(pwd)/../src/local/conf/mosquitto.conf:/mosquitto/config/mosquitto.conf -v $(pwd)/../src/local/log/:/mosquitto/log/ "

              #Run this Container
              run_container
              exit
            fi
          elif [ "$2" == "bridge" ] ; then
            if [ -z "$3" ] ; then
             iHelp
             exit
           else
             # Give the container a meaningful name
             CONTAINER_NAME=reserve-msgbroker-passwd-local

             # Set the Secure MQTT port
             PORT="-p 1885:1885"

             # Set up the volumes to be attached
             VOLUMES="-v $(pwd)/../src/bridge/conf/mosquitto.conf:/mosquitto/config/mosquitto.conf -v $(pwd)/../src/bridge/log/:/mosquitto/log/ "

             #Run this Container
             run_container
             exit
           fi
           else
             iHelp
             exit
           fi
           ;;
   esac

   iHelp
   exit
 done
fi
