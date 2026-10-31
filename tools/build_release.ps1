param()
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path -Parent $PSScriptRoot)

function Read-Properties([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing $Path. Follow docs/RELEASE.md before building for Google Play."
    }
    $properties = @{}
    foreach ($line in Get-Content -LiteralPath $Path) {
        if ($line.Trim() -eq '' -or $line.TrimStart().StartsWith('#')) { continue }
        $parts = $line.Split('=', 2)
        if ($parts.Length -eq 2) { $properties[$parts[0].Trim()] = $parts[1].Trim() }
    }
    return $properties
}

$releaseSettings = Read-Properties 'android/release.properties'
$applicationId = $releaseSettings['applicationId']
if ($applicationId -notmatch '^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$' -or
    $applicationId.StartsWith('com.example.')) {
    throw 'Provide your permanent applicationId in android/release.properties.'
}
if ($releaseSettings['supportEmail'] -notmatch '^[^\s@]+@[^\s@]+\.[^\s@]+$') {
    throw 'Provide a valid supportEmail in android/release.properties.'
}
$policyUri = $null
if (-not [Uri]::TryCreate($releaseSettings['privacyPolicyUrl'], [UriKind]::Absolute, [ref]$policyUri) -or
    $policyUri.Scheme -ne 'https' -or $policyUri.Host -notmatch '\.' -or
    $policyUri.Host -match 'YOUR_|example\.') {
    throw 'Provide your real public HTTPS privacyPolicyUrl in android/release.properties.'
}
$keySettings = Read-Properties 'android/key.properties'
foreach ($required in @('storeFile', 'storePassword', 'keyAlias', 'keyPassword')) {
    if ([string]::IsNullOrWhiteSpace($keySettings[$required]) -or $keySettings[$required].StartsWith('YOUR_')) {
        throw "Complete $required in your private android/key.properties."
    }
}
$keyPath = $keySettings['storeFile']
if (-not [IO.Path]::IsPathRooted($keyPath)) { $keyPath = Join-Path 'android' $keyPath }
if (-not (Test-Path -LiteralPath $keyPath -PathType Leaf)) { throw 'The private upload keystore does not exist.' }

$buildArguments = @('build', 'appbundle', '--release',
    "--dart-define=SUPPORT_EMAIL=$($releaseSettings['supportEmail'])",
    "--dart-define=PRIVACY_POLICY_URL=$($releaseSettings['privacyPolicyUrl'])")
& flutter @buildArguments
if ($LASTEXITCODE -ne 0) { throw "Release build failed with exit code $LASTEXITCODE" }
