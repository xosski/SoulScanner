@echo off
setlocal
set "BASH_PATH=C:\Program Files\Git\bin\bash.exe"
set "SCRIPT_PATH=E:\Tools\SoulScanner.sh"
set "TARGET_DIR=C:\Users\ek930\AppData\Local\Google\Chrome\User Data\Default\Cache\Cache_Data"

"%BASH_PATH%" "%SCRIPT_PATH%" "%TARGET_DIR%"
endlocal