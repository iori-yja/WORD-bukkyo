#!/bin/zsh

olduser=""

coproc "./title.wish"
guicpid=`ps | grep "title.wish" | awk '{print $1}'`
fdump=""
echo $guicpid

while true;do
	while [ ! "$fdump" ]; do
		fdump=`timeout 2 felica_dump`
	done

	username=`echo "$fdump" | grep "0040:0003:" | sed -e "s/^.*0040:0003:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf`
	userid=`echo "$fdump" | grep "0040:0000:" | sed -e "s/^.*0040:0000:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf`
	user=`expr $userid / 100000 - 1000000000`
	balance=`./getbalance.sh $user`

	if [ "$olduser" != "$user" ]; then
		kill -USR1 $guicpid
		echo "Card detected!"
		echo $username
		echo $user
		echo $balance
		echo $username >&p
		echo $user >&p
		echo $balance >&p
	fi

	olduser=$user
	read -t 1 item <&p

	if [ $item ];then
		amount=`./searchitem.sh $item`
		exit_status=$?
		if [ $exit_status != 0 ]; then
			kill -USR1 $guicpid
			echo "$item, $username" >&p
			echo "ありゃりゃ？商品が見つからないよ？" >&p
			echo "配給担当までお問い合わせを" >&p
			item=""
		else
			sudo ./withdrawal.sh "$amount" "$user" "$username"
			exit_status=$?
			echo $exit_status
			balance=`./getbalance.sh $user`
			if [ $exit_status = 0 ]; then
				kill -USR1 $guicpid
				echo "$item, $username"
				echo "Thank you!"
				echo "$item, $username" >&p
				echo "Thank you!" >&p
				echo $balance >&p
				item=""
			else
				kill -USR1 $guicpid
				echo "$item, $username"
				echo "\"金が足りねえぞクソ\" Exception"
				echo "$item, $username" >&p
				echo "\"金が足りねえぞクソ\" Exception" >&p
				echo $balance >&p
				item=""
			fi
		fi
	else
		fdump=`timeout 2 felica_dump`
		if [ "$fdump" ];then
			continue;
		else
			kill -USR2 $guicpid
			echo "===Aborted==="
			olduser=""
		fi
	fi
done

