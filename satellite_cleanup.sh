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
   echo "Script to cleanup tasks/audits/reports in satellite."
   echo
   echo "Syntax: $0 <number-of-days-to-keep>"
   echo
}

# check parameter

if [ $# -ne 1 ]; then
  printf "\n[ERR] This script requires one parameter to work.\n\n"
  howto
  exit 1
fi

dtok=$1

[ "$dtok" -eq "$dtok" ] 2>/dev/null

if [ $? -ne 0 ]; then
  printf "\n[ERR] Parameter must be a number.\n\n"
  howto
  exit 1
fi

tnit="d"

# main

which foreman-rake 2>/dev/null

if [ $? -ne 0 ]; then
  printf "\n[ERR] foreman-rake seems not to be installed. Is Satellite installed here?\n\n"
  exit 1
fi

foreman-rake audits:expire days=$dtok

if [ $? -ne 0 ]; then
  printf "\n[ERR] Audit cleanup failed.\n\n"
fi

foreman-rake reports:expire days=$dtok

if [ $? -ne 0 ]; then
  printf "\n[ERR] Reports cleanup failed.\n\n"
fi

foreman-rake foreman_tasks:cleanup TASK_SEARCH='label ~ *' AFTER="$dtok$tnit"

if [ $? -ne 0 ]; then
  printf "\n[ERR] Tasks cleanup failed.\n\n"
fi

exit
