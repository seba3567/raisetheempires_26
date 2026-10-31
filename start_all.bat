@echo off
title Raise The Empires - Launcher
echo ============================================================
echo   Iniciando Raise The Empires (PostgreSQL 18 + Backend + Web)
echo ============================================================

REM 1. Arrancar PostgreSQL 18 si no esta corriendo
netstat -ano | findstr :5432 >nul
if %errorlevel% neq 0 (
    echo [*] Iniciando PostgreSQL 18...
    start "PostgreSQL 18" "C:\Program Files\PostgreSQL\18\bin\postgres.exe" -D "Z:\progress sql"
    timeout /t 3 >nul
) else (
    echo [OK] PostgreSQL 18 ya esta escuchando en el puerto 5432.
)

REM 2. Arrancar Backend Python (Granian en puerto 5005)
netstat -ano | findstr :5005 >nul
if %errorlevel% neq 0 (
    echo [*] Iniciando Gateway Python en puerto 5005...
    start "RTE Gateway Backend (5005)" cmd /k "cd /d %~dp0 && .\.venv\Scripts\python.exe empires-server.py --no-popup"
    timeout /t 3 >nul
) else (
    echo [OK] Gateway Python ya esta escuchando en el puerto 5005.
)

REM 3. Arrancar Frontend Web (Bun SvelteKit en puerto 8080)
netstat -ano | findstr :8080 >nul
if %errorlevel% neq 0 (
    echo [*] Compilando el frontend...
    REM El build de produccion, no `bun run dev`: el modo dev recarga los
    REM modulos en caliente y no es lo que se debe jugar. El origen que se
    REM compila dentro es el que SvelteKit valida contra el header Origin,
    REM asi que tiene que ser el mismo build que se sirve.
    pushd "%~dp0web"
    bun run --bun build
    if errorlevel 1 (
        popd
        echo [X] El build del frontend fallo. Abortando.
        exit /b 1
    )
    popd

    echo [*] Iniciando Web Frontend en puerto 8080...
    start "RTE Web Frontend (8080)" cmd /k "cd /d %~dp0web && bun .\build"
    timeout /t 3 >nul
) else (
    echo [OK] Web Frontend ya esta escuchando en el puerto 8080.
)

echo ============================================================
echo   El juego esta listo en: http://localhost:8080/juego
echo ============================================================
start http://localhost:8080/juego
