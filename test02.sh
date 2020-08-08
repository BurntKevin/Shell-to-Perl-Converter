#!/bin/dash

# Aims to test subset 2

# Testing test and expr
i=5
j=3
k=$((10 - i - j))
echo $k

if test $((2 + 2 + 2 + $k)) -eq 8
then
    echo 1
fi

if ! test -r "very_unlikely_to_exist.file_extension"
then
    echo 2
fi

# Testing conditional statements
if test 5 -lt 2
then
    echo 3
elif test 2 -ge 3
then
    echo 4
else
    echo 5
fi

# Testing while loops
while (false)
do
    echo 6
done

i=2;
while test $i -ne 0
do
    i=`expr $i - 1`
    echo 7 @ $i
done

# Testing arguments given by user
echo $@
echo $1 $2 $3 $4 "\$5" $6 $7 $8 $9 $10 $11 $12 $1000
