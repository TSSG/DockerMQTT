@messagebroker
Feature: Message Broker
    As an Operator
    I want a message broker
    so I can interact with live message streams.

    @verifymessagebroker
    Scenario Outline: Operator wants to verify the message broker
      Given that I have the message broker <named>
      Given that <named> is in a state of <runningstate>
      When I connect to the broker using a <client>
      Then the appropriate-message <appropriate-message> is returned

    Examples:
      |named|runningstate|client|appropriate-message|
      |servo-msgbroker-local|running|openfmb|Token|
      |bad name mgsbroker-local|not running|openfmb|Null|


    @verifymessagebrokerauth
    Scenario Outline: Operator wants to verify the message broker authentication
      Given that I have the message broker <named> with user names set
      Given that <named> is in a state of <runningstate>
      When I connect to the broker using a <client> with specific username <username>
      Then the appropriate-message <appropriate-message> is returned

    Examples:
      |named|runningstate|client|username|appropriate-message|
      |servo-msgbroker-local|running|openfmb|servo|Token|
      |bad name msgbroker-local|not running|openfmb|service|Null|
