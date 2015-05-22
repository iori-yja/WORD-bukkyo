#!/bin/zsh

# comannd amount user
function add_user () {
	newid=$(tail -1 "${USERDB}"|gawk -v FPAT='([^,]+)|(\"[^\"]+\")' -e '{print $1}')
	echo "${newid}"
	newid=$((newid + 1))
	echo "${newid},${1},\"${2}\",0,0,0,0" >> "${USERDB}"
}

USERDB="user.csv"
current=$(grep "${2}" "${USERDB}")
AWKOPT=""

echo "${current}"
if [ ! "${current}" ]; then
	add_user "${2}" "${3}"
	current=$(grep "${2}" "${USERDB}")
fi

balance=$(echo "${current}" | gawk -v FPAT='([^,]+)|(\"[^\"]+\")' -e '{print $4}')
echo "${balance}"
price="${1}"
newbalance=$((balance - price))
echo "${newbalance}"

if [ "${newbalance}" -ge 0 ]; then
	next=$(echo "${current}" | gawk -v FPAT='([^,]+)|(\"[^\"]+\")' -e '{print $1 "," $2 "," $3 ",'${newbalance}'," $5 "," $6 "," $7 }')
	echo "$(date) : s/${current}/${next}/" >> sed.log
	sed -i -e "s/${current}/${next}/" user.csv
	exit 0
else
	exit 1
fi

