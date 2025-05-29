@echo off
setlocal

:: OPC UA Integration - Windows Service Manager
:: This script provides easy management of the PM2 service and application

echo.
echo ================================================
echo   OPC UA Integration - Service Manager
echo ================================================
echo.

:menu
echo Please select an option:
echo.
echo 1. Start Application
echo 2. Stop Application  
echo 3. Restart Application
echo 4. View Application Status
echo 5. View Real-time Logs
echo 6. View Application Info
echo 7. Monitor CPU/Memory
echo 8. Start PM2 Service
echo 9. Stop PM2 Service
echo 10. Check PM2 Service Status
echo 11. Exit
echo.
set /p choice="Enter your choice (1-11): "

if "%choice%"=="1" goto start_app
if "%choice%"=="2" goto stop_app
if "%choice%"=="3" goto restart_app
if "%choice%"=="4" goto status_app
if "%choice%"=="5" goto logs_app
if "%choice%"=="6" goto info_app
if "%choice%"=="7" goto monitor_app
if "%choice%"=="8" goto start_service
if "%choice%"=="9" goto stop_service
if "%choice%"=="10" goto status_service
if "%choice%"=="11" goto exit

echo Invalid choice. Please try again.
echo.
goto menu

:start_app
echo.
echo Starting OPC UA Integration application...
pm2 start opcua-integration
echo.
pause
goto menu

:stop_app
echo.
echo Stopping OPC UA Integration application...
pm2 stop opcua-integration
echo.
pause
goto menu

:restart_app
echo.
echo Restarting OPC UA Integration application...
pm2 restart opcua-integration
echo.
pause
goto menu

:status_app
echo.
echo Application Status:
pm2 list
echo.
pause
goto menu

:logs_app
echo.
echo Showing real-time logs (Press Ctrl+C to exit):
echo.
pm2 logs opcua-integration
pause
goto menu

:info_app
echo.
echo Application Information:
pm2 info opcua-integration
echo.
pause
goto menu

:monitor_app
echo.
echo Opening PM2 Monitor (Press 'q' to exit)...
echo.
pm2 monit
pause
goto menu

:start_service
echo.
echo Starting PM2 Service...
sc start PM2
echo.
pause
goto menu

:stop_service
echo.
echo Stopping PM2 Service...
sc stop PM2
echo.
pause
goto menu

:status_service
echo.
echo PM2 Service Status:
sc query PM2
echo.
pause
goto menu

:exit
echo.
echo Goodbye!
exit /b 0 
