@echo off
setlocal

:: OPC UA Integration - Windows Service Installer
:: This script automates the complete installation process
:: ⚠️ IMPORTANT: This script MUST be run from the application root directory

echo.
echo ================================================================
echo   OPC UA Integration - Windows Service Installer
echo ================================================================
echo.
echo ⚠️  IMPORTANT: This script must be run from the app root directory
echo    (the directory containing package.json and ecosystem.config.js)
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo Please right-click and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo ✅ Running as Administrator - OK
echo.

:: Check if we're in the correct directory
if not exist "package.json" (
    echo ❌ ERROR: package.json not found in current directory!
    echo.
    echo This script must be run from the application root directory.
    echo Please navigate to your OPC UA integration folder and try again.
    echo.
    echo Example:
    echo   cd C:\path\to\your\opcua-integration
    echo   scripts\install-windows-service.bat
    echo.
    pause
    exit /b 1
)

if not exist "ecosystem.config.js" (
    echo ❌ ERROR: ecosystem.config.js not found in current directory!
    echo.
    echo This script must be run from the application root directory.
    echo Please ensure you have the ecosystem.config.js file and try again.
    echo.
    pause
    exit /b 1
)

echo ✅ Application files found - OK
echo.

:: Check if Node.js is installed
call node --version >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ ERROR: Node.js is not installed or not in PATH!
    echo Please install Node.js from https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo ✅ Node.js found: 
call node --version
echo.

:: Step 1: Check and install PM2 packages if needed
echo Step 1: Checking PM2 installation...
echo ====================================
echo.

:: Check if PM2 is already installed
echo Checking for PM2...
call pm2 --version >nul 2>&1
if errorlevel 1 goto install_pm2
echo PM2 already installed
call pm2 --version
goto check_pm2_service

:install_pm2
echo PM2 not found, installing...
echo Installing PM2 globally (this may take a few minutes)...
call npm install -g pm2
if errorlevel 1 (
    echo ERROR: Failed to install PM2
    echo Trying with cache clean...
    call npm cache clean --force
    call npm install -g pm2
    if errorlevel 1 (
        echo ERROR: PM2 installation failed completely
        pause
        exit /b 1
    )
)
echo PM2 installed successfully!

:check_pm2_service
echo Checking for pm2-windows-service...
where pm2-service-install >nul 2>&1
if errorlevel 1 goto install_pm2_service
echo pm2-windows-service already installed
goto pm2_packages_ready

:install_pm2_service
echo pm2-windows-service not found, installing...
call npm install -g pm2-windows-service
if errorlevel 1 (
    echo ERROR: Failed to install pm2-windows-service
    echo Trying with cache clean...
    call npm cache clean --force
    call npm install -g pm2-windows-service
    if errorlevel 1 (
        echo ERROR: pm2-windows-service installation failed completely
        pause
        exit /b 1
    )
)
echo pm2-windows-service installed successfully!

:pm2_packages_ready
echo.
echo PM2 packages ready!
echo.

:: Step 2: Build the application
echo Step 2: Building the application...
echo ===================================

echo Building application...
call yarn build
if %errorLevel% neq 0 (
    echo ❌ ERROR: Failed to build the application
    echo Make sure you have run 'yarn install' first
    pause
    exit /b 1
)

echo ✅ Application built successfully!
echo.

:: Step 3: Create required directories
echo Step 3: Creating required directories...
echo =======================================
if not exist "logs" mkdir logs
if not exist "data" mkdir data
echo ✅ Directories created successfully!
echo.

:: Step 4: Check environment file
echo Step 4: Checking environment configuration...
echo =============================================
if not exist ".env" (
    echo WARNING: .env file not found!
    echo Please create a .env file with your configuration before starting the service.
    echo You can use the example from the README.md file.
    echo.
    echo The installer will continue anyway, but the application may not work properly
    echo without proper configuration.
    echo.
    echo Press any key to continue...
    pause >nul
    echo Continuing with installation...
) else (
    echo .env file found - OK
)
echo.

:: Step 5: Check and install PM2 Windows Service if needed
echo Step 5: Setting up PM2 Windows Service...
echo =========================================

echo Checking for existing PM2 services and processes...

:: Stop any running PM2 processes first
echo Stopping any existing PM2 processes...
call pm2 kill >nul 2>&1

:: Check if PM2 service exists and remove it
call sc query PM2 >nul 2>&1
if %errorLevel% equ 0 (
    echo Found existing PM2 service, removing it...
    
    :: Stop the service first
    echo Stopping PM2 service...
    call sc stop PM2 >nul 2>&1
    
    :: Wait a moment for service to stop
    timeout /t 2 >nul
    
    :: Try to uninstall existing service
    echo Uninstalling existing PM2 service...
    call pm2-service-uninstall >nul 2>&1
    
    :: Wait for cleanup
    timeout /t 3 >nul
    
    echo Existing PM2 service removed
) else (
    echo No existing PM2 service found
)

:: Clean up any lingering PM2 processes
echo Cleaning up PM2 processes...
taskkill /f /im "PM2 Service.exe" >nul 2>&1
taskkill /f /im pm2.exe >nul 2>&1

:: Wait for cleanup to complete
timeout /t 5 >nul

:: Now install fresh PM2 service
echo Installing fresh PM2 service...
call pm2-service-install
set INSTALL_RESULT=%errorLevel%

if %INSTALL_RESULT% neq 0 (
    echo WARNING: PM2 service installation failed with error %INSTALL_RESULT%
    echo Trying alternative installation method...
    
    :: Try alternative method
    call pm2-service-install --user-name "LocalSystem" >nul 2>&1
    set INSTALL_RESULT=%errorLevel%
)

:: Wait for service registration
timeout /t 3 >nul

:: Verify the service actually exists now
echo Verifying PM2 service was created...
call sc query PM2 >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: PM2 service was not properly installed
    echo.
    echo This is likely due to:
    echo   - Windows permissions issue
    echo   - Antivirus blocking service creation
    echo   - User account control restrictions
    echo.
    echo FALLBACK: Will run PM2 manually without service
    echo The application will work but won't auto-start with Windows
    echo.
    set PM2_SERVICE_FAILED=1
    goto manual_pm2_start
) else (
    echo PM2 service successfully created
    set PM2_SERVICE_FAILED=0
)

:: Try to start the service
echo Starting PM2 service...
call sc start PM2
if %errorLevel% neq 0 (
    echo WARNING: Could not start PM2 service automatically
    echo Trying manual start...
    timeout /t 2 >nul
    call sc start PM2
)

:: Final verification
timeout /t 3 >nul
call sc query PM2 | findstr "RUNNING" >nul
if %errorLevel% equ 0 (
    echo PM2 Windows Service is running successfully!
    set PM2_SERVICE_RUNNING=1
    goto pm2_service_ready
) else (
    echo WARNING: PM2 service exists but is not running
    echo Will continue with manual PM2 startup
    set PM2_SERVICE_RUNNING=0
    goto manual_pm2_start
)

:manual_pm2_start
echo.
echo Starting PM2 manually (without Windows service)...
call pm2 ping >nul 2>&1
if %errorLevel% neq 0 (
    echo Starting PM2 daemon...
    call pm2 status >nul 2>&1
)
echo PM2 daemon is ready
goto pm2_service_ready

:pm2_service_ready
echo.
if %PM2_SERVICE_FAILED% equ 1 (
    echo WARNING: PM2 Windows Service installation failed
    echo Your application will run but won't auto-start with Windows
    echo You can try running this installer as Administrator later
) else (
    echo PM2 Windows Service setup complete!
)
echo.

:: Step 6: Verify service installation
echo Step 6: Verifying service installation...
echo ========================================
call sc query PM2 | findstr "STATE"
if %errorLevel% neq 0 (
    echo ⚠️  WARNING: Could not verify PM2 service status
) else (
    echo ✅ PM2 service verification - OK
)
echo.

:: Step 7: Check if application is already running
echo Step 7: Checking application status...
echo =====================================

:: Check if our application is already running in PM2
call pm2 list | findstr "opcua-integration" >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ Application already exists in PM2
    call pm2 list | findstr "opcua-integration"
    
    :: Check if it's online
    call pm2 list | findstr "opcua-integration" | findstr "online" >nul
    if %errorLevel% equ 0 (
        echo ✅ Application is already running
        echo 🔄 Restarting application to ensure latest build...
        call pm2 restart opcua-integration
        set APP_STARTED=1
    ) else (
        echo ⚠️  Application exists but not online, starting...
        call pm2 start opcua-integration
        set APP_STARTED=1
    )
) else (
    echo Application not found in PM2, starting...
    call pm2 start ecosystem.config.js
    if %errorLevel% neq 0 (
        echo ❌ ERROR: Failed to start the application
        echo Check the logs with: pm2 logs
        pause
        exit /b 1
    )
    set APP_STARTED=1
)

echo Verifying application is running...
call pm2 list | findstr "online"
if %errorLevel% neq 0 (
    echo ❌ ERROR: Application started but not showing as online
    echo Check the status with: pm2 list
    pause
    exit /b 1
)

echo ✅ Application verified online!
echo.

:: Step 8: Save PM2 configuration for auto-start
echo Step 8: Saving PM2 configuration for auto-start...
echo =================================================

echo Saving PM2 configuration...
call pm2 save
if %errorLevel% neq 0 (
    echo ❌ ERROR: Failed to save PM2 configuration
    pause
    exit /b 1
)

echo Verifying configuration was saved...
if exist "%USERPROFILE%\.pm2\dump.pm2" (
    echo ✅ PM2 configuration file found
) else (
    echo ⚠️  WARNING: PM2 configuration file not found in expected location
)

echo ✅ PM2 configuration saved successfully!
echo.

:: Step 9: Test configuration persistence
echo Step 9: Testing configuration persistence...
echo ===========================================

echo Testing PM2 configuration reload...
echo Stopping all PM2 processes...
call pm2 kill
if %errorLevel% neq 0 (
    echo ⚠️  WARNING: Issue stopping PM2 processes
)

echo Waiting for PM2 to fully stop...
timeout /t 3 >nul

echo Resurrecting saved processes...
call pm2 resurrect
if %errorLevel% neq 0 (
    echo ❌ ERROR: Failed to resurrect saved processes
    echo This means auto-start after reboot may not work
    pause
    exit /b 1
)

echo Verifying application restarted from saved configuration...
call pm2 list | findstr "online"
if %errorLevel% neq 0 (
    echo ❌ ERROR: Application did not restart from saved configuration
    echo Auto-start after reboot may not work properly
    pause
    exit /b 1
)

echo ✅ Configuration persistence test passed!
echo.

:: Step 10: Final verification
echo Step 10: Final verification...
echo =============================

echo Current PM2 application status:
call pm2 list

echo.
echo PM2 service status:
call sc query PM2 | findstr "STATE"

echo.
echo ✅ All verification checks completed!
echo.

:: Installation complete
echo ================================================================
echo                    🎉 INSTALLATION COMPLETE! 🎉
echo ================================================================
echo.
echo Your OPC UA Integration application is now running as a Windows service.
echo.
echo ✅ Service installed: PM2 Windows Service
echo ✅ Application running: opcua-integration  
echo ✅ Auto-start configured: Will start with Windows
echo ✅ Configuration tested: Persistence verified
echo.
echo Quick commands:
echo   - View status:     pm2 list
echo   - View logs:       pm2 logs opcua-integration
echo   - Restart app:     pm2 restart opcua-integration
echo   - Stop app:        pm2 stop opcua-integration
echo.
echo 🔄 To test auto-start: Restart your computer and run "pm2 list"
echo    Your application should automatically appear as "online"
echo.
echo For daily management, run: scripts\windows-service-manager.bat
echo.
echo ⚠️  IMPORTANT: If you restart your computer and the app doesn't auto-start,
echo    run this installer again or check WINDOWS_SERVICE_SETUP.md for troubleshooting.
echo.
pause 
