#!/bin/zsh

function post_slack () {
	curl "$slackurl`echo $1| nkf -wMQ | sed 's/=$//g' | tr = % | tr -d "\n"`" &
	echo posting to slack..
}

function no_item_found () {
# no_item_found UI's pid item username
	kill -USR2 $1
	sleep 0.1
	echo "$2, $3" >&p
	echo "ありゃりゃ？商品が見つからないよ？" >&p
	echo "配給担当までお問い合わせを" >&p
	kill -USR1 $1
	sleep 3
}

fpath=(./routines)

autoload -U get_balance
autoload -U search_item
autoload -U get_itemname

autoload -U check_itemprice
autoload -U try_withdrawal
autoload -U barcode_listener

olduser=""

killall -9 title.wish
coproc "./title.wish" $$
guicpid=`ps | grep "title.wish" | awk '{print $1}' | head -1`

fdump=""
echo $guicpid

slackurl=`grep "slackurl:" ../bukkyo.conf| head -1 |awk '{print $2}'`
trap barcode_listener USR1

sleep 1

while true;do
	# Waiting for felica card
	fdump=`timeout 2 felica_dump`

	if [ ! "$fdump" ]; then
		kill -USR2 $guicpid
		olduser=""

	elif [ "$fdump" = "error" ]; then
		msg="No card Reader found"
		kill -USR2 $guicpid
		sleep 0.1
		echo $msg >&p
		echo $msg >&p
		echo $msg >&p
		kill -USR1 $guicpid
		sleep 10

	else
		dummy_username=`echo "$fdump" | grep "0040:0003:" | sed -e "s/^.*0040:0003:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf -Sw`
		dummy_userid=`echo "$fdump" | grep "0040:0000:" | sed -e "s/^.*0040:0000:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf -Sw`
		dummy_user=`expr $dummy_userid / 100000 - 1000000000`
		dummy_balance=`get_balance $dummy_user`

		username=$dummy_username
		userid=$dummy_userid
		user=$dummy_user
		balance=$dummy_balance

		if [ "$olduser" != "$user" ]; then
			echo "Card detected!"
			echo $username
			echo $user
			echo $balance
			echo $username >&p
			echo $user >&p
			echo $balance >&p
			kill -USR1 $guicpid
			olduser=$user
		fi
	fi

done


