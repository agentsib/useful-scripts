#!/bin/bash

# Check balance Beeline Russia
#
# Settings:
#
# MYPHONE=9041234567
# PASSWORD=mysecretpass
#
MYPHONE=
PASSWORD=

USER_AGENT="Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)"
COOKIES="/tmp/beeline-cookies.txt"
CONVERT_COMMAND="iconv -f windows-1251 -t utf-8"

# End settings.

function auth_request {
	curl --silent -L -A "$USER_AGENT" \
		-c "$COOKIES" \
		-H "Accept: */*" \
		-d "userName=$MYPHONE&password=$PASSWORD&ecareAction=login" \
		-e "https://uslugi.beeline.ru" \
		"https://uslugi.beeline.ru/loginPage.do" | $CONVERT_COMMAND
}

function balance_request {
	curl --silent -L -A "$USER_AGENT" \
		-b "$COOKIES" \
		-c "$COOKIES" \
		-H "Accept: */*" \
		-e "https://uslugi.beeline.ru/navigateMenu.do" \
		"https://uslugi.beeline.ru/vip/prepaid/refreshedPrepaidBalance.jsp"  | $CONVERT_COMMAND
}

rm -rf $COOKIES

_RESPONSE=`auth_request`

if [ "$_RESPONSE" != "" ];
then
	_WARN=`auth_request | grep "class=\"warn\""`
	if [ "$_WARN" == "" ];
	then
		_RESPONSE_BALANCE=`balance_request` 
		_BALANCE=`echo $_RESPONSE_BALANCE | egrep -o "<td class=\"tabred\">(.*)</td>" | sed -e 's@<[^>]*>@@gi' -e 's@\s*@ @' -e 's@\ @ @g' -e 's@^\s*@@' -e 's@&nbsp;@ @g'`
		if [ "$_BALANCE" != "" ];
		then
			echo "$_BALANCE" | sed -e 's@\..*@.@' -e 's@,@.@'
		else
			echo "Error: "
			echo $_BALANCE | egrep -o "<td class=\"warn\">(.*)</td>" | sed -e 's@<[^>]*>@@gi' -e 's@\s*@ @' -e 's@\ @ @g' -e 's@^\s*@@' -e 's@&nbsp;@ @g'	
		fi
	else
		echo "Error: incorrect login or password"
	fi

else
	echo "Error: connection error"
fi

