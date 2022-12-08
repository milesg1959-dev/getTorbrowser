#!/usr/bin/env bash

cd "$(dirname "$0")"

echo ":::::::::::::::::::::::::::::"
echo ":: TEBLauncher             ::"
echo ":: 2022.11.18 by Miles Guo ::"
echo ":: Use at your own risk.   ::"
echo ":::::::::::::::::::::::::::::"
echo
echo "Hey buddy."
echo
echo "Today is: $(date +%Y-%m-%d,%H:%M:%S)"
echo

echo "First, we need to check whether privoxy and wget commands exist in the system"
echo

for cmd in privoxy wget
do
  command -v $cmd >/dev/null 2>&1 && {
    echo "OK! The $cmd command exists."
  } || {
    echo "Sorry, I can't find the $cmd command, We need $cmd command."
    echo "Please refer to the readme.md file to download and install the $cmd command first."
    echo "Then run this script again."
    echo
    exit
  }
done
echo

echo "Get the tor running..."
echo

DATA="$PWD/Data"
if [ ! -d "$DATA" ];then
    mkdir -p -m 700 $DATA
fi

#
# Configuration for tor
#
TORHOST="127.0.0.1"
TORPORT=9050
TORCTRLPORT=9051

# Do not modify these
TORRCDEFAULTS="$PWD/TorBrowser/Data/Tor/torrc-defaults"
TORRC="$PWD/torrc"
TORDATA="$DATA"
GEOIP="$PWD/TorBrowser/Data/Tor/geoip"
GEOIP6="$PWD/TorBrowser/Data/Tor/geoip6"
TOREXEC="$PWD/TorBrowser/Tor/tor.real"
TORHASHPASS="16:95808DE6B3C05297608CEFB43053E55F2755284AAA43650AF441A74DFD"
TORLOG="$DATA/torlog.txt"

cd ./TorBrowser/Tor

$TOREXEC \
--defaults-torrc $TORRCDEFAULTS -f $TORRC \
DataDirectory $TORDATA \
GeoIPFile $GEOIP \
GeoIPv6File $GEOIP6 \
HashedControlPassword $TORHASHPASS \
+__ControlPort $TORCTRLPORT \
+__SocksPort "${TORHOST}:$TORPORT IPv6Traffic PreferIPv6 KeepAliveIsolateSOCKSAuth" \
>$TORLOG 2>&1 &

echo "Okey, Tor has started."
echo

cd ../..

echo "Get the privoxy running..."
echo

#
# Configuration for privoxy
#
PRIVOXYCFG="$PWD/config.txt"
PRIVOXYLOG="$DATA/privoxylog.txt"

privoxy --no-daemon $PRIVOXYCFG >$PRIVOXYLOG 2>&1 &

echo "Okey, Tor + Privoxy has started."
echo

TEST_URL=https://aus1.torproject.org/torbrowser/update_3/release/downloads.json

echo "Test $TEST_URL until it can be connected..."
echo

echo "wget -e https_proxy=127.0.0.1:8118 -q -t 1 --spider $TEST_URL"
wget -e https_proxy=127.0.0.1:8118 -q -t 1 --spider $TEST_URL

until [ $? -eq 0 ];
do
  echo "wget -e https_proxy=127.0.0.1:8118 -q -t 1 --spider $TEST_URL"
  wget -e https_proxy=127.0.0.1:8118 -q -t 1 --spider $TEST_URL
done

echo "Okey, now the $TEST_URL can be connected."
echo

echo "Let's Go."
echo

read -p "When you finish the job, press any key to exit..."

echo "We need to kill Tor + Privoxy."
echo
killall -9 privoxy > /dev/null 2>&1
killall -9 tor.real > /dev/null 2>&1
echo
echo "Bye!"
echo
exit
######################test only######################
#read -p "press any key to exit..."
#exit
######################test only######################
