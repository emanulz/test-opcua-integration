# Windows Service Setup Guide - OPC UA Integration

This guide will help you set up the OPC UA Integration application as a Windows service using PM2, so it starts automatically when Windows boots.

## Directory Requirements ⚠️

### Installation Script

- **`scripts/install-windows-service.bat`** - **MUST** be run from the **application root directory**
  - Needs access to `package.json`, `ecosystem.config.js`, and source files
  - Creates `logs/` and `data/` directories in current location

### Management Script  

- **`scripts/windows-service-manager.bat`** - **Can be run from ANY directory**
  - Uses PM2 application names (not file paths)
  - Works from anywhere on your system

## Prerequisites

- **Node.js**: Version 22.14.0 or higher
- **Windows**: Windows 10/11 or Windows Server
- **Administrator Access**: Required for service installation
- **Built Application**: Run `yarn build` first to create the `dist` folder

## Step 1: Install Required Global Packages

Open **Command Prompt as Administrator** and run:

```cmd
npm install -g pm2
npm install -g pm2-windows-service
```

## Step 2: Prepare Your Application

### 2.1 Navigate to Application Directory

```cmd
cd C:\path\to\your\opcua-integration
```

### 2.2 Build the Application

```cmd
yarn build
```

### 2.3 Create Required Directories

```cmd
mkdir logs
mkdir data
```

### 2.4 Configure Environment Variables

Ensure your `.env` file is properly configured with all required variables:

```env
# OPC UA Server Configuration
OPC_ENDPOINT=opc.tcp://your-opcua-server:4840
STATE_NODE_ID=ns=2;s=StateMachineNode
ITEM_ID_NODE_ID=ns=2;s=ItemIdNode
RESULT_NODE_ID=ns=2;s=ResultNode
ERROR_NODE_ID=ns=2;s=ErrorNode
START_STATE_VALUE=START
DONE_STATE_VALUE=DONE
NO_ERROR_CODE=0
GENERAL_ERROR_CODE=9
ITEM_NOT_FOUND_ERROR_CODE=1

# API Configuration
API_BASE_URL=https://your-api-endpoint.com
API_USER=yourUser
API_PASSWORD=yourPassword
API_WORKSPACE_ID=yourWorkspaceId
API_USAGE_REASON=integration
```

## Step 3: Install PM2 as Windows Service

### ⚠️ IMPORTANT: Run Command Prompt as Administrator

```cmd
pm2-service-install
```

**Expected Output:**

``` cmd
Installing PM2 as a Windows service...
Service 'PM2' installed successfully
Starting PM2 service...
PM2 service started successfully
```

### 3.1 Verify Service Installation

```cmd
sc query PM2
```

**Expected Output:**

``` cmd
SERVICE_NAME: PM2
        TYPE               : 10  WIN32_OWN_PROCESS
        STATE              : 4  RUNNING
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x0
```

## Step 4: Configure and Start Your Application

### 4.1 Navigate to Your Application Directory (if not already there)

```cmd
cd C:\path\to\your\opcua-integration
```

### 4.2 Start Your Application with PM2

```cmd
pm2 start ecosystem.config.js
```

**Expected Output:**

``` cmd
[PM2] Starting C:\path\to\your\opcua-integration\dist\index.js in fork_mode (1 instance)
[PM2] Done.
┌─────────────────┬────┬─────────┬──────┬───────┬────────┬─────────┬────────┬─────┬───────────┬──────┬──────────┐
│ App name        │ id │ version │ mode │ pid   │ status │ restart │ uptime │ cpu │ mem       │ user │ watching │
├─────────────────┼────┼─────────┼──────┼───────┼────────┼─────────┼────────┼─────┼───────────┼──────┼──────────┤
│ opcua-integration│ 0  │ 1.0.0   │ fork │ 12345 │ online │ 0       │ 0s     │ 0%  │ 32.1 MB   │ user │ disabled │
└─────────────────┴────┴─────────┴──────┴───────┴────────┴─────────┴────────┴─────┴───────────┴──────┴──────────┘
```

### 4.3 Save PM2 Configuration

```cmd
pm2 save
```

**Expected Output:**

``` cmd
[PM2] Saving current process list...
[PM2] Successfully saved in C:\Users\YourUser\.pm2\dump.pm2
```

## Step 5: Test System Startup

### 5.1 Restart Windows

```cmd
shutdown /r /t 0
```

### 5.2 Verify Application Started Automatically

After Windows restarts, open Command Prompt and run:

```cmd
pm2 list
```

**Expected Output:**

``` cmd
┌─────────────────┬────┬─────────┬──────┬───────┬────────┬─────────┬────────┬─────┬───────────┬──────┬──────────┐
│ App name        │ id │ version │ mode │ pid   │ status │ restart │ uptime │ cpu │ mem       │ user │ watching │
├─────────────────┼────┼─────────┼──────┼───────┼────────┼─────────┼────────┼─────┼───────────┼──────┼──────────┤
│ opcua-integration│ 0  │ 1.0.0   │ fork │ 67890 │ online │ 0       │ 5m     │ 0%  │ 28.3 MB   │ user │ disabled │
└─────────────────┴────┴─────────┴──────┴───────┴────────┴─────────┴────────┴─────┴───────────┴──────┴──────────┘
```

## Daily Management Commands

### Application Management

#### Start Application

```cmd
pm2 start opcua-integration
```

#### Stop Application

```cmd
pm2 stop opcua-integration
```

#### Restart Application

```cmd
pm2 restart opcua-integration
```

#### Reload Application (Zero Downtime)

```cmd
pm2 reload opcua-integration
```

#### Delete Application from PM2

```cmd
pm2 delete opcua-integration
```

### Service Management

#### Start PM2 Service (if stopped)

```cmd
sc start PM2
```

or

```cmd
pm2-service-start
```

#### Stop PM2 Service

```cmd
sc stop PM2
```

or

```cmd
pm2-service-stop
```

#### Restart PM2 Service (if needed)

```cmd
sc stop PM2
sc start PM2
```

### Monitoring Commands

#### View Application Status

```cmd
pm2 list
```

#### View Real-time Logs

```cmd
pm2 logs opcua-integration
```

#### View Last 100 Log Lines

```cmd
pm2 logs opcua-integration --lines 100
```

#### Clear All Logs

```cmd
pm2 flush
```

#### Monitor CPU/Memory Usage

```cmd
pm2 monit
```

#### View Detailed Application Info

```cmd
pm2 info opcua-integration
```

## Easy Management Options

### Option 1: Use the Service Manager (Recommended)

Run the interactive service manager from **any directory**:

```cmd
# Can be run from anywhere
scripts\windows-service-manager.bat
```

### Option 2: Use Command Line

Use the individual PM2 commands shown above (can be run from any directory)

## Troubleshooting

### Problem: Application Not Starting on Boot

#### Check PM2 Service Status

```cmd
sc query PM2
```

#### Check PM2 Process List

```cmd
pm2 list
```

#### Check PM2 Logs

```cmd
pm2 logs
```

#### Restart PM2 Service (if needed 2)

```cmd
sc stop PM2
sc start PM2
```

### Problem: Application Keeps Restarting

#### Check Application Logs

```cmd
pm2 logs opcua-integration --lines 50
```

#### Check Error Logs Specifically

```cmd
type logs\err.log
```

#### Check Environment Variables

```cmd
pm2 env 0
```

### Problem: High Memory Usage

#### Check Memory Usage

```cmd
pm2 monit
```

#### Restart Application (if needed)

```cmd
pm2 restart opcua-integration
```

### Problem: Cannot Connect to OPC UA Server

#### Check Network Connectivity

```cmd
telnet your-opcua-server 4840
```

#### Check Environment Configuration

```cmd
pm2 env 0
```

#### Check Application Logs (if needed)

```cmd
pm2 logs opcua-integration | findstr "OPC"
```

## Advanced Configuration

### Updating Application Configuration

1. **Modify ecosystem.config.js** if needed
2. **Reload the configuration:**

   ```cmd
   pm2 reload ecosystem.config.js
   ```

### Running Multiple Instances (if needed)

Edit `ecosystem.config.js` and change:

```javascript
instances: 1,  // Change to desired number
```

Then reload:

```cmd
pm2 reload ecosystem.config.js
```

### Custom Log Rotation

Install PM2 log rotate module:

```cmd
pm2 install pm2-logrotate
```

Configure log rotation:

```cmd
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 30
pm2 set pm2-logrotate:compress true
```

## Uninstalling the Service

If you need to remove the PM2 service:

### 1. Stop and Delete Application

```cmd
pm2 stop opcua-integration
pm2 delete opcua-integration
```

### 2. Uninstall PM2 Service

```cmd
pm2-service-uninstall
```

### 3. Verify Removal

```cmd
sc query PM2
```

**Expected Output:**

``` cmd
[SC] EnumQueryServicesStatus:OpenService FAILED 1060:
The specified service does not exist as an installed service.
```

## Quick Reference Card

### Essential Commands

| Action | Command |
|--------|---------|
| **Start App** | `pm2 start opcua-integration` |
| **Stop App** | `pm2 stop opcua-integration` |
| **Restart App** | `pm2 restart opcua-integration` |
| **View Status** | `pm2 list` |
| **View Logs** | `pm2 logs opcua-integration` |
| **Monitor** | `pm2 monit` |
| **Save Config** | `pm2 save` |

### Service Commands

| Action | Command |
|--------|---------|
| **Start Service** | `sc start PM2` |
| **Stop Service** | `sc stop PM2` |
| **Service Status** | `sc query PM2` |

### Directory Requirements

| Script | Directory Requirement |
|--------|-----------------------|
| **install-windows-service.bat** | **Must run from app root** |
| **windows-service-manager.bat** | **Can run from anywhere** |

## Support

If you encounter issues:

1. **Check the logs first**: `pm2 logs opcua-integration`
2. **Verify service status**: `sc query PM2`
3. **Check environment variables**: `pm2 env 0`
4. **Test OPC UA connectivity**: `telnet your-opcua-server 4840`
5. **Review this guide** for missed steps

For PM2-specific issues, refer to the official documentation: <https://pm2.keymetrics.io/docs/>
