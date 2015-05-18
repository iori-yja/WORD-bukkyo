#!/bin/zsh


olduser=""

coproc "./title.wish"
guicpid=`ps | grep "title.wish" | awk '{print $1}'`
fdump=""
echo $guicpid

while true;do
	while [ ! "$fdump" ]; do
		fdump=`felica_dump`
	done


	username=`echo "$fdump" | grep "0040:0003:" | sed -e "s/^.*0040:0003:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf`
	userid=`echo "$fdump" | grep "0040:0000:" | sed -e "s/^.*0040:0000:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf`
	user=`expr $userid / 100000 - 1000000000`

	if [ "$olduser" != "$user" ]; then
		kill -USR1 $guicpid
		echo "Card detected!"
		echo $username
		echo $user
		echo $username >&p
		echo $user >&p
	fi

	olduser=$user
	read -t 3 item <&p

	if [ $item ];then
		amount=`./searchitem.sh $item`
		./withdrawal.sh "$amount" "$user"
		echo "$item, $username"
		echo "Thank you!"
		item=""
	else
		fdump=`felica_dump`
		if [ "$fdump" ];then
			continue;
		else
			kill -USR2 $guicpid
			echo "===Aborted==="
			olduser=""
		fi
	fi
done

