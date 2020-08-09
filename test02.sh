#!/bin/dash

# Aims to test subset 2

# Testing test and expr
# Testing in the assignment environment
i=5
j=3
k=$((10 - i - j))
echo $k

# Testing in the condition environment
if test $((2 + 2 + 2 + $k)) -eq 8
then
    # Testing in the echo environment
    echo "$((2 + 2 + 2 + $k)) equals 8"
else
    # Testing in the echo environment
    echo "$((2 + 2 + 2 + $k)) does not equal to 8"
fi

# Testing test flags for files
# Testing with a non-standard initial test string
if ! test -r "very_unlikely_to_exist.file_extension"
then
    echo "Could not find a file which was very unlikely to exist"
else
    echo "Found a file which was very unlikely to exist"
fi

# Testing conditional statements
if test 5 -lt 2
then
    echo 5 is less than 2
elif test "5" -eq "2"
then
    echo "5" is equal to "2"
else
    echo Passed conditional statements
fi

# Testing with two conditional statements
if test 5 -lt 2 && test 10 -lt 3
then
    echo 5 is less than 2 and 10 is less than 3
fi

# Testing with three conditional statements
if test 5 -lt 2 && test 10 -lt 3 || test 10 -gt 0
then
    echo 10 is greater than 0
fi

# Testing while loops
# Using a special variable
while false
do
    echo Entered into a false condition loop!
done

# Using a while loop
i=2
while test $i -ne 0
do
    i=`expr $i - 1`
    echo Count down from 1 to 0 - $i
done

# Using a while loop with multiple conditions
i=2
while ! test -r "non-existent-file" && test $i -ne 0
do
    i=`expr $i - 1`
    echo Count down from 1 to 0 - $i
done

# Testing arguments given by user
echo Here are some of the arguments you gave me!: $1 $2 $3 $4 $5 $6 $7 $8 $9
echo Here are some strange arguments: $11 $12 $1000
