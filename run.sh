# shellcheck disable=SC1071
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

sleep 1

while true;do
	# Waiting for felica card
	fdump=$(timeout 2 felica_dump)

	if [ ! "$fdump" ]; then
		kill -USR2 "${guicpid}"
		olduser=""

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
		dummy_username=$(echo "${fdump}" | grep "0040:0003:" | sed -e "s/^.*0040:0003:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf -Sw)
		dummy_userid=$(echo "${fdump}" | grep "0040:0000:" | sed -e "s/^.*0040:0000:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf -Sw)
		dummy_user=$((dummy_userid / 100000 - 1000000000))
		dummy_balance=$(get_balance "${dummy_user}")

		username="${dummy_username}"
		userid="${dummy_userid}"
		user="${dummy_user}"
		balance="${dummy_balance}"

		if [ "${olduser}" != "${user}" ]; then
			echo "Card detected!"
			echo "${username}"
			echo "${user}"
			echo "${balance}"
			echo "${username}" >&p
			echo "${user}" >&p
			echo "${balance}" >&p
			kill -USR1 "${guicpid}"
			olduser="${user}"
		fi
	fi

done

