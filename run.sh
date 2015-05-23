#!/bin/zsh

source ./routines.sh

olduser=""

killall -9 title.wish
coproc "./title.wish" $$
guicpid=$(pgrep "title.wish" | awk '{print $1}' | head -1)

fdump=""
echo "${guicpid}"

slackurl=$(grep "slackurl:" ../bukkyo.conf| head -1 |awk '{print $2}')
trap barcode_listener USR1
trap force_redraw USR2

sleep 1

while true;do
	# Waiting for felica card
	fdump=$(timeout 2 felica_dump)

	if [ ! "${fdump}" ]; then
		if [ "${redraw}" ] || [ "${olduser}" ]; then
			olduser=""
			killall play_music.sh
			sleep 0.3
			kill -USR2 "${guicpid}"
			redraw=""
		fi

	elif [ "${fdump}" = "error" ]; then
		msg="No card Reader found"
		kill -USR2 "${guicpid}"
		sleep 0.1
		echo "${msg}" >&p
		echo "${msg}" >&p
		echo "${msg}" >&p
		kill -USR1 "${guicpid}"
		sleep 10

	else
		dummy_username=$(echo "${fdump}" | grep "0040:0003:" | sed -e 's/^.*0040:0003:\([A-Z,0-9]*\)$/\1/'|./hex2bin|nkf -Sw)
		dummy_userid=$(echo "${fdump}" | grep "0040:0000:" | sed -e 's/^.*0040:0000:\([A-Z,0-9]*\)$/\1/'|./hex2bin|nkf -Sw)
		dummy_user=$((dummy_userid / 100000 - 1000000000))
		dummy_balance=$(get_balance "${dummy_user}")

		username="${dummy_username}"
		userid="${dummy_userid}"
		user="${dummy_user}"
		balance="${dummy_balance}"

		if [ "${redraw}" ] || [ "${olduser}" != "${user}" ]; then
			echo "Card detected!"
			if [ ! "${redraw}" ]; then
				./play_music.sh &
			fi
			echo "${user}"
			echo "${username}"
			echo "${balance}"
			echo "${user}" >&p
			echo "${username}" >&p
			echo "残高: ${balance}BKD" >&p
			sleep 0.3
			kill -USR1 "${guicpid}"
			olduser="${user}"
			redraw=""
		fi
	fi

done

