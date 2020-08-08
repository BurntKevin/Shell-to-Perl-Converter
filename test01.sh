#!/bin/dash
# Aims to test subset 1

# Creating files - setting up environment
touch c.f
touch z.f
touch a.f
touch a.c
touch a/f.f

# Testing for, do, done, *
for i in 
do
    echo $i
done

# Testing viewing into another directory
for i in a/*
do
    echo $i
done

# Testing ?
for i in ??.c
do
    echo $i
done

# Testing []
for i in [ca].f
do
    echo $i
done

# Testing non-existent file
for i in "non_existent_file.file_extension"
do
    echo $i
done

# Testing read
read line
echo $line

# Testing cd
cd ../
cd *

# Testing exit
exit;
exit 5;

# Cleaning up
rm c.f z.f a.f a.c
rm -rf a/*
