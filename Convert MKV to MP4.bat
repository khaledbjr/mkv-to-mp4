@echo off
rem ============================================================
rem   MKV -> MP4 Converter  (drag & drop launcher)
rem   Drag one or more .mkv files onto this file's icon.
rem ============================================================

if "%~1"=="" (
    echo.
    echo   Drag one or more MKV files onto this icon to convert them.
    echo.
    echo   ^(Nothing was dropped, so there is nothing to do.^)
    echo.
    pause
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0convert.ps1" %*

echo.
echo   All done. You can close this window.
pause
