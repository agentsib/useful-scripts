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
PPREFIX="loginFormB2C%3AloginForm"

# End settings.

function auth_request {
	curl --silent -L -A "$USER_AGENT" \
		-c "$COOKIES" \
		-H "Accept: */*" \
		-d "$PPREFIX=loginFormB2C%3AloginForm&$PPREFIX%3Alogin=$MYPHONE&$PPREFIX%3Apassword=$PASSWORD&$PPREFIX%3AloginButton=&javax.faces.ViewState=stateless" \
		-e "https://my.beeline.ru/login.html" \
		"https://my.beeline.ru/login.html"
}

rm -rf $COOKIES

_RESPONSE=`auth_request`

if [ "$_RESPONSE" != "" ];
then
	_WARN=`_RESPONSE | grep "messages-error"`
	if [ "$_WARN" == "" ];
	then
		_BALANCE=`echo $_RESPONSE | egrep -o "<span class=\"price[^\"]?\">[^<]+<span[^>]+>" | sed -e 's@<[^>]*>@@g' -e 's@\s*@ @' -e 's@\ @ @g' -e 's@^\s*@@'`

		if [ "$_BALANCE" != "" ];
		then
			echo "$_BALANCE" | sed -e 's@\..*@.@' -e 's@,@.@'
		else
			echo "Error: balance not avaible"
		fi
	else
		echo "Error: incorrect login or password"
	fi

else
	echo "Error: connection error"
fi

