@echo off
rem Double-click for the menu, or drag .twv / .tws / .wd1 / video / audio files (or folders) onto this file.
rem Dropped files use the raw defaults (original streams, no re-encode): .twv -> .m1v + .mp2, .wd1 -> .avi/.mpg, video -> .twv + .tws, .tws -> .mp2, audio -> .tws. Double-click for all options, including video -> .wd1.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0RP-TW-Media-Converter.ps1" %*
if not "%~1"=="" pause
