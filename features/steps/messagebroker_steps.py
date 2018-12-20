# Copyright Waterford Institute of Technology 2017 - 2018
# Telecommunications Software and Systems Group (TSSG)
# Author Miguel Ponce de Leon <miguelpdl@tssg.org>

from behave import given, when, then, step
import docker
from paho.mqtt import client as mqtt
import json
import time

@given(u'that I have the message broker reserve-msgbroker-local')
def step_impl(context):
    global dockerClient
    dockerClient = docker.from_env()
    global testMQTTBrokerDockerContainer

    testMQTTBrokerDockerContainer = dockerClient.containers.get("reserve-msgbroker-local")

    #Assert that the docker container is running
    assert 'running' in testMQTTBrokerDockerContainer.status

@given(u'that reserve-msgbroker-local is in a state of running')
def step_impl(context):

    containerTopCmdResult = json.dumps(testMQTTBrokerDockerContainer.top())

    #Assert that the Mosquitto app is running in the container
    assert 'mosquitto' in containerTopCmdResult

@when(u'I connect to the broker using a mqttclient')
def step_impl(context):
    global clientConnected

    def on_connect(client, userdata, flags, rc):
        global clientConnected, resultCode
        clientConnected = True
        resultCode = rc
        print ("Test device connected with result code: " + str(rc))
    def on_disconnect(client, userdata, rc):
        print ("Test device disconnected with result code: " + str(rc))
    def on_publish(client, userdata, mid):
        print ("Test device sent message")

    global device_id, iot_hub_name

    device_id = "test_client_"+str(time.time())
    iot_hub_name = "localhost"
    clientConnected = False

    client = mqtt.Client(client_id=device_id)

    client.on_connect = on_connect
    client.on_disconnect = on_disconnect
    client.on_publish = on_publish

    client.connect(iot_hub_name, port=1883)

    client.loop_start()
    time.sleep(2)

    #Assert that the docker container is running
    assert clientConnected is True

@then(u'the appropriate-message Token is returned')
def step_impl(context):

    #Assert that 0: Connection successful is sent back to the Client which
    # has successfully connected to the Broker.
    assert "0" in str(resultCode)
