#!/bin/bash
if [ -z "$1" ] 
then
  echo " "
  echo " "
  echo "usage: ./viewlog.sh <Nth recent log file to view>"
  echo "for example,"
  echo "   ./viewlog.sh 2"
  echo "would show the 2nd most recent log file"
  echo " "
  echo " "
  exit
fi

less "log/$(ls -ltr log | grep '.log' | tr -s ' ' | cut -f9 -d' ' | tail -$1 | head -n1 )"