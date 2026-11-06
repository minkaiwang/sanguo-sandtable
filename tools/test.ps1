param([Parameter(Mandatory = $true)][string]$GodotPath, [switch]$Capture, [string]$TestName = '')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'test_state_guard.ps1')
$stateRoot = Join-Path $env:APPDATA 'Godot/app_userdata/天下沙盘'
$GodotPath = (Get-Command -Name $GodotPath -CommandType Application -ErrorAction Stop).Source
$lock = $null
$baseline = $null
$failures = @()
try {
    $lock = Enter-AutomatedTestRunLock -StateRoot $stateRoot
    $baseline = Get-FormalStateSnapshot -StateRoot $stateRoot -IncludeBytes
    Initialize-GodotProjectImport -GodotPath $GodotPath -ProjectRoot $projectRoot
    $cases = if ($Capture) { @('test_basic_release.gd') } else {
        @(Get-ChildItem -LiteralPath (Join-Path $projectRoot 'tests') -Filter 'test_*.gd' -File | Sort-Object Name | ForEach-Object Name)
    }
    if ($TestName) { $cases = @($cases | Where-Object { $_ -eq $TestName }) }
    if ($cases.Count -eq 0) { throw '没有匹配的测试文件' }
    foreach ($case in $cases) {
        Clear-AutomatedTestState -StateRoot $stateRoot
        $launch = @('--path', $projectRoot, '--quit-after', '1800', '--script', "res://tests/$case")
        if (-not $Capture) { $launch = @('--headless') + $launch }
        $launch += @('--', '--automated-test-mode')
        if ($Capture) { $launch += '--release-artifacts=' + (Join-Path $projectRoot 'artifacts/release') }
        $output = @(& $GodotPath @launch 2>&1)
        $code = $LASTEXITCODE
        $output | Write-Output
        if ($code -ne 0 -or -not ($output -match '_TEST_OK') -or ($output -match '(SCRIPT ERROR|ERROR:)')) { $failures += $case }
        $changes = @(Compare-FormalStateSnapshot -Before $baseline -After (Get-FormalStateSnapshot -StateRoot $stateRoot))
        if ($changes.Count -gt 0) { Restore-FormalStateSnapshot -StateRoot $stateRoot -Snapshot $baseline; throw '正式状态出现变化，已恢复' }
    }
}
finally {
    try {
        if ($null -ne $baseline) {
            $changes = @(Compare-FormalStateSnapshot -Before $baseline -After (Get-FormalStateSnapshot -StateRoot $stateRoot))
            if ($changes.Count -gt 0) { Restore-FormalStateSnapshot -StateRoot $stateRoot -Snapshot $baseline; $failures += 'formal_state' }
            Clear-AutomatedTestState -StateRoot $stateRoot
        }
    }
    finally { Exit-AutomatedTestRunLock -LockStream $lock }
}
if ($failures.Count -gt 0) { throw "发布检查失败：$($failures -join ', ')" }
Write-Output "BASIC_SUITE_OK cases=$($cases.Count) formal_state=unchanged"
