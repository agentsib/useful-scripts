#!/bin/bash

# Check balance Megafon Russia
#
# Settings:
#
# MYPHONE=9041234567
# PASSWORD=mysecretpass
# SG_SITE=kavkazsg.megafon.ru #KAVKAZ
#
MYPHONE=
PASSWORD=
SG_SITE=


# End settings.


_S_RESPONSE=`curl --silent -L -H "Accept: */*" -d "X_Username=$MYPHONE&X_Password=$PASSWORD" "https://$SG_SITE/ROBOTS/SC_TRAY_INFO"`

_BALANCE=`echo "$_S_RESPONSE" | grep "<BALANCE>" | sed -e "s@<[^>]*>@@g" -e "s@ @@g"`
_DATE=`echo "$_S_RESPONSE" | grep -m 1 "<DATE>" | sed -e "s@<[^>]*>@@g" `

if [ "$_BALANCE" == "" ];
then
	# <MSEC-COMMAND>SCC-ROBOTS-DENY</MSEC-COMMAND>
	_ERROR=`echo "$_S_RESPONSE" | grep "SCC-ROBOTS-DENY"`
	if [ "$_ERROR" != "" ];
	then
		echo "Error: incorrect login or password"
	else
		echo "Error: connection error"
	fi
else
	echo "$_BALANCE"
fi

