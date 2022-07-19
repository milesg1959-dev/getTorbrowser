echo off
setlocal enabledelayedexpansion
cls
echo :::::::::::::::::::::::::::::
echo :: getTorbrowser           ::
echo :: 2022.07.19 by Miles Guo ::
echo :: Use at your own risk.   ::
echo :::::::::::::::::::::::::::::
echo .
::
cd /d %~dp0
::
echo Hey buddy.
echo .
echo Today is: %date% %time%
echo .
::
:: curl,wget,grep
::
set grep=%~dp0tools\grep\win32\grep.exe
set curl=%~dp0tools\curl\win64\bin\curl.exe
set wget=%~dp0tools\wget\win64\wget.exe
if %PROCESSOR_ARCHITECTURE%==x86 (
  set curl=%~dp0tools\curl\win32\bin\curl.exe
  set wget=%~dp0tools\wget\win32\wget.exe
)
::
:: set the torproject download site.
::
:: Primary site. First choice, but need to run Tor+Privoxy
:: https://www.torproject.org/download/
:: https://dist.torproject.org/torbrowser/11.0.15/
set test_url=https://www.torproject.org/download/
set download_url=https://dist.torproject.org/torbrowser/
::
:: Mirror site. Good choice, but need to run Tor+Privoxy
:: https://tor.eff.org/download/
:: https://tor.eff.org/dist/torbrowser/11.0.15/
::set test_url=https://tor.eff.org/download/
::set download_url=https://tor.eff.org/dist/torbrowser/
::
:: Mirror site. Good choice, no need to run Tor+Privoxy (Recommended for use in China)
:: https://tor.calyxinstitute.org/download/
:: https://tor.calyxinstitute.org/dist/torbrowser/11.0.15/
::set test_url=https://tor.calyxinstitute.org/download/
::set download_url=https://tor.calyxinstitute.org/dist/torbrowser/
::
:: Mirror site. Alternative, no need to run Tor+Privoxy (Attention! Not the latest version)
:: https://mirror.oldsql.cc/tor/download/
:: https://mirror.oldsql.cc/tor/dist/torbrowser/11.0.14/
::set test_url=https://mirror.oldsql.cc/tor/download/
::set download_url=https://mirror.oldsql.cc/tor/dist/torbrowser/
::
echo The current torbrowser download-url is: %download_url%
echo .
echo We will test whether it is available.
echo .
::
:: test test-url
::
echo test %test_url%...
echo .
%wget% -t 3 --spider %test_url% 
if %errorlevel%==0 (
  echo Okay,the %download_url% is available.
  echo .
  set toraloneprivoxy=n
  goto :readygo
)
::
echo Access blocked. Need to run Tor+Privoxy.
echo .
echo get the tor running...
echo .
set startpath=%~dp0tools\toralone\win64
set torExe=%~dp0tools\toralone\win64\Tor\tor.exe
set geoIP=%~dp0tools\toralone\win64\Data\Tor\geoip
set geoIPv6=%~dp0tools\toralone\win64\Data\Tor\geoip6
if %PROCESSOR_ARCHITECTURE%==x86 (
  set startpath=%~dp0tools\toralone\win32
  set torExe=%~dp0tools\toralone\win32\Tor\tor.exe
  set geoIP=%~dp0tools\toralone\win32\Data\Tor\geoip
  set geoIPv6=%~dp0tools\toralone\win32\Data\Tor\geoip6
)
set CTRL_PORT=9051
set TOR_HOST=127.0.0.1
set TOR_PORT=9050
set torrc=%~dp0tools\toralone\torrc
set tordata=%~dp0tools\toralone\data
set Tor_HashPass=16:95808DE6B3C05297608CEFB43053E55F2755284AAA43650AF441A74DFD
::
start "toralone" /d %startpath% /min %torExe% -f %torrc% DataDirectory %tordata% GeoIPFile %geoIP% GeoIPv6File %geoIPv6% HashedControlPassword %Tor_HashPass% +__ControlPort %CTRL_PORT% +__SocksPort "%TOR_HOST%:%TOR_PORT% IPv6Traffic PreferIPv6 KeepAliveIsolateSOCKSAuth"
:: __OwningControllerProcess $controllerProcess 
::
echo get the privoxy running...
echo .
set cfg=%~dp0tools\privoxy\config_toralone.txt
start /d %~dp0tools\privoxy\privoxy /min privoxy.exe %cfg%
::
set toraloneprivoxy=y
set https_proxy=127.0.0.1:8118
::
echo Okey,Tor+Privoxy has started.
echo .
::
:: test test-url again until it's available.
::
echo test %test_url% again until it's available...
echo .
:repeat
%wget% -t 1 --spider %test_url% 
if %errorlevel% neq 0 goto :repeat
::
echo Okey,now the %download_url% is available.
echo .
::
:readygo
echo Let's Go.
echo .
::
set TBpath=
for /f "tokens=*" %%a in ('%curl% -s %test_url% ^| %grep% -o -E -m 1 "dist/torbrowser/([^/]+)/"') do set TBpath=%%a
set TBver=%TBpath:~16,-1%
::
for /f "delims=" %%b in ('%curl% -s %download_url%%TBver%/ ^| %grep% -o -E -m 1 ">tor-win64-([^/]+)zip"') do set TBpath1=%%b
set Tver=%TBpath1:~11,-4%
::
set dst=%~dp0Torbrowser\%TBver%
set opt=-c -t 0 -P %dst%
::
set locale=zh-CN
::set locale=en-US
::
:: get torbrowser from download url... 
::
echo get torbrowser from %download_url%...
echo .
::
%wget% %opt% %download_url%%TBver%/sha256sums-signed-build.txt
%wget% %opt% %download_url%%TBver%/sha256sums-signed-build.txt.asc
::
%wget% %opt% %download_url%%TBver%/tor-win32-%Tver%.zip
%wget% %opt% %download_url%%TBver%/tor-win32-%Tver%.zip.asc
%wget% %opt% %download_url%%TBver%/tor-win64-%Tver%.zip
%wget% %opt% %download_url%%TBver%/tor-win64-%Tver%.zip.asc
%wget% %opt% %download_url%%TBver%/tor-linux32-debug.tar.xz
%wget% %opt% %download_url%%TBver%/tor-linux32-debug.tar.xz.asc
%wget% %opt% %download_url%%TBver%/tor-linux64-debug.tar.xz
%wget% %opt% %download_url%%TBver%/tor-linux64-debug.tar.xz.asc
::
%wget% %opt% %download_url%%TBver%/torbrowser-install-%TBver%_%locale%.exe
%wget% %opt% %download_url%%TBver%/torbrowser-install-%TBver%_%locale%.exe.asc
%wget% %opt% %download_url%%TBver%/torbrowser-install-win64-%TBver%_%locale%.exe
%wget% %opt% %download_url%%TBver%/torbrowser-install-win64-%TBver%_%locale%.exe.asc
::
%wget% %opt% %download_url%%TBver%/TorBrowser-%TBver%-osx64_%locale%.dmg
%wget% %opt% %download_url%%TBver%/TorBrowser-%TBver%-osx64_%locale%.dmg.asc
::
%wget% %opt% %download_url%%TBver%/tor-browser-linux32-%TBver%_%locale%.tar.xz
%wget% %opt% %download_url%%TBver%/tor-browser-linux32-%TBver%_%locale%.tar.xz.asc
::
%wget% %opt% %download_url%%TBver%/tor-browser-linux64-%TBver%_%locale%.tar.xz
%wget% %opt% %download_url%%TBver%/tor-browser-linux64-%TBver%_%locale%.tar.xz.asc
::
%wget% %opt% %download_url%%TBver%/tor-browser-%TBver%-android-armv7-multi-qa.apk
%wget% %opt% %download_url%%TBver%/tor-browser-%TBver%-android-armv7-multi-qa.apk.asc
%wget% %opt% %download_url%%TBver%/tor-browser-%TBver%-android-armv7-multi-qa.apk.idsig
%wget% %opt% %download_url%%TBver%/tor-browser-%TBver%-android-armv7-multi.apk
%wget% %opt% %download_url%%TBver%/tor-browser-%TBver%-android-armv7-multi.apk.asc
::
echo download completed,have fun:-)
echo .
::
if %toraloneprivoxy%==y (
  start taskkill /im tor.exe /F /T
  start taskkill /im privoxy.exe /F /T
)
echo Press any key to exit.
pause > nul
endlocal & goto :eof
::
echo :::::::: The following code are for testing purposes only. You can comment them out later. ::::::::
echo :::::::: The code above are only for testing purposes. You can comment them out later. ::::::::
