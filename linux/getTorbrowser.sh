#!/usr/bin/env bash

cd "$(dirname "$0")"

echo ":::::::::::::::::::::::::::::"
echo ":: getTorbrowser           ::"
echo ":: 2022.12.24 by Miles Guo ::"
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

#
# Set save folder for downloaded files
#
DLDIR="$HOME/Downloads/Torbrowser"
if [ ! -d "$DLDIR" ];then
  mkdir -p -m 700 $DLDIR
fi

#
# set the torproject download site.
#
# Torbrowser's official website
# It may be necessary to run Tor + Privoxy to connect
# https://www.torproject.org/download/
# https://www.torproject.org/download/tor/
# https://dist.torproject.org/torbrowser/11.0.15/
#
# Torbrowser's mirror site
# It seems that we can connect without running Tor + Privoxy (Recommended for use in China)
# https://tor.calyxinstitute.org/download/
# https://tor.calyxinstitute.org/download/tor/
# https://tor.calyxinstitute.org/dist/torbrowser/11.0.15/
#
#set TEST_URL=https://aus1.torproject.org/torbrowser/update_3/release/downloads.json

echo "Now we will select the download site of Torbrowser."
echo

# Save the original default delimiter of the system
IFS_OLD="$IFS"
# Set new delimiter
IFS=$'\r\n'
num=0
for site in `cat sites.txt`
do
  if [[ "$site" == "#"* ]];then
    echo -e "\c"
  else
    DL_URLS[$num]=$site/download/
    DLT_URLS[$num]=$site/download/tor/
    DIST_URLS[$num]=$site/dist/torbrowser/
    num=`expr $num + 1`
  fi
done
# Restore the original default delimiter of the system
IFS=$IFS_OLD

num=${#DL_URLS[@]}
num=`expr $num - 1`
for i in $(seq 0 $num)
do
  DL_URL=${DL_URLS[$i]}
  DLT_URL=${DLT_URLS[$i]}
  DIST_URL=${DIST_URLS[$i]}
  echo "Let's try whether $DL_URL can connect..."
  echo

  echo "wget -q -t 1 --spider $DL_URL"
  wget -q -t 1 --spider $DL_URL
  
  if [ $? -eq 0 ];then
    echo "Yes, the $DL_URL can be connected."
    echo
    TORPRIVOXY=0
    break
  else
    echo "No, the $DL_URL can't connect."
    echo
    TORPRIVOXY=1
  fi
  i=`expr $i + 1`
done

if [ $TORPRIVOXY -eq 1 ];then
  echo "Since all the sites could not connect normally,"
  echo "we decided to select the Torbrowser's official website"
  echo "and start Tor + Privoxy."
  echo
  . startTorPrivoxy.sh
fi

# Save the original default delimiter of the system
IFS_OLD="$IFS"
# Set new delimiter
IFS=$'\r\n'
for platform in `cat platforms.txt`
do
  if [[ "$platform" == "#"* ]];then
    echo -e "\c"
  elif [[ $platform == TorExpertBundle ]];then
    # Tor Expert Bundle
    num=0
    for str in `cat $platform.txt`
    do
      if [[ "$str" == "#"* ]];then
        echo -e "\c"
      else
        para[$num]=$str
        ((num+=1))
      fi
    done
    num=`expr $num - 1`
    echo "${para[0]}"
    echo "${para[1]}"
    echo "${para[2]}"
    echo
    echo "Get the current version number of the ${para[3]} from $DLT_URL"
    echo
    str=${para[4]//PAT/([^/]+)}
    cutpoint=`expr $((para[5])) + 1`
    cutoffchars=${para[6]}
    if [ $TORPRIVOXY -eq 0 ];then
      wget -q -c -t 0 -O tempa.txt $DLT_URL
    else
      wget -e https_proxy=127.0.0.1:8118 -q -c -t 0 -O tempa.txt $DLT_URL
    fi
    tmpstr="$(grep -o -E -m 1 "$str" tempa.txt | cut -c $cutpoint-)"
    TVER="${tmpstr%$cutoffchars}"
    echo "Current version number is: $TVER"
    echo
    echo "Get the current path of the ${para[3]} from $DLT_URL"
    echo
    str=${para[7]//PAT/([^/]+)}
    cutpoint=`expr $((para[8])) + 1`
    cutoffchars=${para[9]}
    tmpstr="$(grep -o -E -m 1 "$str$TVER-windows-i686.tar.gz.asc" tempa.txt | cut -c $cutpoint-)"
	  TBVER="${tmpstr%$cutoffchars}"
    echo "Current path is: $TBVER"
    echo
    if [ -e tempa.txt ];then
      rm -rf tempa.txt
    fi

    echo "The downloaded files will be saved in this folder:"
    echo
    echo "  $DLDIR/$TBVER"
    echo

    for i in $(seq 10 $num)
    do
      file=${para[i]//TVER/$TVER}
      echo "Download file $file ..."
      echo
      if [ $TORPRIVOXY -eq 0 ];then
        echo "wget -q -c -t 0 -P $DLDIR/$TBVER $DIST_URL$TBVER/$file"
        wget -c -t 0 -P $DLDIR/$TBVER $DIST_URL$TBVER/$file
      else
        echo "wget -e https_proxy=127.0.0.1:8118 -q -c -t 0 -P $DLDIR/$TBVER $DIST_URL$TBVER/$file"
        wget -e https_proxy=127.0.0.1:8118 -c -t 0 -P $DLDIR/$TBVER $DIST_URL$TBVER/$file
      fi
      echo
    done
  elif [[ $platform == Android ]];then
    # Android
    num=0
    for str in `cat $platform.txt`
    do
      if [[ "$str" == "#"* ]];then
        echo -e "\c"
      else
        para[$num]=$str
        ((num+=1))
      fi
    done
    num=`expr $num - 1`
    echo "${para[0]}"
    echo "${para[1]}"
    echo "${para[2]}"
    echo
    echo "Get the current version number of the ${para[3]} from $DL_URL"
    echo
    str=${para[4]//PAT/([^/]+)}
    cutpoint=`expr $((para[5])) + 1`
    cutoffchars=${para[6]}
    if [ $TORPRIVOXY -eq 0 ];then
      wget -q -c -O tempa.txt $DL_URL
    else
      wget -e https_proxy=127.0.0.1:8118 -q -c -O tempa.txt $DL_URL
    fi
    tmpstr="$(grep -o -E -m 1 "$str" tempa.txt | cut -c $cutpoint-)"
	  TBVER="${tmpstr%$cutoffchars}"
    echo "Current version number is: $TBVER"
    echo
    if [ -e tempa.txt ];then
      rm -rf tempa.txt
    fi

    echo "The downloaded files will be saved in this folder:"
    echo
    echo "  $DLDIR/$TBVER"
    echo

    for i in $(seq 7 $num)
    do
      file=${para[i]//TBVER/$TBVER}
      echo "Download file $file ..."
      echo
      if [ $TORPRIVOXY -eq 0 ];then
        echo "wget -q -c -t 0 -P $DLDIR/$TBVER $DIST_URL$TBVER/$file"
        wget -c -t 0 -P $DLDIR/$TBVER $DIST_URL$TBVER/$file
      else
        echo "wget -e https_proxy=127.0.0.1:8118 -q -c -t 0 -P $DLDIR/$TBVER $DIST_URL$TBVER/$file"
        wget -e https_proxy=127.0.0.1:8118 -c -t 0 -P $DLDIR/$TBVER $DIST_URL$TBVER/$file
      fi
      echo
    done
  else
    # Windows/macOS/Linux
    num=0
    for str in `cat $platform.txt`
    do
      if [[ "$str" == "#"* ]];then
        echo -e "\c"
      else
        para[$num]=$str
        ((num+=1))
      fi
    done
    num=`expr $num - 1`
    echo "${para[0]}"
    echo "${para[1]}"
    echo "${para[2]}"
    echo
    echo "Get the current version number of the ${para[3]} from $DL_URL"
    echo
    str=${para[4]//PAT/([^/]+)}
    cutpoint=`expr $((para[5])) + 1`
    cutoffchars=${para[6]}
    if [ $TORPRIVOXY -eq 0 ];then
      wget -q -c -O tempa.txt $DL_URL
    else
      wget -e https_proxy=127.0.0.1:8118 -q -c -O tempa.txt $DL_URL
    fi
    tmpstr="$(grep -o -E -m 1 "$str" tempa.txt | cut -c $cutpoint-)"
	  TBVER="${tmpstr%$cutoffchars}"
    echo "Current version number is: $TBVER"
    echo
    if [ -e tempa.txt ];then
      rm -rf tempa.txt
    fi

    echo "The downloaded files will be saved in this folder:"
    echo
    echo "  $DLDIR/$TBVER"
    echo

    for i in $(seq 7 $num)
    do
      file=${para[i]//TBVER/$TBVER}
      echo "Download file $file ..."
      echo
      if [ $TORPRIVOXY -eq 0 ];then
        echo "wget -q -c -t 0 -P $DLDIR/$TBVER $DIST_URL$TBVER/$file"
        wget -c -t 0 -P $DLDIR/$TBVER $DIST_URL$TBVER/$file
      else
        echo "wget -e https_proxy=127.0.0.1:8118 -q -c -t 0 -P $DLDIR/$TBVER $DIST_URL$TBVER/$file"
        wget -e https_proxy=127.0.0.1:8118 -c -t 0 -P $DLDIR/$TBVER $DIST_URL$TBVER/$file
      fi
      echo
    done
  fi
done
# Restore the original default delimiter of the system
IFS=$IFS_OLD

echo "Okey, All files have been downloaded. Enjoy!"
echo

if [ $TORPRIVOXY -eq 0 ];then
  echo "Bye!"
  echo
else
  echo "We need to kill Tor + Privoxy."
  echo
  killall -9 privoxy > /dev/null 2>&1
  killall -9 tor > /dev/null 2>&1
  echo
  echo "Bye!"
  echo
fi

######################test only######################
#read -p "press any key to exit..."
#exit
######################test only######################
