#!/bin/zsh

function try_withdrawal () {
	local price
	local exit_status
	price=$(search_item "${item}")
	exit_status="${?}"
	if [ "${exit_status}" != 0 ]; then
		no_item_found "${guicpid}" "${item}" "${username}"
		item=""
	else
		sudo ./withdrawal.sh "${price}" "${user}" "${username}"
		exit_status="${?}"
		echo "${exit_status}"
		balance=$(get_balance "${user}")
		if [ "${exit_status}" = 0 ]; then
			kill -USR2 "${guicpid}"
			itemname=$(get_itemname "${item}")
			sleep 0.1
			echo "${itemname}, ${username}"
			echo "Thank you!"
			echo "${balance}"
			echo "${itemname}, ${username}" >&p
			echo "Thank you!" >&p
			echo "${balance}" >&p
			post_slack "@maririso speech ${username} が ${itemname} を買いました"
			kill -USR1 "${guicpid}"
			item=""
		else
			kill -USR2 "${guicpid}"
			itemname=$(get_itemname "${item}")
			sleep 0.1
			echo "${itemname}, ${username}"
			echo "${balance}"
			echo "\"金が足りねえぞクソ\" Exception"
			echo "${itemname}, ${username}" >&p
			echo "\"金が足りねえぞクソ\" Exception" >&p
			echo "${balance}" >&p
			post_slack "@maririso speech ${username} はお金がなくて ${itemname} を買えませんでした"
			kill -USR1 "${guicpid}"
			item=""
		fi
	fi
}

function post_slack () {
	curl "${slackurl}$(echo "${1}"| nkf -wMQ | sed 's/=$//g' | tr '=' '%' | tr -d "\n")" &
	echo posting to slack..
}

function no_item_found () {
# no_item_found UI's pid item username
	kill -USR2 "${1}"
	sleep 0.1
	echo "${2}, ${3}" >&p
	echo "ありゃりゃ？商品が見つからないよ？" >&p
	echo "配給担当までお問い合わせを" >&p
	kill -USR1 "${1}"
	sleep 3
}

function dummy_handle () {
}

function barcode_listener () {
	trap dummy_handle USR1
	kill -PIPE "${guicpid}"
	item=""
	read item <&p
	echo $item
	item=$(echo "${item}"|sed '/^[0-9]*$/ p; d')

	if [ ! "$item" ]; then
		echo "invalid input"
		kill -USR2 "${guicpid}"
		sleep 0.1
		echo "Barcode error." >&p
		echo "Invalid input." >&p
		echo "abort." >&p
		kill -USR1 "${guicpid}"
		sleep 1
		exit 1
	else
		echo "$item"
		if [ "${fdump}" ]; then
			try_withdrawal
		else
			price=$(search_item "$item")
			exit_status="${?}"
			if [ $exit_status != 0 ]; then
				no_item_found "${guicpid}" "${item}" " "
				item=""
			else
				itemname=$(get_itemname "${item}")
				check_itemprice "${guicpid}" "${price}" "${itemname}"
			fi
		fi
		item=""
	fi
	trap barcode_listener USR1
}

function check_itemprice () {
	kill -USR2 "${1}"
	sleep 0.1
	echo "${3} のお値段は"
	echo "${2} BKD"
	echo "です"
	echo "${3} のお値段は" >&p
	echo "${2} BKD" >&p
	echo "です" >&p
	kill -USR1 "${1}"
	sleep 3
}

function get_balance () {
	USERDB="user.csv"
	current=$(grep "${1}" ${USERDB})

	if [ ! "${current}" ]; then
		echo "残高: 0 BKD"
	else
		balance=$(echo "${current}" | gawk -v FPAT='([^,]+)|(\"[^\"]+\")' -e '{print $4}'|tail -1)
		echo "残高: "${balance}" BKD"
	fi
}

function get_itemname () {
	local itemname
	itemname=$(grep "${1}" item.csv | gawk -v FPAT='([^,]+)|(\"[^\"]+\")' '{print $3}')
	if [ "${itemname}" ]; then
		echo "${itemname}"
		exit 0
	else
		exit 1
	fi
}

function search_item () {
	price=$(grep "${1}" item.csv | gawk -v FPAT='([^,]+)|(\"[^\"]+\")' '{print $4}')

	if [ "${price}" ]; then
		echo "${price}"
		exit 0
	else
		exit 1
	fi
}

