Feature: print csvfile

   As a user
   I want to print labels
   So that I can get labels

   Scenario: print csvfile
	Given I am not yet playing
#	When I start app with 'print example/example-data-in.csv'
#	When I start app with 'print example/example-data.csv'
	When I start app with 'print "hello,label"'
