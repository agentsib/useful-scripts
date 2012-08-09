#!/bin/bash

# Check balance Tele2 Russia
#
# Settings:
#
# MYPHONE=9041234567
# PASSWORD=mysecretpass
#
MYPHONE=
PASSWORD=

USER_AGENT="Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)"
COOKIES="/tmp/tele2-cookies.txt"

# End settings.

function session_request {
	curl --silent -L -A "$USER_AGENT" \
		-b "$COOKIES" \
		-c "$COOKIES" \
		-H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
		"https://my.tele2.ru"
}

function auth_request {
	curl --silent -L -A "$USER_AGENT" \
		-b "$COOKIES" \
		-c "$COOKIES" \
		-d "j_username=$MYPHONE&j_password=$PASSWORD&_redirectToUrl=&is_ajax=true&$_TOKEN_NAME=$_TOKEN_VALUE&undefined=" \
		-H "X-Requested-With:XMLHttpRequest" \
		-H "Accept: application/json, text/javascript, */*; q=0.01" \
		-e "https://my.tele2.ru" \
		"https://my.tele2.ru/public/security/check"
}

function balance_request {
	curl --silent -L -A "$USER_AGENT" \
		-b "$COOKIES" \
		-c "$COOKIES" \
		-H "Accept: */*" \
		-H "Origin: https://my.tele2.ru" \
		-e "https://my.tele2.ru/home" \
		"https://my.tele2.ru/balance/sync/value?isBalanceRefresh=true"
}

function echo_balance {
	echo `balance_request | grep "span" | grep "column-header-data" | sed -e 's@<[^>]*>@@gi'`
}

_S_RESPONSE=`session_request`
_S_RESPONSE_HOME=`echo "$_S_RESPONSE" | egrep "csrfTok[^:]+: '[^']+',"`

if [ "$_S_RESPONSE_HOME" != "" ];
then
	#_TOKEN_NAME=`echo "$_S_RESPONSE_HOME" | egrep -o "[^:]+:" | sed -e "s@:@@g" -e "s@ @@g"`
	#_TOKEN_VALUE=`echo "$_S_RESPONSE_HOME" | sed -e "s@[^:]*:@@g" -e "s@'@@g" -e "s@,@@g" -e "s@ @@g"`
	echo_balance
	exit
fi

_S_RESPONSE_TOKEN=`echo "$_S_RESPONSE" | grep "/public/security/check" | grep "popup"`

if [ "$_S_RESPONSE_TOKEN" != "" ];
then
	_TOKEN_NAME=`echo "$_S_RESPONSE_TOKEN" | egrep -o "name=\"[^\"]+\"" | sed -e "s@[^\"]*@@" -e "s@\"@@g" -e "s@ @@g"`
	_TOKEN_VALUE=`echo "$_S_RESPONSE_TOKEN" | egrep -o "value=\"[^\"]+\"" | sed -e "s@[^\"]*@@" -e "s@\"@@g" -e "s@ @@g"`
	_JSON_RESULT=`auth_request | egrep -o "\"success\":true"`
	if [ "$_JSON_RESULT" != "" ];
	then
		echo_balance
		exit
	else
		echo "Error: incorrect login or password"
		rm "$COOKIES"
		exit
	fi
else
	echo "Error: connection error"
	exit
fi
