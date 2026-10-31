param([switch]$SkipAndroidBuild)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path -Parent $PSScriptRoot)

function Invoke-Checked {
    param([string]$Executable, [string[]]$Arguments)
    & $Executable @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Executable failed with exit code $LASTEXITCODE" }
}

Invoke-Checked flutter @('pub', 'get')
Invoke-Checked dart @('format', '--output=none', '--set-exit-if-changed', 'lib', 'test')
Invoke-Checked flutter @('analyze', '--no-pub')
Invoke-Checked flutter @('test', '--no-pub')
if (-not $SkipAndroidBuild) {
    Invoke-Checked flutter @('build', 'apk', '--debug', '--no-pub')
    Invoke-Checked python @('tools/check_android_compatibility.py', 'build/app/outputs/flutter-apk/app-debug.apk')
}
