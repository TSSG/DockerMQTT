import docker
import os
import subprocess
from shutil import copyfile

def buildTestImage():
    #Build an image
    path = "../../docker/"
    rm = true
    tag = "servo/mosquitto"
    dockerClient.images.build(path, rm, tag)

def runOpenfmbClient(theDockerClient):
    global testMQTTClientDockerContainer

    if theDockerClient.images.get("reserve/openfmb-demo"):
        if theDockerClient.containers.get("reserve-openfmb-demo"):
            # Is the Docker container "servo-msgbroker-local" for dev to hand
            testMQTTClientDockerContainer = theDockerClient.containers.get("reserve-openfmb-demo")
            testMQTTClientDockerContainer.start()


def before_all(context):
    global cwd
    cwd = os.getcwd()
    global testDockerContainer

    #Git update in the requirements.wiki

    #Copy in the feature files
    src = cwd + "/requirements.wiki/user-stories/servo-live-user-stories/servo-live-us/operator-us/features/operator-sl-1.asciidoc"
    dst = cwd + "/features/operator-sl-1.feature"
    copyfile(src, dst)

    # Start the docker message broker we have to hand
    dockerClient = docker.from_env()

    # Is the Docker image servo/mosquitto available then use it
    if dockerClient.images.get("servo/mosquitto"):
        #Is the container already available then use it.
        try:
            #if dockerClient.containers.get("servo-msgbroker-local"):
            # Is the Docker container "servo-msgbroker-local" for dev to hand
            testDockerContainer = dockerClient.containers.get("servo-msgbroker-local")
            testDockerContainer.start()

            #Run the openfmb client
            runOpenfmbClient(dockerClient)

        except docker.errors.NotFound:
            #Run that image in a container
            dockerRunCommand = cwd + "/docker/dockerrun.sh"
            subprocess.call([dockerRunCommand, "-e", "dev", "localhost"])

            testDockerContainer = dockerClient.containers.get("servo-msgbroker-local")

            #Run the openfmb client
            runOpenfmbClient(dockerClient)

    else:
        #Build an image
        buildTestImage()

        #Run that image in a container
        image = "servo/mosquitto"
        name ="servo-msgbroker-local"
        ports = {'1883/tcp': 1883}
        volumes = {'./../src/local/conf/mosquitto.conf': {'bind': '/mosquitto/config/mosquitto.conf', 'mode': 'rw'},
        './../src/local/log/:/mosquitto/log/': {'bind': '/mosquitto/log/ ', 'mode': 'rw'}}
        detach = True

        testDockerContainer = dockerClient.containers.run(image, detach, name, ports, volumes)

        #Run the openfmb client
        runOpenfmbClient()


def after_all(context):
    testDockerContainer.stop()
    testMQTTClientDockerContainer.stop()
