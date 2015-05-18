#!/bin/bash

read user
read item

amount=`./searchitem.sh $item`
./withdrawal.sh $amount $user

