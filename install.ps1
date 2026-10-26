<#
.SYNOPSIS
    Install 1C-developer Cursor kit (skills + mcp.json).

.PARAMETER ProjectDir
    Path to 1C XML dump project. Default: current directory.

.PARAMETER Global
    Install into %USERPROFILE%\.cursor

.PARAMETER PlatformPath
    Path to 1C platform folder (e.g. C:\Program Files\1cv8\8.3.27.1606)

.PARAMETER SkipBsp
    Do not install BSP skill

.PARAMETER SkipMcp
    Do not write mcp.json
#>

[CmdletBinding()]
param(
    [string]$ProjectDir = (Get-Location).Path,
    [switch]$Global,
    [string]$PlatformPath = "",
    [switch]$SkipBsp,
    [switch]$SkipMcp
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$KitRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$CursorSkillsInstall = Join-Path $KitRoot "cursor-1c-skills\install.ps1"
$BspRoot = Join-Path $KitRoot "1c-ssl-skills"

if (-not (Test-Path -LiteralPath $CursorSkillsInstall)) {
    throw "cursor-1c-skills\install.ps1 not found in kit: $KitRoot"
}

Write-Host "=== 1C-developer install ===" -ForegroundColor Cyan
Write-Host "Kit: $KitRoot"

if ($Global) {
    Write-Host "`nSkills: global (%USERPROFILE%\.cursor)" -ForegroundColor Yellow
    & $CursorSkillsInstall -Global
} else {
    if (-not (Test-Path -LiteralPath $ProjectDir)) {
        throw "Project directory not found: $ProjectDir"
    }
    Write-Host "`nSkills: project $ProjectDir" -ForegroundColor Yellow
    & $CursorSkillsInstall -ProjectDir $ProjectDir
}

if (-not $SkipBsp) {
    $bspSkillSrc = $null
    foreach ($cand in @(
        (Join-Path $BspRoot "skills\bsp"),
        (Join-Path $BspRoot "bsp"),
        (Join-Path $BspRoot "skill")
    )) {
        if (Test-Path -LiteralPath (Join-Path $cand "SKILL.md")) {
            $bspSkillSrc = $cand
            break
        }
    }
    if (-not $bspSkillSrc -and (Test-Path -LiteralPath (Join-Path $BspRoot "SKILL.md"))) {
        $bspSkillSrc = $BspRoot
    }

    if ($bspSkillSrc) {
        if ($Global) {
            $skillsTarget = Join-Path $env:USERPROFILE ".cursor\skills\bsp"
        } else {
            $skillsTarget = Join-Path $ProjectDir ".cursor\skills\bsp"
        }
        $parent = Split-Path $skillsTarget -Parent
        if (-not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        if (Test-Path $skillsTarget) {
            Remove-Item -LiteralPath $skillsTarget -Recurse -Force
        }
        Copy-Item -LiteralPath $bspSkillSrc -Destination $skillsTarget -Recurse -Force
        Write-Host "BSP skill -> $skillsTarget" -ForegroundColor Green
    } else {
        Write-Host "BSP skill: SKILL.md not found — skipped" -ForegroundColor Yellow
    }
}

if (-not $SkipMcp) {
    $example = Join-Path $KitRoot "mcp.json.example"
    if (-not (Test-Path -LiteralPath $example)) {
        throw "mcp.json.example missing"
    }

    $mcpTargetDir = if ($Global) {
        Join-Path $env:USERPROFILE ".cursor"
    } else {
        Join-Path $ProjectDir ".cursor"
    }
    if (-not (Test-Path $mcpTargetDir)) {
        New-Item -ItemType Directory -Path $mcpTargetDir -Force | Out-Null
    }
    $mcpPath = Join-Path $mcpTargetDir "mcp.json"

    $json = Get-Content -LiteralPath $example -Raw -Encoding UTF8
    $kitEscaped = $KitRoot.Replace('\', '\\')
    $json = $json.Replace("__KIT_ROOT__", $kitEscaped)

    if ([string]::IsNullOrWhiteSpace($PlatformPath)) {
        $json = $json.Replace("__PLATFORM_PATH__", "C:\\Program Files\\1cv8\\CHANGE_ME")
        Write-Host "Platform path placeholder CHANGE_ME — edit $mcpPath" -ForegroundColor Yellow
    } else {
        $platEscaped = $PlatformPath.Replace('\', '\\')
        $json = $json.Replace("__PLATFORM_PATH__", $platEscaped)
    }

    if (Test-Path -LiteralPath $mcpPath) {
        $backup = "$mcpPath.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -LiteralPath $mcpPath -Destination $backup -Force
        Write-Host "Existing mcp.json backed up: $backup" -ForegroundColor Yellow
    }

    Set-Content -LiteralPath $mcpPath -Value $json -Encoding UTF8
    Write-Host "MCP -> $mcpPath" -ForegroundColor Green
}

Write-Host "`nDone." -ForegroundColor Cyan
Write-Host "1) Open your XML dump folder in Cursor (not this kit folder)."
Write-Host "2) Set 1C platform path in mcp.json if CHANGE_ME remains."
Write-Host "3) Fully restart Cursor."
Write-Host "4) Start with skills + BSL Context + v8std. LSP / Metacode / YaXUnit are optional (Docker / test IB)."
Write-Host "See README.md and VERSIONS.md"