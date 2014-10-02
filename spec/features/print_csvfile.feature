Feature: print csvfile

   As a user
   I want to print labels
   So that I can get labels

   Scenario: print csvfile
	Given I am not yet playing
	When I start app with 'print -n example/example-data-in.csv --printer="Example Printer"'
