@echo off
title RTE - Watchdog PostgreSQL
REM Keeps the cluster alive. The crash is PostgreSQL bug #18954 on Windows;
REM the real fix needs administrator rights. See watchdog_postgres.ps1.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0watchdog_postgres.ps1"
pause
