#!/bin/bash
#
# Script to register systems in Satellite, no matter if they have been previously registered in the Red Hat customer portal or another Satellite installation. RHEL 8 and newer required. 
#

# functions

howto()
{
   echo
   echo "Syntax: $0 <satellite-full-fqdn> <satellite-organization-name> <activation-key>"
   echo
   echo "Example: $0 mysatellite.mydomain.com organization xxxxxxxxx"
   echo
}

# main

if [ $# -ne 3 ]; then
  printf "Error. This script requires 3 parameter to work\n"
  howto
  exit 1
fi

sathost=$1
satorg=$2
satkey=$3

if [ ! -f /usr/bin/dnf ]
then
   printf "Error. dnf is not installed. Remember this script only works for systems running RHEL 8 and newer\n"
   exit 1
fi

if [ ! -f /usr/sbin/subscription-manager ]
then
   printf "Error. subscription-manager is not installed\n"
   exit 1
fi

# Clean the system in case it was previously registered in the customer portal or another satellite
subscription-manager clean
subscription-manager remove --all

# Uninstall the old katello (if exist)
dnf -y remove katello-ca-consumer*

# Download and install the katello
dnf -y --nogpgcheck --setopt sslverify=false install https://"$sathost"/pub/katello-ca-consumer-latest.noarch.rpm

if [ $? -ne 0 ]; then
   printf "Error. katello installation failed\n"
   exit 1
fi

# Subscribe the server
subscription-manager register --org="$satorg" --activationkey="$satkey"

if [ $? -ne 0 ]; then
   printf "Error. The subscription was not successful\n"
   exit 1
fi

exit
