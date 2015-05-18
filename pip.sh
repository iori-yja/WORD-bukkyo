#!/bin/bash

olduser=""

while true;do
	while [ ! "$fdump" ]; do
		fdump=`felica_dump`
	done


	username=`echo "$fdump" | grep "0040:0003:" | sed -e "s/^.*0040:0003:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf`
	userid=`echo "$fdump" | grep "0040:0000:" | sed -e "s/^.*0040:0000:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf`
	user=`expr $userid / 100000 - 1000000000`

	if [ "$olduser" != "$user" ]; then
		echo "Card detected!"
		echo $username
		echo $user
	fi

	olduser=$user
	read -t 1 item

	if [ $item ];then
		amount=`./searchitem.sh $item`
		./withdrawal.sh $amount $user
		echo "$item, $username"
		echo "Thank you!"
	else
		fdump=`felica_dump`
		if [ "$fdump" ];then
			continue;
		else
			echo "===Aborted==="
			olduser=""
		fi
	fi
done

