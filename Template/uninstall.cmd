@echo off
REM **************************************************************************
REM Uninstallation script template
REM
REM Author: Andrew Levin
REM
REM Version: 1.0
REM **************************************************************************

REM Please change variable values
set HIVE=HIVE_NAME
set PACKAGE=PACKAGE_NAME
set PRODUCT=PRODUCT_NAME
set MANUFACTURER=MANUFACTURER_NAME

REM Set inventory script path
set SCRIPT_PATH=%temp%\%PACKAGE%.ps1

REM Put your uninstall instruction here

REM Check if uninstallation finished correctly
set EXITLEVEL=%errorlevel%

if %EXITLEVEL% == 0 goto repository
if %EXITLEVEL% == 3010 goto repository
REM If uninstallation failed go to end
goto end
REM Update local inventory with script
:repository
copy "%~dp0Repository.ps1" %SCRIPT_PATH%
powershell -ExecutionPolicy Unrestricted -file %SCRIPT_PATH% Uninstall %HIVE% %PACKAGE% %PRODUCT% %MANUFACTURER%
del /F /Q %SCRIPT_PATH%

REM End Install
:end
exit EXITLEVEL