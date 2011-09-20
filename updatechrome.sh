#!/bin/bash

cd /Applications

RUNNING_ALREADY=0
STILL_RUNNING=0
is_running() {
	COUNT=`ps auwwx|grep Chromium.app|grep -v grep|wc -l`
	return $COUNT
}
is_running
RUNNING_ALREADY=$?

#curl -s -S -O http://build.chromium.org/f/chromium/snapshots/Mac/LATEST
curl -s -S -O https://commondatastorage.googleapis.com/chromium-browser-continuous/Mac/LAST_CHANGE

VAL=`cat LAST_CHANGE |cut -f1`
CURRENT=`cat /Applications/Chromium.app/Contents/Info.plist|grep -A 1 SVNRevision|tail -1|tr -d "[a-z<>/ ]"|tr -d "[:space:]"`

rm LAST_CHANGE

if [ ! -f /Applications/Chromium.app/Contents/Info.plist ]; then
	CURRENT=0
fi

#echo "Current version: $CURRENT"
#echo "Latest version: $VAL"

if [ $VAL -gt $CURRENT ]; then
	echo "New version found. Downloading."
	#curl -O --progress-bar http://build.chromium.org/f/chromium/snapshots/Mac/$VAL/chrome-mac.zip
  curl -O --progress-bar https://commondatastorage.googleapis.com/chromium-browser-continuous/Mac/$VAL/chrome-mac.zip
else
	echo "No new version available"
	exit
fi

# Kill Any Existing Chrome Proceses
is_running
STILL_RUNNING=$?
if [ $STILL_RUNNING -gt 0 ]; then
	osascript -e 'tell application "Chromium" to quit'
fi
is_running
STILL_RUNNING=$?
if [ $STILL_RUNNING -gt 0 ]; then
	killall Chromium
fi;

unzip -o chrome-mac

if [ -f LATEST ]
then
rm LATEST
fi

if [ -d Chromium.app ]
then
rm -r Chromium.app/
fi

mv chrome-mac/Chromium.app/ Chromium.app/

rm chrome-mac.zip
rm -rf chrome-mac

echo "Done"
if [ $RUNNING_ALREADY -gt 0 ]; then
	open "/Applications/Chromium.app"
fi
