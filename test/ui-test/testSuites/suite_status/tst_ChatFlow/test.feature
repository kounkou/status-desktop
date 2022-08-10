# This is a sample .feature file
# Squish feature files use the Gherkin language for describing features, a short example
# is given below. You can find a more extensive introduction to the Gherkin format at
# https://cucumber.io/docs/gherkin/reference/
Feature: Status Desktop Chat

	# TODO The complete feature / all scenarios have a chance to fail since they rely on the mailserver (at least, to verify a chat is loaded, something in the history needs to be displayed).
    As a user I want to join a room and chat and do basic interactions.

    The following scenarios cover basic chat flows.

    Background:
         Given A first time user lands on the status desktop and generates new key
    	 When user signs up with username tester123 and password TesTEr16843/!@00
    	 Then the user lands on the signed in app

    Scenario: User joins a public room and chats
		 When user joins chat room test
		 Then user is able to send chat message
		 | message  			 |
		 | Hello    			 |
		 | How are you    		 |
		 | I am from status   	 |
		 | tell me how you do?   |


    Scenario: User can reply to their own message
         When user joins chat room test
         Then user is able to send chat message
         | message               |
         | Reply to this         |
         Then the user can reply to the message at index 0 with "This is a reply"


    # TODO This test has a chance to fail since it relies on the mailserver. Until we host a local mailserver for the tests, this test is at risk
#    Scenario: User can reply to another user's message
#         When user joins chat room test
#         Then the user can reply to the message at index 0 with "This is a reply to another user"


    Scenario: User joins a room and marks it as read
		 When user joins chat room test
		 Then the user can mark the channel test as read
         # TODO find a way to validate that it worked


    Scenario: User can delete their own message
         When user joins chat room automation-test
         Then user is able to send  a random chat message
         Then the user can delete the message at index 0
         Then the last message is not the random message


    # TODO This test has a chance to fail since it relies on the mailserver. Until we host a local mailserver for the tests, this test is at risk
 #   Scenario: User cannot delete another user's message
 #        When user joins chat room test
 #        Then the user cannot delete the last message

#	Scenario Outline: The user can do a mention
#		When user joins chat room test
#		And the user inputs a mention to <displayName> with message <message>
#		Then the <displayName> mention with message <message> have been sent
#	Examples:
#		| displayName | message          |
#		| tester123   |  testing mention |

#	Scenario Outline: The user can not do a mention to not existing users
#		When user joins chat room test
#		Then the user cannot input a mention to a not existing user <displayName>
#	Examples:
#		| displayName        |
#		| notExistingAccount |
#		| asdfgNoNo          |