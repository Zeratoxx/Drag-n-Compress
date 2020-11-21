# --------- Function section ---------

function Set-Item-Property ([string]$path, [string]$name, [string]$value) {
    Write-Host "Create or change Property:`n`tItem $name`n`tPath: $path`n`tValue: $value`n"
    New-ItemProperty -Path $path -Name $name -PropertyType String -Value $value -Force | Out-Null
}


# ----------- Code section -----------

# Requires '-RunAsAdministrator'
# Or it elevates itself to admin rights
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    Write-Host "Requesting Admin Rights..."
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit 
}
Write-Host -ForegroundColor Yellow "----------- Admin Mode -----------`n"

$registryPathRoot = "HKCR:"
IF ( !(Test-Path $registryPathRoot) ) {
    Write-Host "HKEY_CLASSES_ROOT is not mounted. Mounting..."
    New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
    Write-Host "`n"
}

# Install neccessary registry
$registryPathDropHandler = "HKCR:\Microsoft.PowerShellScript.1\ShellEx\DropHandler"
$registryPathShellOpen = "HKCR:\Microsoft.PowerShellScript.1\Shell\Open\Command"
$nameDefault = "(Default)"
$valueDropHandler = "{60254CA5-953B-11CF-8C96-00AA00B8708C}"
$valueShellOpen = '"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -NoExit -File "%1" %*'


IF ( !(Test-Path $registryPathDropHandler) ) {
    Write-Host "Create path..."
    New-Item -Path $registryPathDropHandler -Force | Out-Null
    Set-Item-Property $registryPathDropHandler $nameDefault $valueDropHandler

} ELSE {
    Set-Item-Property $registryPathDropHandler $nameDefault $valueDropHandler
}


IF ( !(Test-Path $registryPathShellOpen) ) {
    New-Item -Path $registryPathShellOpen -Force | Out-Null
    Set-Item-Property $registryPathShellOpen $nameDefault $valueShellOpen

} ELSE {
    Set-Item-Property $registryPathShellOpen $nameDefault $valueShellOpen
}


Write-Host -ForegroundColor Yellow "----------- Done -----------`n"
PAUSE