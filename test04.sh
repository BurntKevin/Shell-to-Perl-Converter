#!/bin/dash

# Testing functions
# Setting up functions - predetermined, argument taking and calculations
printa() {
    echo a
}

# Using local variable
echo_back() {
    local a
    a=$@
    echo $a
}

calculate_add() {
    for i in $@
    do
        sum=$(($sum + $i));
    done
    echo $sum;
}

# Calling functions
printa
echo_back Hello There
echo Trying to access local variable in echo back: $a
calculate_add 2 5 2 0 0 1 -1 1

# Testing <, >, >>
# Testing working commands
echo ">> to file" >>$1
echo "> to file" >$1
echo "< to file" <$1

# Chaining statements with and
test 0 -eq 0 && echo "0 is equal to 0"
test 0 -ne 0 && echo "0 is not equal to 0"

# Chainging statements with or
test 0 -eq 0 || echo "0 is not equal to 0"
test 0 -ne 0 || echo "0 is equal to 0"

# Testing ; - weird syntax breaking and shell ignoring ;
echo hello;
echo "hello;'"
echo 'hello;"'
i=2;
echo $i
echo $i;

case $1 in
    "greeting") echo "greetings == $1" && echo "And that is true!"
    ;;
    "banana")
        if test 1 -eq 1
        then
            echo "banana == $1"
        fi
    ;;
    "kiwi") echo "New Zealand is famous for kiwi." ;;
    *) echo "Could not find a fulfil query"
esac

# Testing ls
for file in $(ls)
do
    echo $file
done

# Choosing to comment out and not fully complete tests for mv, chmod, rm
# For security of systems and lack of creation tools such as mkdir and touch
# for file in $(ls)
# do
#     mv $file /$file
# done

# for file in $(ls)
# do
#     chmod 755 $file
# done

# for file in $(ls)
# do
#     rm $file
# done
