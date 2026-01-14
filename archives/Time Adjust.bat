@echo off
setlocal enabledelayedexpansion

:: 1. Check for Administrative Privileges
echo Checking for Administrator rights...
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as Administrator.
    echo Please right-click and select "Run as administrator".
    pause
    exit /b 1
)

:: 2. Define NTP Servers
:: The 0x8 flag tells Windows to send requests in Client mode (recommended for external servers).
set NTP_SERVERS="pool.ntp.org,0x8 time.google.com,0x8, time.windows.com,0x8"

echo.
echo ----------------------------------------------------
echo STEP 1: Stopping Windows Time Service...
net stop w32time >nul 2>&1

echo STEP 2: Configuring NTP Peers...
:: /syncfromflags:manual tells Windows to ignore the Domain Hierarchy and use your list.
w32tm /config /manualpeerlist:%NTP_SERVERS% /syncfromflags:manual /reliable:YES /update

echo STEP 3: Starting Windows Time Service...
net start w32time >nul 2>&1

echo STEP 4: Forcing Immediate Resync...
w32tm /resync /rediscover

echo ----------------------------------------------------
echo.

:: 3. Verification
echo Final Status Check:
w32tm /query /status | findstr /C:"Source" /C:"Leap"
w32tm /query /peers

echo.
echo Configuration Complete!
pause