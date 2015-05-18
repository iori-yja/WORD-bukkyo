#!/bin/bash

username=`felica_dump | grep "0040:0003:" | sed -e "s/^.*0040:0003:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf`
userid=`felica_dump | grep "0040:0000:" | sed -e "s/^.*0040:0000:\([A-Z,0-9]*\)$/\1/"|./hex2bin|nkf`
user=`expr $userid / 100000 - 1000000000`
echo $username
echo $user
beep
read item

amount=`./searchitem.sh $item`
./withdrawal.sh $amount $user

