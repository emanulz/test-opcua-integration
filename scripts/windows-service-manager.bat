@echo off
setlocal

:: OPC UA Integration - Windows Service Manager
:: This script provides easy management of the PM2 service and application
:: ✅ This script can be run from ANY directory (uses PM2 app names, not file paths)

echo.
echo ================================================
echo   OPC UA Integration - Service Manager
echo ================================================
echo.
echo ℹ️  This manager can be run from any directory
echo.

:menu
cls
echo.
echo ================================================
echo   OPC UA Integration - Service Manager
echo ================================================
echo.
echo Please select an option:
echo.
echo 1.  Start Application
echo 2.  Stop Application  
echo 3.  Restart Application
echo 4.  View Application Status
echo 5.  View Real-time Logs
echo 6.  View Application Info
echo 7.  Monitor CPU/Memory
echo 8.  Start PM2 Service
echo 9.  Stop PM2 Service
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

echo.
echo ❌ Invalid choice. Please try again.
echo.
timeout /t 2 >nul
goto menu

:start_app
echo.
echo ▶️  Starting OPC UA Integration application...
echo.
call pm2 start opcua-integration
if %errorLevel% equ 0 (
    echo ✅ Application started successfully!
) else (
    echo ❌ Failed to start application. Check if PM2 service is running.
)
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:stop_app
echo.
echo ⏹️  Stopping OPC UA Integration application...
echo.
call pm2 stop opcua-integration
if %errorLevel% equ 0 (
    echo ✅ Application stopped successfully!
) else (
    echo ❌ Failed to stop application. It might not be running.
)
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:restart_app
echo.
echo 🔄 Restarting OPC UA Integration application...
echo.
call pm2 restart opcua-integration
if %errorLevel% equ 0 (
    echo ✅ Application restarted successfully!
) else (
    echo ❌ Failed to restart application. Check if it exists in PM2.
)
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:status_app
echo.
echo 📊 Application Status:
echo =====================
echo.
call pm2 list
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:logs_app
echo.
echo 📋 Showing real-time logs...
echo ============================
echo.
echo Press Ctrl+C to stop viewing logs and return to menu
echo.
timeout /t 3 >nul
call pm2 logs opcua-integration
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:info_app
echo.
echo ℹ️  Application Information:
echo ===========================
echo.
call pm2 info opcua-integration
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:monitor_app
echo.
echo 📈 Opening PM2 Monitor...
echo ========================
echo.
echo Press 'q' to exit monitor and return to this menu
echo.
timeout /t 3 >nul
call pm2 monit
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:start_service
echo.
echo ▶️  Starting PM2 Service...
echo.
call sc start PM2
if %errorLevel% equ 0 (
    echo ✅ PM2 service started successfully!
) else (
    echo ❌ Failed to start PM2 service. It might already be running.
)
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:stop_service
echo.
echo ⏹️  Stopping PM2 Service...
echo.
call sc stop PM2
if %errorLevel% equ 0 (
    echo ✅ PM2 service stopped successfully!
) else (
    echo ❌ Failed to stop PM2 service. It might not be running.
)
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:status_service
echo.
echo 🔍 PM2 Service Status:
echo =====================
echo.
call sc query PM2
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:exit
echo.
echo 👋 Goodbye!
echo.
timeout /t 1 >nul
exit /b 0 
