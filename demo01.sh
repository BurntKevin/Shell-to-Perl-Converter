#!/bin/dash

# Cheering Andrew
say="Andrew rocks!!!"
for i in $(seq 10)
do
    echo $say
done

# Requesting audience feedback
echo "Shout it back!"
read line

# Not letting the audience say their feedback
echo "Sorry, don't trust you"
exit 0
for i in $(seq 10)
do
    echo $line
done
