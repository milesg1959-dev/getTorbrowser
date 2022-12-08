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
TBLOCALE="zh-CN"
#TBLOCALE="en-US"
#

XDIR="tor-browser_$TBLOCALE"

for file in `ls -R $DLDST/*/tor-browser-linux64-*.tar.xz 2>/dev/null`
do
  echo -e ". \c"
done
echo
echo

if [ -e $file ];then
  echo "Find an TorBrowser installation file in the download folder."
  echo "  $file"
  echo
  tar -xf $file \
  $XDIR/Browser/TorBrowser/Data/Tor \
  $XDIR/Browser/TorBrowser/Docs \
  $XDIR/Browser/TorBrowser/Tor \
  $XDIR/Browser/tbb_version.json
else
  echo "Sorry, I can't find the TorBrowser installation file on this computer."
  echo "So I can't upgrade Tor Expert Bundle."
  echo "Please download TorBrowser installation file first."
  echo "Then run the script again."
  echo
  exit
fi

# On newer releases of Tor Browser, TorBrowser is in tor-browser_en-US/Browser/.
# On newer releases of Tor Browser, tbb_version.json is in tor-browser_en-US/Browser/.
# The file contains only one line like this:
#   {"version":"11.5.2","architecture":"linux64","channel":"release","locale":"zh-CN"}
# We use it to determine whether we need to update our tor.
APPTB="$XDIR/Browser/TorBrowser"
APPTBB="$XDIR/Browser/tbb_version.json"
OURTB="$PWD/TorBrowser"
OURTBB="$PWD/tbb_version.json"

if [ ! -e "$APPTB" -o ! -e "$APPTBB" ];then
  echo "It seems that I found an TorBrowser installation file on this computer,"
  echo "but I found that TorBrowser and tbb_version.json were missing,"
  echo "so I could not upgrade Tor Expert Bundle."
  echo "Please download the correct TorBrowser installation file again, and then run this script again."
  echo
  rm -rf $XDIR
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
  rm -rf $XDIR
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
mv -f $OURTBB $BAKDIR
echo "Copy new file..."
echo
mv -f $APPTB .
mv -f $APPTBB .
echo "Done."
echo
echo "Update completed. Enjoy!"
echo

rm -rf $XDIR
exit
######################test only######################
#read -p "press any key to exit..."
#exit
######################test only######################
