# Copyright Waterford Institute of Technology 2017
# Telecommunications Software and Systems Group (TSSG)
# Author Miguel Ponce de Leon <miguelpdl@tssg.org>

import docker
import os
import subprocess
from shutil import copyfile

def buildTestImage(theDockerClient):
    #Build an image
    kwargs = {'path': '../../docker/', 'rm': True, 'tag':'reserve/mosquitto' }

    theDockerClient.images.build(**kwargs)

def runOpenfmbClient(theDockerClient):
    global testMQTTClientDockerContainer

    if theDockerClient.images.get("reserve/openfmb-demo"):
        if theDockerClient.containers.get("reserve-openfmb-demo"):
            # Is the Docker container "reserve-msgbroker-local" for dev to hand
            testMQTTClientDockerContainer = theDockerClient.containers.get("reserve-openfmb-demo")
            testMQTTClientDockerContainer.start()


def before_all(context):
    global cwd
    cwd = os.getcwd()
    global testDockerContainer

    # Start the docker message broker we have to hand
    dockerClient = docker.from_env()

    # Is the Docker image reserve/mosquitto available then use it
    try:
        dockerClient.images.get("reserve/mosquitto")

    except docker.errors.NotFound:
        #buildTestImage(dockerClient)
        imageDockerFile = cwd + "/docker"
        kwargs = {'path': imageDockerFile, 'rm': True, 'tag':'reserve/mosquitto' }

        dockerClient.images.build(**kwargs)

    if dockerClient.images.get("reserve/mosquitto"):
        #Is the container already available then use it.
        try:

            # Is the Docker container "reserve-msgbroker-local" for dev to hand
            testDockerContainer = dockerClient.containers.get("reserve-msgbroker-local")

            #If so then run it
            testDockerContainer.start()

        except docker.errors.NotFound:
            #As the container does not exist then run that image in a container
            image = "reserve/mosquitto"
            command = ''

            confvol = cwd + "/src/local/conf/mosquitto.conf"
            logvol = cwd + "/src/local/log/"

            kwargs = {'name': 'reserve-msgbroker-local',
            'ports':{'1883/tcp': 1883},
            'volumes': {confvol: {'bind': '/mosquitto/config/mosquitto.conf', 'mode': 'rw'},logvol: {'bind': '/mosquitto/log/ ', 'mode': 'rw'}},
            'detach': True }

            testDockerContainer = dockerClient.containers.run(image, command, **kwargs)


def after_all(context):
    testDockerContainer.stop()
