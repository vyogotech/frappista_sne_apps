@echo off
setlocal ENABLEDELAYEDEXPANSION

:: ------------------------------
:: Config
:: ------------------------------
set IMAGE=vyogo/erpnext:sne-version-15
set BENCH_DIR=/home/frappe/frappe-bench
set APPS_DIR=%BENCH_DIR%/apps
set CONTAINER_NAME=frappe-app-creator
set COMPOSE_FILE=compose.yml

:: ------------------------------
:: Help
:: ------------------------------
if "%~1"=="" (
    echo Usage:
    echo   %~nx0 app_name [--compose-update-only]
    echo.
    echo Arguments:
    echo   app_name                Name of the Frappe custom app (required)
    echo   --compose-update-only   Skip app creation, only update compose.yml
    exit /b 1
)

set APP_NAME=%~1
set COMPOSE_UPDATE_ONLY=false

if "%~2"=="--compose-update-only" (
    set COMPOSE_UPDATE_ONLY=true
)

:: ------------------------------
:: Function: Update compose.yml
:: ------------------------------
:UPDATE_COMPOSE
if not exist "%COMPOSE_FILE%" (
    echo ❌ %COMPOSE_FILE% not found in current directory.
    exit /b 1
)

set "VOLUME_LINE=      - ./apps/%APP_NAME%:/home/frappe/frappe-bench/apps/%APP_NAME%"
findstr /C:"%VOLUME_LINE%" "%COMPOSE_FILE%" >nul
if %errorlevel%==0 (
    echo ℹ️ Volume already exists in %COMPOSE_FILE%
    exit /b 0
)

echo 🔧 Updating %COMPOSE_FILE% to mount app...

set "TMP_FILE=%COMPOSE_FILE%.tmp"
set "IN_SERVICE=false"

(
for /f "usebackq delims=" %%L in ("%COMPOSE_FILE%") do (
    set "line=%%L"
    echo !line! | findstr /R "^  frappe-sne:" >nul
    if !errorlevel! == 0 (
        set IN_SERVICE=true
    )

    echo !line!

    if "!IN_SERVICE!"=="true" (
        echo !line! | findstr /R "^  \s*volumes:" >nul
        if !errorlevel! == 0 (
            echo %VOLUME_LINE%
            set IN_SERVICE=false
        )
    )
)
) > "%TMP_FILE%"

move /Y "%TMP_FILE%" "%COMPOSE_FILE%" >nul
echo ✅ Updated %COMPOSE_FILE%
exit /b 0

:: ------------------------------
:: Mount-only mode
:: ------------------------------
:CREATE_APP_OR_MOUNT
if "%COMPOSE_UPDATE_ONLY%"=="true" (
    echo 📦 Compose-update-only mode: Skipping app creation...
    call :UPDATE_COMPOSE
    exit /b
)

:: ------------------------------
:: Ensure apps dir exists
:: ------------------------------
set "LOCAL_APP_PATH=%cd%\apps\%APP_NAME%"
if not exist "%LOCAL_APP_PATH%" (
    mkdir "%LOCAL_APP_PATH%"
)

:: ------------------------------
:: Run Docker
:: ------------------------------
docker run --rm -it ^
    --name %CONTAINER_NAME% ^
    -v "%LOCAL_APP_PATH%:/home/frappe/frappe-bench/apps/%APP_NAME%" ^
    %IMAGE% ^
    bash -c "set -e; su - frappe -c 'cd %BENCH_DIR% && bench new-app %APP_NAME%'"

echo.
echo ✅ App '%APP_NAME%' created.
echo 📁 Local path: %LOCAL_APP_PATH%

:: ------------------------------
:: Ask for compose update
:: ------------------------------
set /p UPDATE_COMPOSE="👉 Do you want to update compose.yml to mount this app? (y/N): "
if /I "%UPDATE_COMPOSE%"=="Y" (
    call :UPDATE_COMPOSE
) else (
    echo ❎ Skipping compose.yml update.
)
