[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Repository = 'https://github.com/nicholgroup/special-measure.git',
    [string]$Ref = 'master',
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$skillRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$target = Join-Path $PSScriptRoot 'special-measure'
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('sm-skill-update-' + [guid]::NewGuid().ToString('N'))
$clone = Join-Path $tempRoot 'source'
$backup = Join-Path $tempRoot 'previous'
$targetFull = [IO.Path]::GetFullPath($target)
$scriptsRoot = [IO.Path]::GetFullPath($PSScriptRoot).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (-not $targetFull.StartsWith($scriptsRoot, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Refusing to update a target outside the scripts directory.'
}

$gitRoot = (& git -C $skillRoot rev-parse --show-toplevel 2>$null)
if ($LASTEXITCODE -ne 0 -or [IO.Path]::GetFullPath($gitRoot.Trim()) -ne [IO.Path]::GetFullPath($skillRoot)) {
    throw 'Run this updater from the sm-skill Git repository.'
}

$changes = @(& git -C $skillRoot status --porcelain --untracked-files=all -- 'scripts/special-measure')
if ($LASTEXITCODE -ne 0) { throw 'Could not inspect the Special Measure working tree.' }
if ($changes.Count -gt 0 -and -not $Force) {
    throw 'Local changes exist under scripts/special-measure. Commit or discard them first, or use -Force intentionally.'
}

New-Item -ItemType Directory -Path $tempRoot -WhatIf:$false | Out-Null
try {
    & git clone --depth 1 --single-branch --branch $Ref -- $Repository $clone
    if ($LASTEXITCODE -ne 0) { throw 'Could not clone the requested Special Measure ref.' }
    $commit = (& git -C $clone rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0 -or -not $commit) { throw 'Could not identify the downloaded commit.' }
    if (-not $PSCmdlet.ShouldProcess($targetFull, 'replace with downloaded source')) { return }

    if (Test-Path -LiteralPath $targetFull) { Move-Item -LiteralPath $targetFull -Destination $backup }
    New-Item -ItemType Directory -Path $targetFull | Out-Null
    Get-ChildItem -LiteralPath $clone -Force |
        Where-Object { $_.Name -ne '.git' } |
        Copy-Item -Destination $targetFull -Recurse -Force
    if (Test-Path -LiteralPath $backup) { Remove-Item -LiteralPath $backup -Recurse -Force }
    Write-Host ('Updated scripts/special-measure to {0}' -f $commit)
    Write-Host 'Review with: git diff -- scripts/special-measure'
}
catch {
    if (Test-Path -LiteralPath $backup) {
        if (Test-Path -LiteralPath $targetFull) { Remove-Item -LiteralPath $targetFull -Recurse -Force }
        Move-Item -LiteralPath $backup -Destination $targetFull
    }
    throw
}
finally {
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force -WhatIf:$false }
}
