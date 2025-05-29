@echo off
setlocal enabledelayedexpansion

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

:: Step 1: Install PM2 packages
echo Step 1: Installing PM2 packages...
echo =====================================
echo.

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

echo Verifying PM2 installation...
call pm2 --version >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ ERROR: PM2 installed but not accessible
    pause
    exit /b 1
)

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

echo ✅ PM2 packages installed successfully!
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
    if /i "!continue!" neq "y" (
        echo Installation cancelled.
        pause
        exit /b 1
    )
) else (
    echo ✅ .env file found - OK
)
echo.

:: Step 5: Install PM2 as Windows Service
echo Step 5: Installing PM2 as Windows Service...
echo ============================================

echo Installing PM2 as Windows service...
call pm2-service-install
if %errorLevel% neq 0 (
    echo ❌ ERROR: Failed to install PM2 service
    pause
    exit /b 1
)

echo ✅ PM2 service installed successfully!
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

:: Step 7: Start the application
echo Step 7: Starting the application...
echo ==================================

echo Starting application with PM2...
call pm2 start ecosystem.config.js
if %errorLevel% neq 0 (
    echo ❌ ERROR: Failed to start the application
    echo Check the logs with: pm2 logs
    pause
    exit /b 1
)

echo ✅ Application started successfully!
echo.

:: Step 8: Save PM2 configuration
echo Step 8: Saving PM2 configuration...
echo ===================================

echo Saving PM2 configuration...
call pm2 save
if %errorLevel% neq 0 (
    echo ⚠️  WARNING: Failed to save PM2 configuration
) else (
    echo ✅ PM2 configuration saved successfully!
)
echo.

:: Installation complete
echo ================================================================
echo                    🎉 INSTALLATION COMPLETE! 🎉
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
echo or run scripts\windows-service-manager.bat (can be run from anywhere)
echo.
pause 
