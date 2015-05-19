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

function posting_slack () {
	local slackurl="https://hooks.slack.com/services/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"
	curl -X POST --data-urlencode 'payload={"text": "'$1'"}' $slackurl &
	echo posting to slack..
}

olduser=""

coproc "./title.wish"
guicpid=`ps | grep "title.wish" | awk '{print $1}'`
fdump=""
echo $guicpid

while true;do
	# Waiting for felica card
	while [ ! "$fdump" ]; do
		fdump=`timeout 2 felica_dump`
	done

	username=`echo "$fdump" | grep "0040:0003:" | sed -e "s/^.*0040:0003:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf -X`
	userid=`echo "$fdump" | grep "0040:0000:" | sed -e "s/^.*0040:0000:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf -X`
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
		#if barcode is input
		amount=`./searchitem.sh $item`
		exit_status=$?
		if [ $exit_status != 0 ]; then
			kill -USR2 $guicpid
			sleep 0.1
			echo "$item, $username" >&p
			echo "ありゃりゃ？商品が見つからないよ？" >&p
			echo "配給担当までお問い合わせを" >&p
			kill -USR1 $guicpid
			item=""
		else
			sudo ./withdrawal.sh "$amount" "$user" "$username"
			exit_status=$?
			echo $exit_status
			balance=`./getbalance.sh $user`
			if [ $exit_status = 0 ]; then
				kill -USR2 $guicpid
				itemname=`getitemname`
				sleep 0.1
				echo "$item, $username"
				echo "Thank you!"
				echo $balance
				echo "$item, $username" >&p
				echo "Thank you!" >&p
				echo $balance >&p
				kill -USR1 $guicpid
				posting_slack "maririso speech $username が $itemname を買いました"
				item=""
			else
				kill -USR2 $guicpid
				sleep 0.1
				echo "$item, $username"
				echo $balance
				echo "\"金が足りねえぞクソ\" Exception"
				echo "$item, $username" >&p
				echo "\"金が足りねえぞクソ\" Exception" >&p
				echo $balance >&p
				kill -USR1 $guicpid
				item=""
			fi
		fi
		#no barcode is input
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

