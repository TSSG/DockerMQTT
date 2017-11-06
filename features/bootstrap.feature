Feature: Bootstrap
    As an Operator
    I want to be able to verify I have a message broker
    so I can interact with live message streams.

    @bootstrap
    Scenario Outline: Operator wants to be able to verify they have a message broker
      Given that I have the message broker
      Then I can start testing that message broker
