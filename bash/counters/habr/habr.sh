#!/bin/bash

#username on habrahabr
HABRA_USER="agentsib"




export DISPLAY=:0

HABRA_LINK="http://habrahabr.ru/users/$HABRA_USER"

RESPONSE=`curl --silent -L  "$HABRA_LINK"`

get_script_path() {
	echo "$(dirname $(readlink -f "$0"))"

}

get_image_path(){
	echo $(get_script_path)/icon.png
}


send_message_error(){
        notify-send -t 5000 -i "$(get_image_path)" "$1" "$2"
}

send_message(){
	notify-send -i "$(get_image_path)" "$1" "$2"
}


if [ "$RESPONSE" == "" ]; then
echo $(get_image_path)
	send_message_error "Ошибка" "Не могу подсоединиться к habrahabr.ru"
else
	ER404=$(echo -e "$RESPONSE" | grep "404-")
	if [ "$ER404" != "" ]; then
		send_message_error "Ошибка" "Пользователя <b>$HABRA_USER</b> не существует!"
	else
		OLD_KARMA=$(cat $(get_script_path)/karma.cache)
		KARMA=$(echo -e "$RESPONSE" | grep "<div class=\"num\">" | sed '1!d' | sed -e "s@<[^>]*>@@g" | sed -e "s@[ \t]*@@g" | sed -e "s@,0@@")
		STRONG=$(echo -e "$RESPONSE" | grep "<div class=\"num\">" | sed '2!d' | sed -e "s@<[^>]*>@@g" | sed -e "s@[ \t]*@@g")
		if [ "$OLD_KARMA" != "$KARMA" ]; then
			MESSAGE=""
			if [ $KARMA -gt $OLD_KARMA ]; then
				MESSAGE="<b>УРА!!! Повысили!</b>\n"
			else
				MESSAGE="<b>Блин, понизили...</b>\n"
			fi
			send_message "Обновление кармы" "$MESSAGE<b>Карма:</b> $KARMA,0\n<b>Хабрасила:</b> $STRONG" 
			echo "$KARMA" > $(get_script_path)/karma.cache
		else
			echo > /dev/null
		fi
		
	fi	
fi




#echo -e "$RESPONSE" | grep "<div class=\"num\">"
