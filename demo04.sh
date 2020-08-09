#!/bin/dash

cheerAndrew() {
    # Cheering Andrew
    say="Andrew rocks!!!"
    for i in $(seq 10)
    do
        echo $say
    done
}

cheerAndrew

# Requesting audience feedback
echo "Shout for Andrew!!!"

# Getting audience feedback
while test $# -gt 0
do
    # Getting latest shout
    read line

    # Letting them shout on the speakers until they do bad things
    # I am proud of my somewhat working cases :)
    case $line in
        "Boo") echo "Wow... I am disappointed"; exit 0;
        ;;
        *) echo $line;
    esac
done
