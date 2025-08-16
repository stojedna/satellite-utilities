#!/bin/bash
#
# Script to run an OFFLINE satellite backup.
#
##################################################

# functions

function run_backup {
  logger "[satellite] OFFLINE backup is going to start."
  /usr/bin/satellite-maintain backup offline --assumeyes $1
  if [ $? -ne 0 ]; then
    logger "[satellite] OFFLINE backup has failed."
    echo | mutt -F $(dirname "$0")/.muttrc -s "[satellite] OFFLINE backup has failed" $2
    exit 1
  fi
  logger "[satellite] OFFLINE backup has ended successfully."
}

function chk_fs_size {
  fssize=$(df -h $1 | tail -1 | awk '{print $5}' | cut -d% -f1)
  if [[ $fssize -gt $2 ]]
   then
       logger "[satellite] There is not enough free space to run the backup."
       echo | mutt -F $(dirname "$0")/.muttrc -s "[satellite] There is not enough free space to run the backup" $admin
       exit 1
   fi
}

# variables

admin="my.email.account@example.com"
bckfold="/satellite-backup"
thold="60"

# main

which satellite-maintain 2>/dev/null

if [ $? -ne 0 ]; then
  printf "Error. Utility satellite-maintain is not installed. Ensure you run this in a Satellite installation\n"
  exit 1
fi

which mutt 2>/dev/null

if [ $? -ne 0 ]; then
  printf "Error. Mutt is required by the script but it is not installed\n"
  exit 1
fi

chk_fs_size $bckfold $thold
run_backup $bckfold $admin

exit
