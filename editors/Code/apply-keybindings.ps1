# Applies these VS Code shortcuts on Windows, for the default profile and every other profile.
# Uses keybindings.windows.json (Ctrl keys). Targets that are links are left alone.
# The first time a different file is replaced, the old one is kept as keybindings.backup.json.

$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot 'keybindings.windows.json'
$user = Join-Path $env:APPDATA 'Code\User'

if (-not (Test-Path $source)) { Write-Host "Missing $source"; exit 1 }
if (-not (Test-Path $user)) { Write-Host "VS Code user folder not found: $user"; exit 0 }

$targets = @(Join-Path $user 'keybindings.json')
$profiles = Join-Path $user 'profiles'
if (Test-Path $profiles) {
    $targets += Get-ChildItem $profiles -Directory | ForEach-Object { Join-Path $_.FullName 'keybindings.json' }
}

$wanted = Get-FileHash $source
foreach ($target in $targets) {
    if ((Test-Path $target) -and (Get-Item $target).LinkType) { Write-Host "Skipped (link, managed elsewhere): $target"; continue }
    if ((Test-Path $target) -and ((Get-FileHash $target).Hash -eq $wanted.Hash)) { continue }
    $backup = Join-Path (Split-Path $target) 'keybindings.backup.json'
    if ((Test-Path $target) -and -not (Test-Path $backup)) { Copy-Item $target $backup }
    Copy-Item $source $target -Force
    Write-Host "Updated $target"
}
