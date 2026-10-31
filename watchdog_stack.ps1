# Keeps the game stack alive while you work.
#
# Why this exists
# ---------------
# PostgreSQL on this machine dies every ten to twenty minutes -- see
# watchdog_postgres.ps1, which is the older half of this problem. The other two
# services die for a different reason: anything that supervises them from the
# outside gives up after a while, and whoever was playing is left staring at a
# page that will not load, with no clue which of the three pieces is gone.
#
# So the stack is watched the same way the cluster is: probe each service, and
# restart the one that is not answering.
#
# A restart is survivable for both of them. The gateway's sessions live in
# PostgreSQL, not in its memory, and the front door's sessions are signed
# cookies, so a player can log back in and carry on.
#
# Run it with watchdog_stack.bat. It is a separate tool from start_all.bat:
# the launcher starts the stack, the watchdog keeps it up.
#
#   .\watchdog_stack.bat

param(
    # How often to check. Ten seconds is fast enough that nobody notices a
    # restart and slow enough not to matter.
    [int]$IntervalSeconds = 10,

    # Consecutive failures before a restart. One failed probe is usually a
    # request that was cut short, not a service that died; three in a row is
    # a service that is down.
    [int]$FailuresBeforeRestart = 3,

    [string]$GatewayUrl = 'http://127.0.0.1:5005/snapi.json',
    [string]$WebUrl = 'http://127.0.0.1:8080/'
)

$Root = $PSScriptRoot
$Python = Join-Path $Root '.venv\Scripts\python.exe'
$WebDir = Join-Path $Root 'web'

function Test-Url {
    param([string]$Url)

    # A generous timeout: a service that is still booting answers nothing for
    # a while, and calling that "dead" would start it a second time.
    try {
        $response = Invoke-WebRequest -Uri $Url -TimeoutSec 10 -UseBasicParsing
        return ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500)
    } catch {
        return $false
    }
}

function Start-Gateway {
    Write-Host "$(Get-Date -Format 'HH:mm:ss')  arrancando el gateway..." -ForegroundColor Yellow
    Start-Process -FilePath $Python `
        -ArgumentList @('empires-server.py', '--no-popup') `
        -WorkingDirectory $Root `
        -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $Root 'log-gateway.out.log') `
        -RedirectStandardError (Join-Path $Root 'log-gateway.err.log')
}

function Start-Web {
    Write-Host "$(Get-Date -Format 'HH:mm:ss')  arrancando el front door..." -ForegroundColor Yellow

    # The production build, not `bun run dev`: the origin compiled into the
    # bundle is the one SvelteKit validates every form POST against, so the
    # thing that serves has to be the thing that was built.
    if (-not (Test-Path (Join-Path $WebDir 'build\index.js'))) {
        Write-Host "compilando el front door..." -ForegroundColor Yellow
        Push-Location $WebDir
        try {
            & bun run --bun build | Out-Null
        } finally {
            Pop-Location
        }
    }

    Start-Process -FilePath 'bun' `
        -ArgumentList @('.\build') `
        -WorkingDirectory $WebDir `
        -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $Root 'log-web.out.log') `
        -RedirectStandardError (Join-Path $Root 'log-web.err.log')
}

function Wait-Up {
    param([string]$Url, [int]$Seconds = 60)

    for ($i = 0; $i -lt $Seconds; $i++) {
        Start-Sleep -Seconds 1
        if (Test-Url $Url) { return $true }
    }
    return $false
}

$gatewayFailures = 0
$webFailures = 0

Write-Host "Vigilando el gateway ($GatewayUrl) y el front door ($WebUrl). Ctrl+C para salir." -ForegroundColor Cyan

while ($true) {
    Start-Sleep -Seconds $IntervalSeconds

    # The gateway
    if (Test-Url $GatewayUrl) {
        if ($gatewayFailures -gt 0) {
            Write-Host "$(Get-Date -Format 'HH:mm:ss')  el gateway vuelve a responder." -ForegroundColor Green
        }
        $gatewayFailures = 0
    } else {
        $gatewayFailures++
        if ($gatewayFailures -ge $FailuresBeforeRestart) {
            Write-Host "$(Get-Date -Format 'HH:mm:ss')  el gateway no responde; reiniciando..." -ForegroundColor Yellow
            Start-Gateway
            if (Wait-Up $GatewayUrl) {
                Write-Host "$(Get-Date -Format 'HH:mm:ss')  el gateway esta arriba." -ForegroundColor Green
            } else {
                Write-Host "$(Get-Date -Format 'HH:mm:ss')  el gateway no arranco; reintento en bucle." -ForegroundColor Red
            }
            $gatewayFailures = 0
        }
    }

    # The front door
    if (Test-Url $WebUrl) {
        if ($webFailures -gt 0) {
            Write-Host "$(Get-Date -Format 'HH:mm:ss')  el front door vuelve a responder." -ForegroundColor Green
        }
        $webFailures = 0
    } else {
        $webFailures++
        if ($webFailures -ge $FailuresBeforeRestart) {
            Write-Host "$(Get-Date -Format 'HH:mm:ss')  el front door no responde; reiniciando..." -ForegroundColor Yellow
            Start-Web
            if (Wait-Up $WebUrl) {
                Write-Host "$(Get-Date -Format 'HH:mm:ss')  el front door esta arriba." -ForegroundColor Green
            } else {
                Write-Host "$(Get-Date -Format 'HH:mm:ss')  el front door no arranco; reintento en bucle." -ForegroundColor Red
            }
            $webFailures = 0
        }
    }
}
