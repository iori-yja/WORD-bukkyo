#!/bin/zsh

function getitemname () {
	local itemname=`grep $1 item.csv | gawk -v FPAT='([^,]+)|(\"[^\"]+\")' '{print $3}'`
	if [ $itemname ]; then
		echo $itemname
		exit 0
	else
		exit 1
	fi
}

function post_slack () {
	curl -X POST --data-urlencode 'payload={"channel": "#slabot", "text": "'$1'"}' "$slackurl" &
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
}

function check_itemprice () {
	kill -USR2 $1
	sleep 0.1
	echo "$3 のお値段は"
	echo "$2 BKD"
	echo "です"
	echo "$3 のお値段は" >&p
	echo "$2 BKD" >&p
	echo "です" >&p
	kill -USR1 $1
	sleep 3
}

function try_withdrawal () {
	local price=`./searchitem.sh $item`
	local exit_status=$?
	if [ $exit_status != 0 ]; then
		no_item_found $guicpid $item $username
		item=""
	else
		sudo ./withdrawal.sh "$price" "$user" "$username"
		exit_status=$?
		echo $exit_status
		balance=`./getbalance.sh $user`
		if [ $exit_status = 0 ]; then
			kill -USR2 $guicpid
			itemname=`getitemname $item`
			sleep 0.1
			echo "$itemname, $username"
			echo "Thank you!"
			echo $balance
			echo "$itemname, $username" >&p
			echo "Thank you!" >&p
			echo $balance >&p
			post_slack "@maririso speech $username が $itemname を買いました"
			kill -USR1 $guicpid
			item=""
		else
			kill -USR2 $guicpid
			itemname=`getitemname $item`
			sleep 0.1
			echo "$itemname, $username"
			echo $balance
			echo "\"金が足りねえぞクソ\" Exception"
			echo "$itemname, $username" >&p
			echo "\"金が足りねえぞクソ\" Exception" >&p
			echo $balance >&p
			post_slack "@maririso speech $username はお金がなくて $itemname を買えませんでした"
			kill -USR1 $guicpid
			item=""
		fi
	fi
}

function barcodereader_listener () {
	item=""
	read -t 1 item <&p
	item=`echo $item|sed '/^[0-9]*$/ p; d'`
	echo "$item"
	if [ $fdump ]; then
		try_withdrawal
	else
		price=`./searchitem.sh "$item"`
		exit_status=$?
		if [ $exit_status != 0 ]; then
			no_item_found $guicpid "$item" " "
			item=""
		else
			itemname=`getitemname "$item"`
			check_itemprice $guicpid $price "$itemname"
		fi
	fi
	item=""
}

olduser=""

killall -9 title.wish
coproc "./title.wish" $$
guicpid=`ps | grep "title.wish" | awk '{print $1}' | head -1`

fdump=""
echo $guicpid

slackurl=`grep "slackurl:" ../bukkyo.conf| head -1 |awk '{print $2}'`

sleep 1

while true;do
	# Waiting for felica card
	trap barcodereader_listener USR1
	fdump=`timeout 2 felica_dump`

	if [ ! "$fdump" ]; then
		kill -USR2 $guicpid
		olduser=""

	elif [ "$fdump" = "error" ]; then
		msg="No card Reader found"
		echo msg >&p
		echo msg >&p
		echo msg >&p
		sleep 120

	else
		dummy_username=`echo "$fdump" | grep "0040:0003:" | sed -e "s/^.*0040:0003:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf -Sw`
		dummy_userid=`echo "$fdump" | grep "0040:0000:" | sed -e "s/^.*0040:0000:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf -Sw`
		dummy_user=`expr $dummy_userid / 100000 - 1000000000`
		dummy_balance=`./getbalance.sh $dummy_user`

		username=$dummy_username
		userid=$dummy_userid
		user=$dummy_user
		balance=$dummy_balance

		if [ "$olduser" != "$user" ]; then
			kill -USR1 $guicpid
			echo "Card detected!"
			echo $username
			echo $user
			echo $balance
			echo $username >&p
			echo $user >&p
			echo $balance >&p
			olduser=$user
		fi
	fi

done

