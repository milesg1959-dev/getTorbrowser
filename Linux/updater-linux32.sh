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

for file in `ls -Rrt $DLDIR/*/tor-browser-linux32-*.tar.xz 2>/dev/null`
do
  echo -e ". \c"
done
echo
echo

if [ -e $file ];then
  echo "Find an Torbrowser installation file in the download folder."
  echo "  $file"
  echo
  tar -xf $file
else
  echo "Sorry, I can't find the TorBrowser installation file on this computer."
  echo "You may not have downloaded the TorBrowser installation file."
  echo "Please use the getTorbrowser script to download the TorBrowser installation file"
  echo "before updating your Tor Exper Bundle first."
  exit
fi

if [ -e "tor-browser" ];then
  APPPATH="tor-browser"
else
  echo "Sorry, I can't find the TorBrowser installation file on this computer."
  echo "You may not have downloaded the TorBrowser installation file."
  echo "Please use the getTorbrowser script to download the TorBrowser installation file"
  echo "before updating your Tor Exper Bundle first."
  exit
fi

# On newer releases of Tor Browser, TorBrowser is in tor-browser/Browser/.
# On newer releases of Tor Browser, tbb_version.json is in tor-browser/Browser/.
# The file contains only one line like this:
#   {"version":"11.5.2","architecture":"linux64","channel":"release","locale":"zh-CN"}
#   {"version":"12.0.1","architecture":"linux64","channel":"release","locale":"en-US"}
# We use it to determine whether we need to update our tor.
APPTB="$APPPATH/Browser/TorBrowser"
APPTBB="$APPPATH/Browser/tbb_version.json"
OURTB="$PWD/TorBrowser"
OURTBB="$OURTB/tbb_version.json"

if [ ! -e "$APPTB" -o ! -e "$APPTBB" ];then
  echo "It seems that I found an TorBrowser installation file on this computer,"
  echo "but I found that TorBrowser and tbb_version.json were missing,"
  echo "so I could not upgrade Tor Expert Bundle."
  echo "Please download the correct TorBrowser installation file, and then run this script again."
  echo
  rm -rf $APPPATH
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
  rm -rf $APPPATH
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
mv -f $APPTB .
mv -f $APPTBB $OURTB
echo "Done."
echo
echo "Update completed. Enjoy!"
echo

rm -rf $APPPATH

######################test only######################
#read -p "press any key to exit..."
#exit
######################test only######################
