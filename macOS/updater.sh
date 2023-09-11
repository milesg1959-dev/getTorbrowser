#!/usr/bin/env bash

cd "$(dirname "$0")"

echo ":::::::::::::::::::::::::::::::"
echo ":: Tor Expert Bundle Updater ::"
echo ":: 2022.12.24 by Miles Guo   ::"
echo ":: Use at your own risk.     ::"
echo ":::::::::::::::::::::::::::::::"
echo
echo "Hey buddy."
echo
echo "Today is: $(date +%Y-%m-%d,%H:%M:%S)"
echo

echo "First, we need to find out there is an TorBrowser installation file."
echo

#
# Set save folder for downloaded files
#
DLDIR="$HOME/Downloads/Torbrowser"
if [ ! -d "$DLDIR" ];then
  echo "Sorry, I can't find the TorBrowser installation file on this computer."
  echo "You may not have downloaded the TorBrowser installation file."
  echo "Please use the getTorbrowser script to download the TorBrowser installation file"
  echo "before updating your Tor Exper Bundle first."
  exit
fi

for file in `ls -Rrt $DLDIR/*/TorBrowser-*.dmg 2>/dev/null`
do
  echo -e ". \c"
done
echo
echo

if [ -e $file ];then
  echo "Find an Torbrowser installation file in the download folder."
  echo "  $file"
  echo
  hdiutil attach $file -quiet -readonly
else
  echo "Sorry, I can't find the TorBrowser installation file on this computer."
  echo "You may not have downloaded the TorBrowser installation file."
  echo "Please use the getTorbrowser script to download the TorBrowser installation file"
  echo "before updating your Tor Exper Bundle first."
  exit
fi

if [ -e "/Volumes/Tor Browser/Tor Browser.app" ];then
  APPPATH="/Volumes/Tor Browser/Tor Browser.app"
else
  hdiutil detach "/Volumes/Tor Browser" -quiet -force
  echo "Sorry, I can't find the TorBrowser installation file on this computer."
  echo "You may not have downloaded the TorBrowser installation file."
  echo "Please use the getTorbrowser script to download the TorBrowser installation file"
  echo "before updating your Tor Exper Bundle first."
  exit
fi

# On newer releases of Tor Browser, Tor is in Contents/MacOS/.
# On newer releases of Tor Browser, TorBrowser is in Contents/Resources/.
# On newer releases of Tor Browser, tbb_version.json is in Contents/Resources/.
# The file contains only one line like this:
#   {"version":"11.5.2","architecture":"osx64","channel":"release","locale":"zh-CN"}
#   {"version":"12.0.1","architecture":"macos","channel":"release","locale":"en-US"}
# We use it to determine whether we need to update our tor.
APPT="$APPPATH/Contents/MacOS/Tor"
APPTB="$APPPATH/Contents/Resources/TorBrowser"
APPTBB="$APPPATH/Contents/Resources/tbb_version.json"
OURTB="$PWD/TorBrowser"
OURTBB="$OURTB/tbb_version.json"

if [ ! -e "$APPT" -o ! -e "$APPTB" -o ! -e "$APPTBB" ];then
  echo "It seems that I found an TorBrowser installation file on this computer,"
  echo "but I found that Tor, TorBrowser and tbb_version.json were missing,"
  echo "so I could not upgrade Tor Expert Bundle."
  echo "Please download the correct TorBrowser installation file, and then run this script again."
  echo
  hdiutil detach "/Volumes/Tor Browser" -quiet -force
  exit
fi

echo "Now we need to determine whether this is the updated version of Tor Expert Bundle we need."
echo

for str in `cat "$APPTBB"`
do
  tmpstr="${str#*:\"}"
  APPTBBVER="${tmpstr%\",\"arch*}"
done
echo "Current version number is: $APPTBBVER"
echo
for str in `cat "$OURTBB"`
do
  tmpstr="${str#*:\"}"
  OURTBBVER="${tmpstr%\",\"arch*}"
done
echo "Our version number is: $OURTBBVER"
echo

if [ $APPTBBVER == $OURTBBVER -o $APPTBBVER \< $OURTBBVER ];then
  echo "Tor Expert Bundle no need update."
  echo
  hdiutil detach "/Volumes/Tor Browser" -quiet -force
  exit
fi

BAKDIR="$PWD/Update/$(date +%Y%m%d%H%M)_bak"
if [ -d $BAKDIR ];then
  rm -rf $BAKDIR
fi
if [ ! -d $BAKDIR ];then
  mkdir -p -m 755 $BAKDIR
fi

echo "Tor Expert Bundle needs to be updated, please wait..."
echo
echo "Backup old files to $BAKDIR..."
echo
mv -f $OURTB $BAKDIR
echo "Copy new file..."
echo
cp -rf "$APPTB" .
mkdir -p -m 755 $OURTB/Data
mv -f $OURTB/Tor $OURTB/Data
cp -rf "$APPT" $OURTB
cp -rf "$APPTBB" $OURTB
echo "Done."
echo
echo "Update completed. Enjoy!"
echo

hdiutil detach "/Volumes/Tor Browser" -quiet -force

######################test only######################
#read -p "press any key to exit..."
#exit
######################test only######################
