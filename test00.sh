#!/bin/dash
# Aims to test subset 0

# Testing = syntax
a="Andrew";
b="Rocks"
c="!!!";
a=b=c="Goo";

# Testing $
e=$c
d=$c=$b

# Testing comments
# Single line comment
# Comment # Ontop of another # Comment \n

# Testing echo
# Printing out previous test variables
echo $a
echo $b
echo $c
echo $d
echo $e
echo $f
# Difficult to pass - randomly placed special characters
echo $""$1"@ARGV""\"Hello ''\\''\'''\\\\"''\'\'

# Style check - handling new lines - should maintain style




# Event
