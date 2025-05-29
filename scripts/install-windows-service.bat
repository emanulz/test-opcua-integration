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
set PM2_INSTALLED=0
call pm2 --version >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ PM2 already installed
    for /f "tokens=*" %%i in ('pm2 --version 2^>nul') do echo    Version: %%i
    set PM2_INSTALLED=1
) else (
    echo PM2 not found, will install...
)

:: Check if pm2-windows-service is available
echo Checking for pm2-windows-service...
set PM2_SERVICE_INSTALLED=0
where pm2-service-install >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ pm2-windows-service already installed
    set PM2_SERVICE_INSTALLED=1
) else (
    echo pm2-windows-service not found, will install...
)

echo.
echo Installation status:
echo   PM2: %PM2_INSTALLED%
echo   pm2-windows-service: %PM2_SERVICE_INSTALLED%
echo.

:: Install PM2 if needed
if %PM2_INSTALLED% equ 0 (
    echo Installing PM2 globally (this may take a few minutes)...
    call npm install -g pm2
    if %errorLevel% neq 0 (
        echo ❌ ERROR: Failed to install PM2
        echo.
        echo Trying with cache clean...
        call npm cache clean --force
        call npm install -g pm2
        if %errorLevel% neq 0 (
            echo ❌ ERROR: PM2 installation failed completely
            pause
            exit /b 1
        )
    )
    echo ✅ PM2 installed successfully!
) else (
    echo 🔄 Skipping PM2 installation (already installed)
)

:: Install pm2-windows-service if needed
if %PM2_SERVICE_INSTALLED% equ 0 (
    echo.
    echo Installing pm2-windows-service...
    call npm install -g pm2-windows-service
    if %errorLevel% neq 0 (
        echo ❌ ERROR: Failed to install pm2-windows-service
        echo.
        echo Trying with cache clean...
        call npm cache clean --force
        call npm install -g pm2-windows-service
        if %errorLevel% neq 0 (
            echo ❌ ERROR: pm2-windows-service installation failed completely
            pause
            exit /b 1
        )
    )
    echo ✅ pm2-windows-service installed successfully!
) else (
    echo 🔄 Skipping pm2-windows-service installation (already installed)
)

echo.
echo ✅ PM2 packages ready!
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
    echo ⚠️  WARNING: .env file not found!
    echo Please create a .env file with your configuration before starting the service.
    echo You can use the example from the README.md file.
    echo.
    set /p continue="Do you want to continue anyway? (y/n): "
    if /i "%continue%" neq "y" (
        echo Installation cancelled.
        pause
        exit /b 1
    )
) else (
    echo ✅ .env file found - OK
)
echo.

:: Step 5: Check and install PM2 Windows Service if needed
echo Step 5: Checking PM2 Windows Service...
echo =======================================

:: Check if PM2 service is already installed
call sc query PM2 >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ PM2 Windows Service already installed
    call sc query PM2 | findstr "STATE"
    
    :: Check if service is running
    call sc query PM2 | findstr "RUNNING" >nul
    if %errorLevel% equ 0 (
        echo ✅ PM2 service is running
        set PM2_SERVICE_RUNNING=1
    ) else (
        echo ⚠️  PM2 service exists but not running, starting...
        call sc start PM2
        set PM2_SERVICE_RUNNING=1
    )
    set PM2_SERVICE_EXISTS=1
) else (
    echo PM2 Windows Service not found, installing...
    call pm2-service-install
    if %errorLevel% neq 0 (
        echo ❌ ERROR: Failed to install PM2 service
        pause
        exit /b 1
    )
    echo ✅ PM2 service installed successfully!
    set PM2_SERVICE_EXISTS=1
    set PM2_SERVICE_RUNNING=1
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
