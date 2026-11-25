# CmdCrate bootstrap.
#
#   irm https://raw.githubusercontent.com/makaDv/CmdCrate/main/install.ps1 | iex
#
# Pin a release instead of main:
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/makaDv/CmdCrate/main/install.ps1))) -Ref v1.0.0
#
# What it does:
#   1. downloads CmdCrate.ps1, apps.json and checksums.txt from GitHub into a new temp folder
#   2. checks the SHA256 of each file against checksums.txt and stops on any mismatch
#   3. starts CmdCrate.ps1 (GUI). Nothing is installed until you press "Install".
# No data is collected or sent anywhere.
param(
    [ValidatePattern('^[A-Za-z0-9._\-/]+$')]
    [string]$Ref = 'main'
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$base = "https://raw.githubusercontent.com/makaDv/CmdCrate/$Ref"
$dir = Join-Path $env:TEMP ('CmdCrate-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $dir -Force | Out-Null

Write-Host "CmdCrate: downloading from $base" -ForegroundColor Cyan
$files = @('CmdCrate.ps1', 'apps.json', 'checksums.txt')
foreach ($f in $files) {
    Invoke-WebRequest -Uri "$base/$f" -OutFile (Join-Path $dir $f) -UseBasicParsing
}

# checksums.txt format: "<sha256>  <file>" per line
$expected = @{}
foreach ($line in Get-Content -LiteralPath (Join-Path $dir 'checksums.txt')) {
    if ($line -match '^([0-9a-fA-F]{64})\s+(\S+)$') { $expected[$Matches[2]] = $Matches[1].ToLowerInvariant() }
}
foreach ($f in @('CmdCrate.ps1', 'apps.json')) {
    $actual = (Get-FileHash -LiteralPath (Join-Path $dir $f) -Algorithm SHA256).Hash.ToLowerInvariant()
    if (-not $expected.ContainsKey($f) -or $expected[$f] -ne $actual) {
        Remove-Item -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue
        throw "CmdCrate: integrity check failed for $f. Nothing was run."
    }
}
Write-Host 'CmdCrate: integrity check OK, starting...' -ForegroundColor Green

$hostExe = (Get-Process -Id $PID).Path
if ($hostExe -notmatch '(powershell|pwsh)\.exe$') { $hostExe = 'powershell.exe' }
Start-Process -FilePath $hostExe -ArgumentList @(
    '-NoProfile', '-ExecutionPolicy', 'Bypass', '-STA',
    '-File', ('"{0}"' -f (Join-Path $dir 'CmdCrate.ps1'))
)
