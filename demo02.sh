#!/bin/dash

# Cheering Andrew
say="Andrew rocks!!!"
for i in $(seq 10)
do
    echo $say
done

# Requesting audience feedback
echo "Shout for Andrew!!!"

# Getting audience feedback
while test $# -gt 0
do
    # Getting latest shout
    read line

    # Letting them shout on the speakers until they do bad things
    if [ $line != "Boo" ]
    then
        for i in $(seq 10)
        do
            echo $line
        done
    else
        echo "Wow... I am disappointed"
        exit 0
    fi
done
