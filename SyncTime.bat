@echo off

:: Server Time Sync Script by Austin Porto
:: Set time server to windows & google.

w32tm /config /manualpeerlist:"0.time.windows.com,0x1 1. time.google.com ,0X1" /syncfromflags:manual /reliable:yes /update

:: Stop and start time sync service

net stop w32time
net start w32time

:: Resync time service

w32tm /resync

:: Exit code

echo Sync Complete
echo Exiting in 30 seconds...
timeout /t 30 /nobreak

exit