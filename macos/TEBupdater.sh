#!/usr/bin/env bash

cd "$(dirname "$0")"

echo ":::::::::::::::::::::::::::::::"
echo ":: Tor Expert Bundle Updater ::"
echo ":: 2022.12.05 by Miles Guo   ::"
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
DLDST="$PWD/Download/Torbrowser"
if [ ! -d "$DLDST" ];then
  echo "Sorry, I can't find the TorBrowser installation file on this computer."
  echo "So I can't upgrade Tor Expert Bundle."
  echo "Please use getTorbrowser to download TorBrowser installation file first."
  echo "Then run the script again."
  echo
  exit
fi

#
# Locale, you can change it to your own locale.
#
#TBLOCALE="zh-CN"
#TBLOCALE="en-US"
#

for file in `ls -R $DLDST/*/TorBrowser-*.dmg 2>/dev/null`
do
  echo -e ". \c"
done
echo
echo

if [ -e $file ];then
  echo "Find an Torbrowser DMG installation file in the download folder."
  echo "  $file"
  echo
  hdiutil attach $file -quiet -readonly
else
  echo "Sorry, I can't find an Torbrowser DMG installation file on this computer."
  echo
  echo "Let's try to find the Torbrowser app in the installed application."
  echo
fi

if [ -e "/Volumes/Tor Browser/Tor Browser.app" ];then
  APPPATH="/Volumes/Tor Browser/Tor Browser.app"
elif [ -e "/Applications/Tor Browser.app" ];then
  echo "Find an Torbrowser app in the installed application."
  echo
  APPPATH="/Applications/Tor Browser.app"
else
  echo "Sorry, I can't find either the TorBrowser DMG installation file or the TorBrowser app on this computer."
  echo "So I can't upgrade Tor Expert Bundle."
  echo "Please download TorBrowser DMG installation file and install TorBrowser app first."
  echo "Then run the script again."
  echo
  hdiutil detach "/Volumes/Tor Browser" -quiet -force
  exit
fi

# On newer releases of Tor Browser, Tor is in Contents/MacOS/.
# On newer releases of Tor Browser, TorBrowser is in Contents/Resources/.
# On newer releases of Tor Browser, tbb_version.json is in Contents/Resources/.
# The file contains only one line like this:
#   {"version":"11.5.2","architecture":"osx64","channel":"release","locale":"zh-CN"}
# We use it to determine whether we need to update our tor.
APPT="$APPPATH/Contents/MacOS/Tor"
APPTB="$APPPATH/Contents/Resources/TorBrowser"
APPTBB="$APPPATH/Contents/Resources/tbb_version.json"
OURTBB="$PWD/tbb_version.json"

if [ ! -e "$APPT" -o ! -e "$APPTB" -o ! -e "$APPTBB" ];then
  echo "It seems that I found an TorBrowser DMG installation file (or an TorBrowser app) on this computer,"
  echo "but I found that Tor, TorBrowser and tbb_version.json were missing, so I could not upgrade Tor Expert Bundle."
  echo "Please download and install the correct TorBrowser app again, and then run this script again."
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
mv -f ./TorBrowser $BAKDIR
mv -f ./tbb_version.json $BAKDIR
echo "Copy new file..."
echo
cp -rf "$APPTB" .
mkdir -p -m 755 ./TorBrowser/Data
mv -f ./TorBrowser/Tor ./TorBrowser/Data
cp -rf "$APPT" ./TorBrowser
cp -rf "$APPTBB" .
echo "Done."
echo
echo "Update completed. Enjoy!"
echo

hdiutil detach "/Volumes/Tor Browser" -quiet -force
exit
######################test only######################
#read -p "press any key to exit..."
#exit
######################test only######################
