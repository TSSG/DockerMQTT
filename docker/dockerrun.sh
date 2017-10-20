#!/bin/bash

# Run the command with a parameter
# > ./dockerrun.sh -e prod reservemsgbroker.tssg.org

function iHelp () {
# Using a help doc with standard out.
cat <<-END
Usage:
------
  -e environment servername
    e.g. -e dev localhost, -e prod reservemsgbroker.tssg.org
END
}

function run_container () {

# Run the main container.
docker run \
    --name ${CONTAINER_NAME} \
    ${PORT} \
    -u `id -u $USER` \
    ${VOLUMES} \
    -d -t servo/mosquitto

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
              sudo ln -s /etc/letsencrypt/live/$3/cert.pem $(pwd)/../src/cloud/conf/certs/cert.pem
              sudo ln -s /etc/letsencrypt/live/$3/chain.pem $(pwd)/../src/cloud/conf/certs/chain.pem
              sudo ln -s /etc/letsencrypt/live/$3/privkey.pem $(pwd)/../src/cloud/conf/certs/privkey.pem

              # Give the container a meaningful name
              CONTAINER_NAME=reserve-msgbroker-ssl

              # Set the Secure MQTT port
              PORT="-p 8883:8883"

              # Set up the volumes to be attached
              VOLUMES="-v $(pwd)/../src/cloud/conf/mosquitto.conf:/mosquitto/config/mosquitto.conf -v $(pwd)/../src/cloud/conf/passwd:/mosquitto/config/passwd -v $(pwd)/../src/cloud/conf/certs/cert.pem:/mosquitto/config/certs/cert.pem -v $(pwd)/../src/cloud/conf/certs/chain.pem:/mosquitto/config/certs/chain.pem -v $(pwd)/../src/cloud/conf/certs/privkey.pem:/mosquitto/config/certs/privkey.pem -v $(pwd)/../src/cloud/log/:/mosquitto/log/ "

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

              # Set the Secure MQTT port
              PORT="-p 1883:1883"

              # Set up the volumes to be attached
              VOLUMES="-v $(pwd)/../src/local/conf/mosquitto.conf:/mosquitto/config/mosquitto.conf -v $(pwd)/../src/local/log/:/mosquitto/log/ "

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
