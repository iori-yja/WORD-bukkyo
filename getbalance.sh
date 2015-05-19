#!/bin/zsh

USERDB="user.csv"
current=`grep "$1" $USERDB`

if [ ! $current ]; then
	echo "残高: 0円"
else
	balance=`echo $current | gawk -v FPAT='([^,]+)|(\"[^\"]+\")' -e '{print $4}'|tail -1`
	echo "残高: $balance 円"
fi

