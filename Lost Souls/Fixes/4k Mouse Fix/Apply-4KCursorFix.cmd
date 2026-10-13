@echo off
rem Earth 2150: The Moon Project - 4K cursor fix launcher.
rem Keep this file next to Apply-4KCursorFix.ps1 and TheMoonProject.exe, then double-click it.
rem To undo, run from a command prompt:  Apply-4KCursorFix.cmd -Restore
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Apply-4KCursorFix.ps1" %*
set "RC=%ERRORLEVEL%"
echo.
pause
exit /b %RC%
