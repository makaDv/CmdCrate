# Regenerates checksums.txt. Run it before every commit that changes CmdCrate.ps1 or apps.json:
#   .\tools\Update-Checksums.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$lines = foreach ($f in 'CmdCrate.ps1', 'apps.json') {
    $hash = (Get-FileHash -LiteralPath (Join-Path $root $f) -Algorithm SHA256).Hash.ToLowerInvariant()
    "$hash  $f"
}
# LF line endings, no BOM: identical bytes on every machine
[IO.File]::WriteAllText((Join-Path $root 'checksums.txt'), (($lines -join "`n") + "`n"))
$lines
