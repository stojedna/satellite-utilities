#!/bin/bash
#
# Script to reclain space from the Satellite database.
#
#####################################################

which satellite-maintain 2>/dev/null

if [ $? -ne 0 ]; then
  printf "Error. Utility satellite-maintain is not installed. Ensure you run this in a Satellite installation\n"
  exit 1
fi

satellite-maintain service stop --exclude postgresql

if [ $? -ne 0 ]; then
  printf "Error. Satellite has failed to stop\n"
fi

su - postgres -c 'vacuumdb --full --dbname=foreman'

if [ $? -ne 0 ]; then
  printf "Error. The vacuumdb operation has failed\n"
fi

satellite-maintain service start

if [ $? -ne 0 ]; then
  printf "Error. Satellite has failed to start\n"
fi

exit
