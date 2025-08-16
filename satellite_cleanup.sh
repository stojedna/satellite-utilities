#!/bin/bash
#
# Script to cleanup tasks/audits/reports in satellite.
#
# https://docs.redhat.com/en/documentation/red_hat_satellite/6.13/html/administering_red_hat_satellite/maintaining-satellite-server_admin#maintaining-satellite-server_admin
# https://access.redhat.com/solutions/2755731
#
##################################################

# functions

howto()
{
   # Display Help
   echo
   echo "Syntax: $0 <number-of-days-to-keep>"
   echo
}

# check parameter

if [ $# -ne 1 ]; then
  printf "Error. This script requires one parameter to work\n"
  howto
  exit 1
fi

dtok=$1

[ "$dtok" -eq "$dtok" ] 2>/dev/null

if [ $? -ne 0 ]; then
  printf "Error. Parameter must be a number\n"
  howto
  exit 1
fi

tnit="d"

# main

which foreman-rake 2>/dev/null

if [ $? -ne 0 ]; then
  printf "Error. Utility foreman-rake seems not to be installed. Is Satellite installed here?\n"
  exit 1
fi

foreman-rake audits:expire days=$dtok

if [ $? -ne 0 ]; then
  printf "Error. Audit cleanup failed\n"
fi

foreman-rake reports:expire days=$dtok

if [ $? -ne 0 ]; then
  printf "Error. Reports cleanup failed\n"
fi

foreman-rake foreman_tasks:cleanup TASK_SEARCH='label ~ *' AFTER="$dtok$tnit"

if [ $? -ne 0 ]; then
  printf "Error. Tasks cleanup failed\n"
fi

exit
