@echo off
setlocal

:: OPC UA Integration - PM2 Service Installer
:: This script installs PM2 and sets up the Windows service
:: ⚠️ IMPORTANT: This script MUST be run from the application root directory

echo.
echo ================================================================
echo   OPC UA Integration - PM2 Service Installer
echo ================================================================
echo.
echo This script will:
echo   1. Install PM2 (if needed)
echo   2. Install pm2-windows-service (if needed)  
echo   3. Set up PM2 Windows Service
echo   4. Build the application
echo.
echo You will manually add your application and save configuration.
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
echo Step 1: Installing PM2 packages...
echo ==================================
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

:: Step 4: Setting up PM2 Windows Service
echo Step 4: Setting up PM2 Windows Service...
echo =========================================

echo Cleaning up any existing PM2 processes...
call pm2 kill >nul 2>&1

:: Check if PM2 service exists and remove it
call sc query PM2 >nul 2>&1
if %errorLevel% equ 0 (
    echo Found existing PM2 service, removing it...
    call sc stop PM2 >nul 2>&1
    timeout /t 2 >nul
    call pm2-service-uninstall >nul 2>&1
    timeout /t 3 >nul
    echo Existing PM2 service removed
)

:: Clean up any lingering processes
echo Cleaning up PM2 processes...
taskkill /f /im "PM2 Service.exe" >nul 2>&1
taskkill /f /im pm2.exe >nul 2>&1
timeout /t 5 >nul

:: Install fresh PM2 service
echo Installing fresh PM2 service...
call pm2-service-install
set INSTALL_RESULT=%errorLevel%

if %INSTALL_RESULT% neq 0 (
    echo WARNING: PM2 service installation failed with error %INSTALL_RESULT%
    echo Trying alternative installation method...
    call pm2-service-install --user-name "LocalSystem"
    set INSTALL_RESULT=%errorLevel%
)

:: Verify service was created
timeout /t 3 >nul
call sc query PM2 >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ ERROR: PM2 service was not properly installed
    echo.
    echo This is likely due to:
    echo   - Windows permissions issue
    echo   - Antivirus blocking service creation
    echo   - User account control restrictions
    echo.
    pause
    exit /b 1
)

echo PM2 service successfully created!

:: Start the service
echo Starting PM2 service...
call sc start PM2
timeout /t 3 >nul

:: Verify it's running
call sc query PM2 | findstr "RUNNING" >nul
if %errorLevel% equ 0 (
    echo ✅ PM2 Windows Service is running successfully!
) else (
    echo ⚠️  PM2 service created but may not be running
    echo You can start it manually with: sc start PM2
)

echo.

:: Installation complete
echo ================================================================
echo                    🎉 PM2 SERVICE SETUP COMPLETE! 🎉
echo ================================================================
echo.
echo PM2 and Windows Service are now ready!
echo.
echo ✅ PM2 installed and working
echo ✅ pm2-windows-service installed  
echo ✅ PM2 Windows Service created
echo ✅ Application built and directories created
echo.
echo Next steps (manual):
echo   1. pm2 start ecosystem.config.js
echo   2. pm2 save
echo   3. pm2 list (to verify)
echo.
echo Your application will then auto-start with Windows!
echo.
pause 
