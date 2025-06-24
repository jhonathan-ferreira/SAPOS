param()

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Solicitando privilégios de administrador..." -ForegroundColor Yellow
    Start-Process PowerShell -Verb RunAs "-File `"$PSCommandPath`"" 
    exit
}

$ErrorActionPreference = 'Stop'

$SAPOS_URL = "https://raw.githubusercontent.com/jhonathan-ferreira/SAPOS/refs/heads/main/SAPOS.cmd"

$tempFile = "$env:TEMP\SAPOS_$(Get-Random).cmd"

try {
    Invoke-WebRequest -Uri $SAPOS_URL -OutFile $tempFile
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$tempFile`""
    Stop-Process -Id $PID -Force
}
catch {
    Write-Error "Erro ao executar SAPOS: $($_.Exception.Message)"
    Write-Error "Tente baixar o arquivo"
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
    Read-Host "Pressione Enter para fechar"
}
