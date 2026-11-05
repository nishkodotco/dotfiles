<#
.SYNOPSIS
Install RHEL on WSL 2 and set it up with these dotfiles in one go.

.DESCRIPTION
1. Installs WSL if it is missing (asks you to restart Windows once, then run this again).
2. Updates WSL.
3. Installs RHEL from the image you downloaded from
   https://developers.redhat.com/products/rhel/download (RHEL for WSL).
   On first start RHEL asks you to create a Linux username and password.
4. Runs scripts/rhel-bootstrap.sh inside RHEL: registers it with Red Hat, installs
   git, which, gh and Nushell, and links the dotfiles configuration.

Registration asks for your Red Hat username and password unless you pass an
organization ID and activation key (create one at
https://console.redhat.com/insights/connector/activation-keys). The key is passed
to WSL for this run only and is never written to disk.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File setup-rhel-wsl.ps1 -ImagePath "$HOME\Downloads\rhel-10.wsl"

.EXAMPLE
powershell -ExecutionPolicy Bypass -File setup-rhel-wsl.ps1 -ImagePath .\rhel-10.wsl -Organization 1234567 -ActivationKey my-wsl-key
#>
param(
    [string]$ImagePath,
    [string]$Distro,
    [string]$Organization,
    [string]$ActivationKey,
    [string]$BootstrapUrl = 'https://raw.githubusercontent.com/nishkodotco/dotfiles/main/scripts/rhel-bootstrap.sh'
)
$ErrorActionPreference = 'Stop'

function Step($message) { Write-Host "`n==> $message" -ForegroundColor Cyan }

function Get-Distros {
    # wsl.exe prints UTF-16; strip the NUL characters PowerShell leaves behind.
    $output = & wsl.exe --list --quiet 2>$null
    if ($LASTEXITCODE -ne 0) { return @() }
    return @($output | ForEach-Object { ($_ -replace "`0", '').Trim() } | Where-Object { $_ })
}

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    return (New-Object Security.Principal.WindowsPrincipal $identity).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# 1. WSL itself
& wsl.exe --status *> $null
if ($LASTEXITCODE -ne 0) {
    if (-not (Test-Admin)) { throw 'WSL is not installed. Run this script once from an administrator PowerShell.' }
    Step 'Installing WSL'
    & wsl.exe --install --no-distribution
    Write-Host 'Restart Windows, then run this script again.' -ForegroundColor Yellow
    exit 0
}

Step 'Updating WSL'
& wsl.exe --update
& wsl.exe --set-default-version 2 | Out-Null

# 2. RHEL distribution
$existing = Get-Distros
if (-not $Distro) { $Distro = $existing | Where-Object { $_ -like 'RHEL*' } | Select-Object -First 1 }
if ($Distro -and ($existing -contains $Distro)) {
    Step "Using the existing $Distro distribution"
} else {
    if (-not $ImagePath) { throw 'Pass -ImagePath with the RHEL for WSL image from https://developers.redhat.com/products/rhel/download' }
    $image = (Resolve-Path $ImagePath).Path
    Step "Installing RHEL from $image"
    Write-Host 'When RHEL starts, create your Linux user, then type exit to continue here.' -ForegroundColor Yellow
    & wsl.exe --install --from-file $image
    if ($LASTEXITCODE -ne 0) { throw 'wsl --install --from-file failed. Run wsl --update and try again.' }
    $Distro = Get-Distros | Where-Object { $existing -notcontains $_ } | Select-Object -First 1
    if (-not $Distro) { throw 'Could not find the new RHEL distribution in wsl --list.' }
}

# 3. Bootstrap inside RHEL
Step "Setting up $Distro"
$names = @()
if ($Organization -and $ActivationKey) {
    $env:RHSM_ORG = $Organization
    $env:RHSM_ACTIVATION_KEY = $ActivationKey
    $names = 'RHSM_ORG', 'RHSM_ACTIVATION_KEY'
}
$previousWslEnv = $env:WSLENV
if ($names) { $env:WSLENV = (@($previousWslEnv) + $names | Where-Object { $_ }) -join ':' }
try {
    & wsl.exe -d $Distro -- bash -c "curl -fsSL $BootstrapUrl -o /tmp/rhel-bootstrap.sh && sh /tmp/rhel-bootstrap.sh"
    if ($LASTEXITCODE -ne 0) { throw "The setup inside $Distro failed (exit code $LASTEXITCODE)." }
} finally {
    $env:WSLENV = $previousWslEnv
    Remove-Item Env:RHSM_ORG, Env:RHSM_ACTIVATION_KEY -ErrorAction SilentlyContinue
}

Step "Done. Start it with: wsl -d $Distro"
