@echo off
setlocal enabledelayedexpansion

:: OPC UA Integration - Windows Service Installer
:: This script automates the complete installation process

echo.
echo ================================================================
echo   OPC UA Integration - Windows Service Installer
echo ================================================================
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

echo Running as Administrator - OK
echo.

:: Check if Node.js is installed
node --version >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Node.js is not installed or not in PATH!
    echo Please install Node.js from https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo Node.js found: 
node --version
echo.

:: Step 1: Install PM2 packages
echo Step 1: Installing PM2 packages...
echo =====================================
npm install -g pm2
if %errorLevel% neq 0 (
    echo ERROR: Failed to install PM2
    pause
    exit /b 1
)

npm install -g pm2-windows-service
if %errorLevel% neq 0 (
    echo ERROR: Failed to install pm2-windows-service
    pause
    exit /b 1
)

echo PM2 packages installed successfully!
echo.

:: Step 2: Build the application
echo Step 2: Building the application...
echo ===================================
if not exist "package.json" (
    echo ERROR: package.json not found!
    echo Please run this script from the application root directory.
    pause
    exit /b 1
)

call yarn build
if %errorLevel% neq 0 (
    echo ERROR: Failed to build the application
    echo Make sure you have run 'yarn install' first
    pause
    exit /b 1
)

echo Application built successfully!
echo.

:: Step 3: Create required directories
echo Step 3: Creating required directories...
echo =======================================
if not exist "logs" mkdir logs
if not exist "data" mkdir data
echo Directories created successfully!
echo.

:: Step 4: Check environment file
echo Step 4: Checking environment configuration...
echo =============================================
if not exist ".env" (
    echo WARNING: .env file not found!
    echo Please create a .env file with your configuration before starting the service.
    echo You can use the example from the README.md file.
    echo.
    set /p continue="Do you want to continue anyway? (y/n): "
    if /i "!continue!" neq "y" (
        echo Installation cancelled.
        pause
        exit /b 1
    )
) else (
    echo .env file found - OK
)
echo.

:: Step 5: Install PM2 as Windows Service
echo Step 5: Installing PM2 as Windows Service...
echo ============================================
pm2-service-install
if %errorLevel% neq 0 (
    echo ERROR: Failed to install PM2 service
    pause
    exit /b 1
)

echo PM2 service installed successfully!
echo.

:: Step 6: Verify service installation
echo Step 6: Verifying service installation...
echo ========================================
sc query PM2 | findstr "STATE"
if %errorLevel% neq 0 (
    echo WARNING: Could not verify PM2 service status
) else (
    echo PM2 service verification - OK
)
echo.

:: Step 7: Start the application
echo Step 7: Starting the application...
echo ==================================
pm2 start ecosystem.config.js
if %errorLevel% neq 0 (
    echo ERROR: Failed to start the application
    echo Check the logs with: pm2 logs
    pause
    exit /b 1
)

echo Application started successfully!
echo.

:: Step 8: Save PM2 configuration
echo Step 8: Saving PM2 configuration...
echo ===================================
pm2 save
if %errorLevel% neq 0 (
    echo WARNING: Failed to save PM2 configuration
) else (
    echo PM2 configuration saved successfully!
)
echo.

:: Installation complete
echo ================================================================
echo                    INSTALLATION COMPLETE!
echo ================================================================
echo.
echo Your OPC UA Integration application is now running as a Windows service.
echo.
echo Quick commands:
echo   - View status:     pm2 list
echo   - View logs:       pm2 logs opcua-integration
echo   - Restart app:     pm2 restart opcua-integration
echo   - Stop app:        pm2 stop opcua-integration
echo.
echo The service will automatically start when Windows boots.
echo.
echo To test auto-start, restart your computer and run: pm2 list
echo.
echo For more commands, see WINDOWS_SERVICE_SETUP.md
echo or run scripts\windows-service-manager.bat
echo.
pause 
