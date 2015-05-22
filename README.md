# WORD-bukkyo
This is what you saw in the past..
Gandhara...Gandhara..

## Set-up

### prepare-for-meal
This scripts need stuff like such:
 - tcl/tk
 - tclx
 - libpafe
 - pcsclite
 - zsh
 - nkf

### physical devices
 - SONY's felica reader (pasori)
 - A barcode reader that behaves as keyboard
 - ur student ID card
 - Barcodes to charge your balance

## Run
1. Write your DB in "item.csv" as the file this repos has. (Negative price tag is for charge)
2. setup your slack integration like ```slackurl: https://slack.com/api/chat.postMessage?token=foo&channel=%23bar&as_user=true&text=``` on ~/bukkyo.conf.
2. Type ```./run.sh``` (if UI does not spring up, removing card from card reader may be helpful)
3. Put your card on the reader.
4. ![the GAMEN](https://raw.githubusercontent.com/iori-yja/WORD-bukkyo/master/img/screenshot.png)
5. Charge your balance. If your account is not exist, it will be automatically created.
6. buy, share, dance!

