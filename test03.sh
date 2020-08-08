#!/bin/dash

# Testing ``
i=`expr 1 + 2`
i=`expr $i + $i + 0 - 2`
echo $i

# Testing $()
k=$((2 + $i))
echo $k

# Testing []
if [ $k != $i ]
then
    echo "$k is not equal to $i"
fi

# Testing -n
echo -n "Hello"
echo "Hello -n "
echo "Hello" -n
echo "-n -n -n -n -n -n -n -n"
