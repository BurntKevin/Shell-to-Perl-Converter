#!/bin/dash

# Testing ``
i=`expr 1 + 2`
i=`expr $i + $i + 0 - 2`
echo $i

# Testing $()
j=$(expr 1 + $i)
echo $j

# Testing $(()))
k=$((2 + $i))
echo $k

# Testing []
# Single condition
if [ $k != $i ]
then
    echo "$k is not equal to $i"
fi

# Multiple condition
if [ $k != $i -a $k > $i ]
then
    echo "$k is not equal and is greater than $i"
fi

# Non-standard square bracket usage
if [ ! $k != $i -a $k > $i ]
then
    echo "$k is equal and is greater than $i"
else
    echo "$k is not equal and is greater than $i"
fi

# Testing echo -n flag
echo -n "Hello"
echo "Hello -n "
echo "Hello" -n
echo "-n -n -n -n -n -n -n -n"

# Testing arguments
# Number of arguments
if [ $# -ne 0 ]
then
    echo "You gave me $# argument(s)"
else
    echo "You only gave me nothing! $#"
fi

# Testing $* - printing all arguments
echo $*

# Testing $@ - printing all arguments
echo $@

# Testing nested loops and nested if statements
# Tests variables used for seq and uses of seq's different forms
for i in $(seq 2 5)
do
    for j in $(seq 2)
    do
        for k in 1 2
        do
            tmp=$(($i + $j - $k))
            if [ $tmp -le 3 ]
            then
                echo "$i + $j - $k <= 3"
            elif [ $tmp -eq 4 ]
            then
                echo "$i + $j - $k == 4"
            else
                echo "$i + $j - $k > 4"
            fi
        done
    done
done
