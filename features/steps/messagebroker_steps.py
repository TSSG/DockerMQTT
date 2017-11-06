# Copyright Waterford Institute of Technology 2017
# Telecommunications Software and Systems Group (TSSG)
# Author Miguel Ponce de Leon <miguelpdl@tssg.org>

from behave import given, when, then, step
import docker
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

@when(u'I connect to the broker using a openfmb')
def step_impl(context):
    global testMQTTClientDockerContainer
    testMQTTClientDockerContainer = dockerClient.containers.get("reserve-openfmb-demo")
    time.sleep(15)

    #Assert that the docker container is running
    assert 'running' in testMQTTClientDockerContainer.status

@then(u'the appropriate-message Token is returned')
def step_impl(context):
    time.sleep(15)

    MQQTClientLogs = testMQTTClientDockerContainer.logs()

    #Assert that a message Token is been sent by the Client successfully to the Broker.
    assert 'Token' in MQQTClientLogs

@given(u'that I have the message broker bad name mgsbroker-local')
def step_impl(context):
    #Get a list of running containers on this machine
    #Set all = True for list of all the containers on the server
    listOfDockerContainers = dockerClient.containers.list()

    global badMsgBrokerRunning
    badMsgBrokerRunning = True
    #Does the list contain the words mgsbroker
    for container in range(len(listOfDockerContainers)):
        currentContainer = listOfDockerContainers[container]
        assert 'mgsbroker-local' not in currentContainer.name
        badMsgBrokerRunning = False

    #If it doesn't great
    #If it does make sure it's not another one (other than reserve-msgbroker-local) with port 1883 open.

@given(u'that bad name mgsbroker-local is in a state of not running')
def step_impl(context):
    assert badMsgBrokerRunning is False

@then(u'the appropriate-message Null is returned')
def step_impl(context):
    assert badMsgBrokerRunning is False
