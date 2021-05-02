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

if [ ! "$(ls -A /tmp)" ] 
then 
  echo " "
  echo " "
  echo "log directory is empty, there are no logs to view. To create log files, set the YAROZI_LOG_LEVEL shell variable to CRITICAL, ERROR, WARN, INFO, or DEBUG and then run the application or tests, e.g."
  echo " "
  echo "export YAROZI_LOG_LEVEL=DEBUG"
  echo "rake"
  echo " "
  echo " "
  exit
fi

less "log/$(ls -ltr log | grep '.log' | tr -s ' ' | cut -f9 -d' ' | tail -$1 | head -n1 )"
