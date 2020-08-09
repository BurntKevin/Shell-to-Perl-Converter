#!/bin/dash
# Aims to test subset 1

# Testing for, do, done, *
for i in *
do
    echo $i
done

# Testing viewing into another directory
for i in a/*
do
    echo Found file from a/*! $i
done

# Testing ?
for i in ??.c
do
    echo "Found file from ??.c! $i"
done

# Testing []
for i in [ca].f
do
    echo "Found file from [ca].f! $i"
done

# Testing combination
for i in *y.[c]*
do
    echo "Found file from *y.[c]*! $i"
done

# Testing non-existent file
for i in "non_existent_file.file_extension"
do
    echo "Found seemingly non-existent file! $i"
done

# Testing read
echo "Type something cool! Break the program!"
read line
echo $line

# Testing cd
cd ../
cd *

# Testing exit
exit

echo "Did not exit correctly on empty exit"

exit 5

echo "Did not exit correctly on exit 5"
