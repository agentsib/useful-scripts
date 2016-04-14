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

function session_request {
        curl --silent -L -A $USER_AGENT \
                -b $COOKIES \
                -c $COOKIES \
                -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
                "https://login.tele2.ru:443/ssotele2/wap/auth/"
}

function auth_request {
        curl --silent -L -A "$USER_AGENT" \
                -b $COOKIES \
                -c $COOKIES \
                -H "_csrf_header:X-CSRF-TOKEN" \
                -H "_csrf:$_S_RESPONSE_TOKEN" \
                -d "_csrf=$_S_RESPONSE_TOKEN&pNumber=$MYPHONE&password=$PASSWORD" \
                "https://login.tele2.ru:443/ssotele2/wap/auth/submitLoginAndPassword"
}

function balance_request {
        MS=$(($(date +%s%N)/1000000))
        curl --silent -k -L -A "$USER_AGENT" \
                -b $COOKIES \
                -c $COOKIES \
                -H "Accept: */*" \
                "https://my.tele2.ru/getFreshBalance?_=$MS"
}

function echo_balance {
        _S_BALANCE_REQUEST=`balance_request`
        echo "$_S_BALANCE_REQUEST" | grep '"balance"' | cut -d '>' -f2 | cut -d '<' -f1
}

_S_RESPONSE=`session_request`
_S_RESPONSE_HOME=`echo "$_S_RESPONSE" | grep 'service-list-item'`

if [ "$_S_RESPONSE_HOME" != "" ];
then
        echo_balance
        exit
fi

_S_RESPONSE_TOKEN=`echo "$_S_RESPONSE" | awk -F 'value=' '/_csrf/ {print $2}' | cut -d '"' -f2`

if [ "$_S_RESPONSE_TOKEN" != "" ];
then
        _AUTH_CHECK=`auth_request | grep 'service-list-item'`
        if [ "$_AUTH_CHECK" != "" ];
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

rm "$COOKIES"
exit
