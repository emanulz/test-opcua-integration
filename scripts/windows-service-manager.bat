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
echo [INFO] This manager can be run from any directory
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
echo 11. [RECOVERY] Recovery Mode (Reset PM2 Apps)
echo 12. Exit
echo.
set /p choice="Enter your choice (1-12): "

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
if "%choice%"=="11" goto recovery_mode
if "%choice%"=="12" goto exit

echo.
echo [ERROR] Invalid choice. Please try again.
echo.
timeout /t 2 >nul
goto menu

:start_app
echo.
echo [START] Starting OPC UA Integration application...
echo.
call pm2 start opcua-integration
if %errorLevel% equ 0 (
    echo [OK] Application started successfully!
) else (
    echo [ERROR] Failed to start application. Check if PM2 service is running.
)
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:stop_app
echo.
echo [STOP] Stopping OPC UA Integration application...
echo.
call pm2 stop opcua-integration
if %errorLevel% equ 0 (
    echo [OK] Application stopped successfully!
) else (
    echo [ERROR] Failed to stop application. It might not be running.
)
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:restart_app
echo.
echo [RESTART] Restarting OPC UA Integration application...
echo.
call pm2 restart opcua-integration
if %errorLevel% equ 0 (
    echo [OK] Application restarted successfully!
) else (
    echo [ERROR] Failed to restart application. Check if it exists in PM2.
)
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:status_app
echo.
echo [STATUS] Application Status:
echo =====================
echo.
call pm2 list
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:logs_app
echo.
echo [LOGS] Showing real-time logs...
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
echo [INFO] Application Information:
echo ===========================
echo.
call pm2 info opcua-integration
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:monitor_app
echo.
echo [MONITOR] Opening PM2 Monitor...
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
echo [START] Starting PM2 Service...
echo.
call sc start PM2
if %errorLevel% equ 0 (
    echo [OK] PM2 service started successfully!
) else (
    echo [ERROR] Failed to start PM2 service. It might already be running.
)
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:stop_service
echo.
echo [STOP] Stopping PM2 Service...
echo.
call sc stop PM2
if %errorLevel% equ 0 (
    echo [OK] PM2 service stopped successfully!
) else (
    echo [ERROR] Failed to stop PM2 service. It might not be running.
)
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:status_service
echo.
echo [STATUS] PM2 Service Status:
echo =====================
echo.
call sc query PM2
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:recovery_mode
echo.
echo [RECOVERY] RECOVERY MODE - Resetting PM2 Application Configuration
echo ========================================================
echo.
echo This will:
echo   1. Navigate to application directory
echo   2. Clear existing PM2 processes
echo   3. Start fresh from ecosystem.config.js
echo   4. Save the configuration
echo.
echo [WARNING] This will stop all current PM2 processes!
echo.
set /p confirm="Continue with recovery? (y/N): "
if /i not "%confirm%"=="y" (
    echo Recovery cancelled.
    echo.
    echo Press any key to return to main menu...
    pause >nul
    goto menu
)

echo.
echo [RECOVERY] Starting recovery process...
echo.

:: Find the application directory
echo [SEARCH] Looking for application directory...
set "app_dir="

:: Check current directory first
if exist "ecosystem.config.js" (
    set "app_dir=%CD%"
    echo [OK] Found ecosystem.config.js in current directory
    goto found_dir
)

:: Check parent directory
if exist "..\ecosystem.config.js" (
    set "app_dir=%CD%\.."
    echo [OK] Found ecosystem.config.js in parent directory
    goto found_dir
)

:: Check common locations
for %%d in (
    "C:\ArenaIntegration\test-opcua-integration"
    "C:\opcua-integration"
    "C:\app"
    "C:\projects\opcua-integration"
    "%USERPROFILE%\opcua-integration"
) do (
    if exist "%%d\ecosystem.config.js" (
        set "app_dir=%%d"
        echo [OK] Found ecosystem.config.js in %%d
        goto found_dir
    )
)

:: If not found, ask user
echo [ERROR] Could not find ecosystem.config.js automatically
echo.
set /p app_dir="Please enter the full path to your application directory: "
if not exist "%app_dir%\ecosystem.config.js" (
    echo [ERROR] ecosystem.config.js not found in "%app_dir%"
    echo Recovery failed.
    echo.
    echo Press any key to return to main menu...
    pause >nul
    goto menu
)

:found_dir
echo.
echo [PATH] Using application directory: %app_dir%
echo.

:: Change to application directory
cd /d "%app_dir%"
if %errorLevel% neq 0 (
    echo [ERROR] Could not change to directory "%app_dir%"
    echo.
    echo Press any key to return to main menu...
    pause >nul
    goto menu
)

:: Step 1: Clear existing PM2 processes
echo [CLEAN] Step 1: Clearing existing PM2 processes...
call pm2 delete all >nul 2>&1
timeout /t 2 >nul

:: Step 2: Start fresh from ecosystem.config.js
echo [START] Step 2: Starting application from ecosystem.config.js...
call pm2 start ecosystem.config.js
if %errorLevel% neq 0 (
    echo [ERROR] Failed to start from ecosystem.config.js
    echo Please check your ecosystem.config.js file for errors.
    echo.
    echo Press any key to return to main menu...
    pause >nul
    goto menu
)

:: Step 3: Wait for PM2 to stabilize
echo [WAIT] Step 3: Waiting for PM2 to stabilize...
timeout /t 5 >nul

:: Step 4: Save configuration
echo [SAVE] Step 4: Saving PM2 configuration...
call pm2 save
if %errorLevel% neq 0 (
    echo [WARNING] Failed to save PM2 configuration
    echo Your apps are running but may not auto-restart on reboot.
) else (
    echo [OK] PM2 configuration saved successfully!
)

:: Step 5: Show final status
echo.
echo [STATUS] Final Status:
echo ================
call pm2 list

echo.
echo [SUCCESS] RECOVERY COMPLETE!
echo.
echo Your application should now be running properly.
echo The configuration has been saved for auto-restart.
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:exit
echo.
echo [EXIT] Goodbye!
echo.
timeout /t 1 >nul
exit /b 0 
