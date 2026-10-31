# Keeps PostgreSQL alive while you work.
#
# Why this exists
# ---------------
# The cluster on this machine dies every ten to twenty minutes. A new backend
# fails to map the shared memory segment -- "could not reserve shared memory
# region ... error code 487" -- and takes the whole cluster down with it.
# That is PostgreSQL bug #18954 on Windows: Bottom-up ASLR, which Windows
# enforces on the PostgreSQL binaries, breaks the mapping.
#
# The real fix needs administrator rights and is one command:
#
#     Set-ProcessMitigation -Name postgres.exe -Disable BottomUp
#     Set-ProcessMitigation -Name pg_ctl.exe   -Disable BottomUp
#
# Until that is applied, restarting clears it, and restarting takes a few
# seconds. So: watch, and restart.
#
# Run it with watchdog_postgres.bat.

param(
    [int]$IntervalSeconds = 10,
    [string]$DataDir = 'Z:\progress sql',
    [string]$LogFile = 'C:\Users\sebas\pg_service.log'
)

$pgCtl = 'C:\Program Files\PostgreSQL\18\bin\pg_ctl.exe'
$pgReady = 'C:\Program Files\PostgreSQL\18\bin\pg_isready.exe'

if (-not (Test-Path $pgCtl)) {
    Write-Host "No se encuentra pg_ctl en $pgCtl" -ForegroundColor Red
    exit 1
}

function Test-PgUp {
    $p = Start-Process -FilePath $pgReady -ArgumentList @('-h', '127.0.0.1', '-p', '5432') `
        -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput (Join-Path $env:TEMP 'wdpg.out') `
        -RedirectStandardError (Join-Path $env:TEMP 'wdpg.err')
    if (-not $p.WaitForExit(8000)) { try { $p.Kill() } catch { }; return $false }
    return ($p.ExitCode -eq 0)
}

function Start-Pg {
    Get-Process postgres -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 3
    # The data directory has a space in it, and Start-Process joins the
    # argument array with plain spaces, so the path has to be quoted here.
    Start-Process -FilePath $pgCtl `
        -ArgumentList @('start', '-D', ('"{0}"' -f $DataDir), '-l', ('"{0}"' -f $LogFile)) `
        -WindowStyle Hidden
    for ($i = 0; $i -lt 60; $i++) {
        Start-Sleep -Seconds 1
        if (Test-PgUp) { return $true }
    }
    return $false
}

Write-Host "Vigilando PostgreSQL en 127.0.0.1:5432 (Ctrl+C para salir)" -ForegroundColor Cyan

if (-not (Test-PgUp)) {
    Write-Host "PostgreSQL no responde; arrancando..." -ForegroundColor Yellow
    if (Start-Pg) {
        Write-Host "PostgreSQL arriba." -ForegroundColor Green
    } else {
        Write-Host "PostgreSQL no pudo arrancar; reintento en bucle." -ForegroundColor Red
    }
}

while ($true) {
    Start-Sleep -Seconds $IntervalSeconds
    if (-not (Test-PgUp)) {
        Write-Host "$(Get-Date -Format 'HH:mm:ss')  PostgreSQL se Murio; reiniciando..." -ForegroundColor Yellow
        if (Start-Pg) {
            Write-Host "$(Get-Date -Format 'HH:mm:ss')  PostgreSQL vuelve a estar arriba." -ForegroundColor Green
        } else {
            Write-Host "$(Get-Date -Format 'HH:mm:ss')  fallo al arrancar; reintento." -ForegroundColor Red
        }
    }
}
