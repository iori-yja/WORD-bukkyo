#!/bin/zsh

while test -f "../alert.mp3"; do
	mplayer '../alert.mp3' > /dev/null 2>&1
done

