@echo off
title RTE - Watchdog Stack
REM Keeps the gateway and the front door alive, the same way
REM watchdog_postgres.bat keeps the cluster alive. See watchdog_stack.ps1.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0watchdog_stack.ps1"
pause
