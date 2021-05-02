#!/bin/bash
if [ -z "$1" ] 
then
  echo " "
  echo " "
  echo "usage: ./runtest.sh <test file name relative to ./test directory, including file extension>"
  echo "eg: ./runtest.sh test_question.rb"
  echo " "
  echo " "
  exit
fi
ruby -Ilib:test test/$1