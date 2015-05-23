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
2. Set your slack integration in ~/bukkyo.conf. eg)```echo "slackurl: https://slack.com/api/chat.postMessage?token=foo&channel=%23bar&as_user=true&text=" > ~/bukkyo.conf```
2. Type ```./run.sh```.
3. Put your card on the reader.
5. Charge your balance. If your account is not exist, it will be automatically created.
6. buy, share, dance!

## Hint
- If you have no slack integration, delete ```post_slack``` statement in routines.sh:26 and 39. (The actual line number may differ than those)
- In many case, DB must be protected. It may be helpful to make `*.csv` and `withdrawal.sh` to be owned by another user. If user `hoge` owns these 3 files, you should edit sudoer file with ```visudo``` and put a line like ```bukkyo ALL=(hoge) NOPASSWD:/path/to/source/withdrawal.sh```.
- If you want to make a POS terminal instead of multi-use-computer, write `.profile` as below:
```
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && xinit

logout
```
and `.xinitrc` as:
```
#!/bin/sh
:
:
exec "/path/to/source/run.sh" > log 2>&1
```

![the GAMEN](https://raw.githubusercontent.com/iori-yja/WORD-bukkyo/master/img/screenshot.png)
