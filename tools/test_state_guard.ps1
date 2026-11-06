$script:FormalStateNames = @(
    "sandbox_save.json",
    "backpack_preferences.json",
    "backpack_preferences_v2.json",
    "sandbox_snapshots.json",
    "personal_scenario_templates.json",
    "title_settings.json",
    "title_settings.json.previous"
)
$script:FormalStateDirectoryNames = @(
    "backups"
)
$script:FormalStateSidecarPatterns = @(
    "sandbox_save.json.last-good*",
    "sandbox_save.json.replace-*.tmp",
    "sandbox_save.json.write-*.tmp",
    "sandbox_save.json.txn-*",
    "backpack_preferences_v2.json.replace-*.tmp",
    "backpack_preferences_v2.json.write-*.tmp",
    "sandbox_snapshots.json.replace-*.tmp",
    "sandbox_snapshots.json.write-*.tmp",
    "personal_scenario_templates.json.replace-*.tmp",
    "personal_scenario_templates.json.write-*.tmp",
    "title_settings.json.tmp",
    "title_settings.json.replace.tmp"
)
$script:AutomatedStateNames = @(
    "sandbox_save_automated_test.json",
    "sandbox_save_automated_test.json.last-good",
    "sandbox_save_automated_test.json.tmp",
    "backpack_preferences_automated_test.json",
    "backpack_preferences_v2_automated_test.json",
    "sandbox_snapshots_automated_test.json",
    "personal_scenario_templates_automated_test.json",
    "sandbox_save_m4_b7_catalog_v4_automated_test.json",
    "sandbox_save_m4_b7_catalog_v4_automated_test.json.last-good",
    "backpack_preferences_m4_b7_catalog_v4_automated_test.json",
    "backpack_preferences_v2_m4_b7_catalog_v4_automated_test.json",
    "sandbox_snapshots_m4_b7_catalog_v4_automated_test.json",
    "personal_scenario_templates_m4_b7_catalog_v4_automated_test.json",
    "sandbox_save_m4_b7_catalog_v4_rollback_probe.json",
    "title_settings_automated_test.json",
    "title_settings_automated_test.json.previous",
    "title_settings_automated_test.json.tmp",
    "title_settings_automated_test.json.replace.tmp",
    "primary_recovery_raw_backup_blocker_automated_test"
)
$script:AutomatedStateDirectoryNames = @(
    "backups_automated_test",
    "backups_m4_b7_catalog_v4_automated_test"
)
$script:AutomatedStateSidecarPatterns = @(
    "sandbox_save_automated_test.json.last-good*",
    "sandbox_save_automated_test.json.replace-*.tmp",
    "sandbox_save_automated_test.json.write-*.tmp",
    "sandbox_save_automated_test.json.txn-*",
    "backpack_preferences_v2_automated_test.json.replace-*.tmp",
    "backpack_preferences_v2_automated_test.json.write-*.tmp",
    "sandbox_snapshots_automated_test.json.replace-*.tmp",
    "sandbox_snapshots_automated_test.json.write-*.tmp",
    "personal_scenario_templates_automated_test.json.replace-*.tmp",
    "personal_scenario_templates_automated_test.json.write-*.tmp",
    "sandbox_save_m4_b7_catalog_v4_automated_test.json.last-good*",
    "sandbox_save_m4_b7_catalog_v4_automated_test.json.replace-*.tmp",
    "sandbox_save_m4_b7_catalog_v4_automated_test.json.write-*.tmp",
    "sandbox_save_m4_b7_catalog_v4_automated_test.json.txn-*",
    "backpack_preferences_v2_m4_b7_catalog_v4_automated_test.json.replace-*.tmp",
    "backpack_preferences_v2_m4_b7_catalog_v4_automated_test.json.write-*.tmp",
    "sandbox_snapshots_m4_b7_catalog_v4_automated_test.json.replace-*.tmp",
    "sandbox_snapshots_m4_b7_catalog_v4_automated_test.json.write-*.tmp",
    "personal_scenario_templates_m4_b7_catalog_v4_automated_test.json.replace-*.tmp",
    "personal_scenario_templates_m4_b7_catalog_v4_automated_test.json.write-*.tmp",
    "sandbox_save_m4_b7_catalog_v4_rollback_probe.json.replace-*.tmp",
    "sandbox_save_m4_b7_catalog_v4_rollback_probe.json.write-*.tmp"
)

function Test-FullRegressionReceiptUtcTimestamp {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    if ($Value -notmatch '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{7}\+00:00$') {
        return $false
    }
    $parsed = [DateTimeOffset]::MinValue
    $parsedExactly = [DateTimeOffset]::TryParseExact(
        $Value,
        "yyyy-MM-dd'T'HH:mm:ss.fffffffzzz",
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::None,
        [ref]$parsed
    )
    return $parsedExactly -and $parsed.Offset -eq [TimeSpan]::Zero
}

function Assert-FullRegressionSuiteSentinel {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$TestNames
    )

    $actualCount = @(
        $TestNames |
            Where-Object {
                [string]::Equals(
                    $_,
                    "test_current_project_status.gd",
                    [System.StringComparison]::Ordinal
                )
            }
    )
    if ($actualCount.Count -ne 1) {
        throw "完整回归必须且只能包含一个 test_current_project_status.gd：expected=1 actual=$($actualCount.Count)"
    }
}

function Clear-AutomatedTestState {
    param(
        [Parameter(Mandatory = $true)]
        [string]$StateRoot
    )

    $resolvedStateRoot = [System.IO.Path]::GetFullPath($StateRoot)
    Assert-NoFormalReparsePoint -Path $resolvedStateRoot
    if (Test-Path -LiteralPath $resolvedStateRoot -PathType Leaf) {
        throw "自动测试状态根不是文件夹：$resolvedStateRoot"
    }
    if (-not (Test-Path -LiteralPath $resolvedStateRoot -PathType Container)) {
        return
    }
    $rootPrefix = $resolvedStateRoot.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    ) + [System.IO.Path]::DirectorySeparatorChar
    $stateFilesToRemove = [System.Collections.Generic.List[string]]::new()
    $sidecarFilesToRemove = [System.Collections.Generic.List[string]]::new()
    $directoriesToRemove = [System.Collections.Generic.List[string]]::new()

    foreach ($stateName in $script:AutomatedStateNames) {
        $statePath = [System.IO.Path]::GetFullPath((Join-Path $resolvedStateRoot $stateName))
        if (-not $statePath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "自动测试状态文件越界：$statePath"
        }
        Assert-NoFormalReparsePoint -Path $statePath -Recurse
        if (Test-Path -LiteralPath $statePath) {
            if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
                throw "自动测试状态文件路径不是普通文件：$statePath"
            }
            $stateFilesToRemove.Add($statePath)
        }
    }

    $sidecarItems = foreach ($pattern in $script:AutomatedStateSidecarPatterns) {
        Get-ChildItem -LiteralPath $resolvedStateRoot -Force -Filter $pattern -ErrorAction Stop
    }
    foreach ($stateItem in @($sidecarItems | Sort-Object FullName -Unique)) {
        $statePath = [System.IO.Path]::GetFullPath($stateItem.FullName)
        if (-not $statePath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "自动测试旁路文件越界：$statePath"
        }
        Assert-NoFormalReparsePoint -Path $statePath -Recurse
        if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
            throw "自动测试旁路路径不是普通文件：$statePath"
        }
        $sidecarFilesToRemove.Add($statePath)
    }

    foreach ($directoryName in $script:AutomatedStateDirectoryNames) {
        $directoryPath = [System.IO.Path]::GetFullPath((Join-Path $resolvedStateRoot $directoryName))
        if (-not $directoryPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "自动测试目录越界：$directoryPath"
        }
        Assert-NoFormalReparsePoint -Path $directoryPath -Recurse
        if (Test-Path -LiteralPath $directoryPath) {
            if (-not (Test-Path -LiteralPath $directoryPath -PathType Container)) {
                throw "自动测试目录路径不是文件夹：$directoryPath"
            }
            $directoriesToRemove.Add($directoryPath)
        }
    }

    $allFilesToRemove = @($stateFilesToRemove) + @($sidecarFilesToRemove) | Sort-Object -Unique
    foreach ($statePath in $allFilesToRemove) {
        Assert-NoFormalReparsePoint -Path $resolvedStateRoot
        Assert-NoFormalReparsePoint -Path $statePath
        if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
            throw "自动测试状态文件在预检后发生变化：$statePath"
        }
        Remove-Item -LiteralPath $statePath -Force -ErrorAction Stop
    }
    foreach ($directoryPath in $directoriesToRemove) {
        Assert-NoFormalReparsePoint -Path $resolvedStateRoot
        Remove-AutomatedTestDirectoryNoFollow -Path $directoryPath
    }

    Assert-NoFormalReparsePoint -Path $resolvedStateRoot
    foreach ($stateName in $script:AutomatedStateNames) {
        $statePath = [System.IO.Path]::GetFullPath((Join-Path $resolvedStateRoot $stateName))
        Assert-NoFormalReparsePoint -Path $statePath -Recurse
        if (Test-Path -LiteralPath $statePath) {
            throw "自动测试固定状态清理后仍存在：$statePath"
        }
    }
    foreach ($pattern in $script:AutomatedStateSidecarPatterns) {
        $residue = @(
            Get-ChildItem -LiteralPath $resolvedStateRoot -Force -Filter $pattern -ErrorAction Stop
        )
        if ($residue.Count -gt 0) {
            throw "自动测试事务旁路清理后仍存在：$($residue[0].FullName)"
        }
    }
    foreach ($directoryName in $script:AutomatedStateDirectoryNames) {
        $directoryPath = [System.IO.Path]::GetFullPath((Join-Path $resolvedStateRoot $directoryName))
        Assert-NoFormalReparsePoint -Path $directoryPath -Recurse
        if (Test-Path -LiteralPath $directoryPath) {
            throw "自动测试目录清理后仍存在：$directoryPath"
        }
    }
}

function Test-GodotProjectImportReady {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot
    )

    $resolvedProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
    $requiredCacheFiles = @(
        (Join-Path $resolvedProjectRoot ".godot\global_script_class_cache.cfg"),
        (Join-Path $resolvedProjectRoot ".godot\editor\filesystem_cache10")
    )
    foreach ($cacheFile in $requiredCacheFiles) {
        if (-not (Test-Path -LiteralPath $cacheFile -PathType Leaf)) {
            return $false
        }
        if ((Get-Item -LiteralPath $cacheFile).Length -le 0) {
            return $false
        }
    }

    $importedRoot = Join-Path $resolvedProjectRoot ".godot\imported"
    if (-not (Test-Path -LiteralPath $importedRoot -PathType Container)) {
        return $false
    }

    $assetsRoot = Join-Path $resolvedProjectRoot "assets"
    if (-not (Test-Path -LiteralPath $assetsRoot -PathType Container)) {
        return $false
    }
    $importableExtensions = @(".jpeg", ".jpg", ".mp3", ".ogg", ".otf", ".png", ".svg", ".ttf", ".wav", ".webp")
    foreach ($asset in @(Get-ChildItem -LiteralPath $assetsRoot -File -Recurse)) {
        if ($importableExtensions -notcontains $asset.Extension.ToLowerInvariant()) {
            continue
        }
        if (-not (Test-Path -LiteralPath ($asset.FullName + ".import") -PathType Leaf)) {
            return $false
        }
    }
    return $true
}

function Initialize-GodotProjectImport {
    param(
        [Parameter(Mandatory = $true)]
        [string]$GodotPath,
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot
    )

    if (Test-GodotProjectImportReady -ProjectRoot $ProjectRoot) {
        return
    }

    Write-Output "PREPARE godot_import=cold_cache"
    $importOutput = @(& $GodotPath --headless --path $ProjectRoot --import 2>&1)
    $importExitCode = $LASTEXITCODE
    if ($importExitCode -ne 0) {
        $importOutput | Select-Object -Last 40 | Write-Output
        throw "Godot 冷缓存导入失败，退出码：$importExitCode"
    }
    if (-not (Test-GodotProjectImportReady -ProjectRoot $ProjectRoot)) {
        $importOutput | Select-Object -Last 40 | Write-Output
        throw "Godot 冷缓存导入结束，但全局类或运行资源仍未就绪。"
    }
    Write-Output "PREPARE godot_import=completed"
}

function Test-AutomatedTestRunLockContention {
    param(
        [Parameter(Mandatory = $true)]
        [System.Exception]$Exception
    )

    if ($env:OS -ne "Windows_NT") {
        return $true
    }
    $ioException = $null
    $currentException = $Exception
    while ($null -ne $currentException) {
        if ($currentException -is [System.IO.IOException]) {
            $ioException = $currentException
        }
        $currentException = $currentException.InnerException
    }
    if ($null -eq $ioException) {
        return $false
    }
    $sharingViolationHResult = -2147024864 # 0x80070020: ERROR_SHARING_VIOLATION
    $lockViolationHResult = -2147024863    # 0x80070021: ERROR_LOCK_VIOLATION
    return $ioException.HResult -in @($sharingViolationHResult, $lockViolationHResult)
}

function Enter-AutomatedTestRunLock {
    param(
        [Parameter(Mandatory = $true)]
        [string]$StateRoot
    )

    $resolvedStateRoot = [System.IO.Path]::GetFullPath($StateRoot).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
    Assert-NoFormalReparsePoint -Path $resolvedStateRoot
    $lockDirectory = [System.IO.Path]::GetDirectoryName($resolvedStateRoot)
    $stateRootName = [System.IO.Path]::GetFileName($resolvedStateRoot)
    if ([string]::IsNullOrWhiteSpace($lockDirectory) -or [string]::IsNullOrWhiteSpace($stateRootName)) {
        throw "自动测试状态根不能映射到共享锁：$resolvedStateRoot"
    }
    Assert-NoFormalReparsePoint -Path $lockDirectory
    [System.IO.Directory]::CreateDirectory($lockDirectory) | Out-Null
    Assert-NoFormalReparsePoint -Path $lockDirectory
    $lockPath = Join-Path $lockDirectory ("{0}.automated-tests.lock" -f $stateRootName)
    try {
        return [System.IO.File]::Open(
            $lockPath,
            [System.IO.FileMode]::OpenOrCreate,
            [System.IO.FileAccess]::ReadWrite,
            [System.IO.FileShare]::None
        )
    }
    catch [System.IO.IOException] {
        if (-not (Test-AutomatedTestRunLockContention -Exception $_.Exception)) {
            throw
        }
        throw [System.InvalidOperationException]::new(
            "已有一组 Godot 自动测试正在运行。请等待它完成后再启动另一组测试。锁文件：$lockPath",
            $_.Exception
        )
    }
}

function Exit-AutomatedTestRunLock {
    param(
        [AllowNull()]
        [System.IO.FileStream]$LockStream
    )
    if ($null -ne $LockStream) {
        $LockStream.Dispose()
    }
}

function Get-FormalRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BasePath,
        [Parameter(Mandatory = $true)]
        [string]$ChildPath
    )

    $resolvedBase = [System.IO.Path]::GetFullPath($BasePath)
    $basePrefix = $resolvedBase.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    ) + [System.IO.Path]::DirectorySeparatorChar
    $resolvedChild = [System.IO.Path]::GetFullPath($ChildPath)
    if (-not $resolvedChild.StartsWith($basePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Formal state child escaped base path: $resolvedChild"
    }
    return $resolvedChild.Substring($basePrefix.Length).Replace("\", "/")
}

function Assert-NoFormalReparsePoint {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [switch]$Recurse
    )

    $resolvedPath = [System.IO.Path]::GetFullPath($Path)
    $pathRoot = [System.IO.Path]::GetPathRoot($resolvedPath)
    if ([string]::IsNullOrWhiteSpace($pathRoot)) {
        throw "Formal state path has no filesystem root: $resolvedPath"
    }
    $currentItem = Get-Item -LiteralPath $pathRoot -Force -ErrorAction Stop
    if (($currentItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Formal state ancestor reparse point is not allowed: $($currentItem.FullName)"
    }
    $nameComparison = if ($env:OS -eq "Windows_NT") {
        [System.StringComparison]::OrdinalIgnoreCase
    }
    else {
        [System.StringComparison]::Ordinal
    }
    $relativePath = $resolvedPath.Substring($pathRoot.Length)
    $pathSegments = @(
        $relativePath.Split(
            [char[]]@(
                [System.IO.Path]::DirectorySeparatorChar,
                [System.IO.Path]::AltDirectorySeparatorChar
            ),
            [System.StringSplitOptions]::RemoveEmptyEntries
        )
    )
    foreach ($segment in $pathSegments) {
        if (-not $currentItem.PSIsContainer) {
            return
        }
        $nextItem = @(
            Get-ChildItem -LiteralPath $currentItem.FullName -Force -ErrorAction Stop |
                Where-Object {
                    [string]::Equals($_.Name, $segment, $nameComparison)
                }
        ) | Select-Object -First 1
        if ($null -eq $nextItem) {
            return
        }
        if (($nextItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Formal state ancestor reparse point is not allowed: $($nextItem.FullName)"
        }
        $currentItem = $nextItem
    }
    if (-not $Recurse -or -not $currentItem.PSIsContainer) {
        return
    }
    $pending = [System.Collections.Generic.Stack[string]]::new()
    $pending.Push($currentItem.FullName)
    while ($pending.Count -gt 0) {
        $currentPath = $pending.Pop()
        foreach ($child in @(Get-ChildItem -LiteralPath $currentPath -Force -ErrorAction Stop)) {
            if (($child.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "Formal state descendant reparse point is not allowed: $($child.FullName)"
            }
            if ($child.PSIsContainer) {
                $pending.Push($child.FullName)
            }
        }
    }
}

function Remove-AutomatedTestDirectoryNoFollow {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedPath = [System.IO.Path]::GetFullPath($Path)
    Assert-NoFormalReparsePoint -Path $resolvedPath
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Container)) {
        throw "自动测试目录在预检后发生变化：$resolvedPath"
    }
    $children = @(
        Get-ChildItem -LiteralPath $resolvedPath -Force -ErrorAction Stop |
            Sort-Object FullName
    )
    Assert-NoFormalReparsePoint -Path $resolvedPath
    foreach ($child in $children) {
        Assert-NoFormalReparsePoint -Path $resolvedPath
        Assert-NoFormalReparsePoint -Path $child.FullName
        if ($child.PSIsContainer) {
            Remove-AutomatedTestDirectoryNoFollow -Path $child.FullName
            continue
        }
        if (-not (Test-Path -LiteralPath $child.FullName -PathType Leaf)) {
            throw "自动测试目录子项在删除前发生变化：$($child.FullName)"
        }
        Remove-Item -LiteralPath $child.FullName -Force -ErrorAction Stop
    }
    Assert-NoFormalReparsePoint -Path $resolvedPath
    [System.IO.Directory]::Delete($resolvedPath)
}

function Test-FormalPathSegmentName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ([string]::IsNullOrEmpty($Name)) {
        return $false
    }
    foreach ($invalidCharacter in [System.IO.Path]::GetInvalidFileNameChars()) {
        if ($Name.IndexOf($invalidCharacter) -ge 0) {
            return $false
        }
    }
    if ($env:OS -eq "Windows_NT") {
        if ($Name.EndsWith(" ", [System.StringComparison]::Ordinal) -or $Name.EndsWith(".", [System.StringComparison]::Ordinal)) {
            return $false
        }
    }
    return $true
}

function Assert-FormalRelativeEntryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BasePath,
        [Parameter(Mandatory = $true)]
        [string]$RelativePath,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if ([string]::IsNullOrWhiteSpace($RelativePath) -or [System.IO.Path]::IsPathRooted($RelativePath)) {
        throw "Invalid formal snapshot relative path for ${Label}: $RelativePath"
    }
    if (
        $RelativePath.Contains("\") -or
        $RelativePath.StartsWith("/", [System.StringComparison]::Ordinal) -or
        $RelativePath.EndsWith("/", [System.StringComparison]::Ordinal) -or
        $RelativePath.Contains("//")
    ) {
        throw "Formal snapshot relative path is not canonical for ${Label}: $RelativePath"
    }
    foreach ($segment in @($RelativePath.Split('/'))) {
        if ($segment -eq "." -or $segment -eq "..") {
            throw "Formal snapshot relative path is not canonical for ${Label}: $RelativePath"
        }
        if (-not (Test-FormalPathSegmentName -Name $segment)) {
            throw "Formal snapshot relative path has an invalid path segment for ${Label}: $RelativePath"
        }
    }
    $resolvedBase = [System.IO.Path]::GetFullPath($BasePath)
    $basePrefix = $resolvedBase.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    ) + [System.IO.Path]::DirectorySeparatorChar
    $resolvedChild = [System.IO.Path]::GetFullPath((Join-Path $resolvedBase $RelativePath))
    if (-not $resolvedChild.StartsWith($basePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Formal snapshot relative path escaped ${Label}: $RelativePath"
    }
    $canonicalRelativePath = $resolvedChild.Substring($basePrefix.Length).Replace("\", "/")
    if (-not [string]::Equals($RelativePath, $canonicalRelativePath, [System.StringComparison]::Ordinal)) {
        throw "Formal snapshot relative path is not canonical for ${Label}: $RelativePath"
    }
}

function Get-FormalBytePayloadSha256 {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [byte[]]$Bytes
    )

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        return [System.BitConverter]::ToString($sha256.ComputeHash($Bytes)).Replace("-", "")
    }
    finally {
        $sha256.Dispose()
    }
}

function Assert-FormalTrackedPathEntryRestorable {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Entry,
        [Parameter(Mandatory = $true)]
        [string]$TargetPath,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if (-not $Entry.Contains("Kind")) {
        throw "Formal snapshot entry has no Kind: $Label"
    }
    $kind = [string]$Entry.Kind
    if ($kind -eq "missing") {
        return
    }
    if ($kind -eq "file") {
        if (
            -not $Entry.Contains("Bytes") -or
            -not ($Entry.Bytes -is [byte[]]) -or
            -not $Entry.Contains("Length") -or
            -not $Entry.Contains("Sha256")
        ) {
            throw "Formal snapshot file has no byte payload: $Label"
        }
        $bytes = [byte[]]$Entry.Bytes
        if (
            [long]$Entry.Length -ne [long]$bytes.LongLength -or
            -not [string]::Equals(
                [string]$Entry.Sha256,
                (Get-FormalBytePayloadSha256 -Bytes $bytes),
                [System.StringComparison]::OrdinalIgnoreCase
            )
        ) {
            throw "Formal snapshot file payload does not match length or SHA-256: $Label"
        }
        return
    }
    if ($kind -ne "directory") {
        throw "Unsupported formal snapshot kind for ${Label}: $kind"
    }
    if (-not $Entry.Contains("Directories") -or -not $Entry.Contains("Files") -or -not ($Entry.Files -is [System.Collections.IDictionary])) {
        throw "Formal snapshot directory structure is incomplete: $Label"
    }
    $pathComparer = if ($env:OS -eq "Windows_NT") {
        [System.StringComparer]::OrdinalIgnoreCase
    }
    else {
        [System.StringComparer]::Ordinal
    }
    $directoryPaths = [System.Collections.Generic.HashSet[string]]::new($pathComparer)
    $directoryPathList = [System.Collections.Generic.List[string]]::new()
    foreach ($relativePath in @($Entry.Directories)) {
        $directoryRelativePath = [string]$relativePath
        Assert-FormalRelativeEntryPath -BasePath $TargetPath -RelativePath $directoryRelativePath -Label $Label
        if (-not $directoryPaths.Add($directoryRelativePath)) {
            throw "Formal snapshot directory path is duplicated for ${Label}: $directoryRelativePath"
        }
        $directoryPathList.Add($directoryRelativePath)
    }
    $filePaths = [System.Collections.Generic.HashSet[string]]::new($pathComparer)
    $filePathList = [System.Collections.Generic.List[string]]::new()
    foreach ($relativePathValue in @($Entry.Files.Keys)) {
        $relativePath = [string]$relativePathValue
        Assert-FormalRelativeEntryPath -BasePath $TargetPath -RelativePath $relativePath -Label $Label
        if (-not $filePaths.Add($relativePath)) {
            throw "Formal snapshot file path is duplicated for ${Label}: $relativePath"
        }
        $filePathList.Add($relativePath)
        $fileEntry = $Entry.Files[$relativePathValue]
        if (
            -not ($fileEntry -is [System.Collections.IDictionary]) -or
            -not $fileEntry.Contains("Bytes") -or
            -not ($fileEntry.Bytes -is [byte[]]) -or
            -not $fileEntry.Contains("Length") -or
            -not $fileEntry.Contains("Sha256")
        ) {
            throw "Formal snapshot nested file has no byte payload: $Label/$relativePath"
        }
        $bytes = [byte[]]$fileEntry.Bytes
        if (
            [long]$fileEntry.Length -ne [long]$bytes.LongLength -or
            -not [string]::Equals(
                [string]$fileEntry.Sha256,
                (Get-FormalBytePayloadSha256 -Bytes $bytes),
                [System.StringComparison]::OrdinalIgnoreCase
            )
        ) {
            throw "Formal snapshot nested payload does not match length or SHA-256: $Label/$relativePath"
        }
    }
    foreach ($relativePath in $directoryPathList) {
        if ($filePaths.Contains($relativePath)) {
            throw "Formal snapshot path is both file and directory for ${Label}: $relativePath"
        }
    }
    foreach ($relativePath in @($directoryPathList) + @($filePathList)) {
        $parentSeparator = $relativePath.LastIndexOf('/')
        while ($parentSeparator -ge 0) {
            $parentPath = $relativePath.Substring(0, $parentSeparator)
            if ($filePaths.Contains($parentPath)) {
                throw "Formal snapshot file is an ancestor of another entry for ${Label}: $parentPath"
            }
            if (-not $directoryPaths.Contains($parentPath)) {
                throw "Formal snapshot entry is missing its parent directory for ${Label}: $relativePath -> $parentPath"
            }
            $parentSeparator = $parentPath.LastIndexOf('/')
        }
    }
}

function Test-FormalSidecarName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if (
        [string]::IsNullOrWhiteSpace($Name) -or
        -not (Test-FormalPathSegmentName -Name $Name) -or
        [System.IO.Path]::GetFileName($Name) -ne $Name -or
        $Name.Contains([System.IO.Path]::DirectorySeparatorChar) -or
        $Name.Contains([System.IO.Path]::AltDirectorySeparatorChar)
    ) {
        return $false
    }
    foreach ($pattern in $script:FormalStateSidecarPatterns) {
        if ($Name -like $pattern) {
            return $true
        }
    }
    return $false
}

function Assert-FormalStateSnapshotRestorable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$StateRoot,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Snapshot
    )

    foreach ($stateName in @($script:FormalStateNames + $script:FormalStateDirectoryNames)) {
        if (-not $Snapshot.Contains($stateName) -or -not ($Snapshot[$stateName] -is [System.Collections.IDictionary])) {
            throw "Formal snapshot is missing tracked entry: $stateName"
        }
        Assert-FormalTrackedPathEntryRestorable `
            -Entry $Snapshot[$stateName] `
            -TargetPath (Join-Path $StateRoot $stateName) `
            -Label $stateName
    }
    if (-not $Snapshot.Contains("__formal_sidecars") -or -not ($Snapshot["__formal_sidecars"] -is [System.Collections.IDictionary])) {
        throw "Formal snapshot is missing the sidecar map"
    }
    $sidecarNameComparer = if ($env:OS -eq "Windows_NT") {
        [System.StringComparer]::OrdinalIgnoreCase
    }
    else {
        [System.StringComparer]::Ordinal
    }
    $sidecarNames = [System.Collections.Generic.HashSet[string]]::new($sidecarNameComparer)
    foreach ($sidecarNameValue in @($Snapshot["__formal_sidecars"].Keys)) {
        $sidecarName = [string]$sidecarNameValue
        if (-not (Test-FormalSidecarName -Name $sidecarName)) {
            throw "Formal snapshot has an invalid sidecar name: $sidecarName"
        }
        if (-not $sidecarNames.Add($sidecarName)) {
            throw "Formal snapshot sidecar name is duplicated: $sidecarName"
        }
        $entry = $Snapshot["__formal_sidecars"][$sidecarNameValue]
        if (-not ($entry -is [System.Collections.IDictionary])) {
            throw "Formal snapshot sidecar entry is invalid: $sidecarName"
        }
        Assert-FormalTrackedPathEntryRestorable `
            -Entry $entry `
            -TargetPath (Join-Path $StateRoot $sidecarName) `
            -Label $sidecarName
    }
}

function Assert-NoVisibleGodotWindowBeforeFormalRestore {
    param(
        [Parameter(Mandatory = $true)]
        [string]$StateRoot
    )

    if ($env:OS -ne "Windows_NT") {
        return
    }
    $resolvedRoot = [System.IO.Path]::GetFullPath($StateRoot)
    $tempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    ) + [System.IO.Path]::DirectorySeparatorChar
    if ($resolvedRoot.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return
    }
    $visibleGodot = @(
        Get-Process -ErrorAction SilentlyContinue |
            Where-Object {
                $_.ProcessName -like "Godot*" -and $_.MainWindowHandle -ne [IntPtr]::Zero
            }
    )
    if ($visibleGodot.Count -gt 0) {
        $processSummary = ($visibleGodot | ForEach-Object { "$($_.ProcessName):$($_.Id)" }) -join ","
        throw "Refusing formal state restore while a visible Godot window is running: $processSummary"
    }
}

function Get-FormalTrackedPathEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [switch]$IncludeBytes
    )

    Assert-NoFormalReparsePoint -Path $Path -Recurse
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        if ($IncludeBytes) {
            $bytes = [System.IO.File]::ReadAllBytes($Path)
            return [ordered]@{
                Kind = "file"
                Exists = $true
                Length = [long]$bytes.LongLength
                Sha256 = (Get-FormalBytePayloadSha256 -Bytes $bytes)
                Bytes = $bytes
            }
        }
        $item = Get-Item -LiteralPath $Path
        return [ordered]@{
            Kind = "file"
            Exists = $true
            Length = [long]$item.Length
            Sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
        }
    }
    if (Test-Path -LiteralPath $Path -PathType Container) {
        $entry = [ordered]@{
            Kind = "directory"
            Exists = $true
            Length = [long]0
            Sha256 = "DIRECTORY"
            Directories = @()
            Files = [ordered]@{}
        }
        $entry.Directories = @(
            Get-ChildItem -LiteralPath $Path -Directory -Recurse -Force |
                ForEach-Object {
                    Get-FormalRelativePath -BasePath $Path -ChildPath $_.FullName
                } |
                Sort-Object -Unique
        )
        foreach ($file in @(Get-ChildItem -LiteralPath $Path -File -Recurse -Force | Sort-Object FullName)) {
            $relativePath = Get-FormalRelativePath -BasePath $Path -ChildPath $file.FullName
            if ($IncludeBytes) {
                $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
                $fileEntry = [ordered]@{
                    Length = [long]$bytes.LongLength
                    Sha256 = (Get-FormalBytePayloadSha256 -Bytes $bytes)
                    Bytes = $bytes
                }
            }
            else {
                $fileEntry = [ordered]@{
                    Length = [long]$file.Length
                    Sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash
                }
            }
            $entry.Files[$relativePath] = $fileEntry
        }
        return $entry
    }
    $entry = [ordered]@{
        Kind = "missing"
        Exists = $false
        Length = [long]0
        Sha256 = "MISSING"
    }
    if ($IncludeBytes) {
        $entry["Bytes"] = [byte[]]@()
    }
    return $entry
}

function Compare-FormalTrackedPathEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$BeforeEntry,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$AfterEntry
    )

    $changes = [System.Collections.Generic.List[string]]::new()
    $beforeKind = [string]$BeforeEntry.Kind
    $afterKind = [string]$AfterEntry.Kind
    if ($beforeKind -ne $afterKind) {
        $changes.Add("$Name type before=$beforeKind after=$afterKind")
        return @($changes)
    }
    if ($beforeKind -eq "missing") {
        return @($changes)
    }
    if ($beforeKind -eq "file") {
        if (
            [long]$BeforeEntry.Length -ne [long]$AfterEntry.Length -or
            [string]$BeforeEntry.Sha256 -ne [string]$AfterEntry.Sha256
        ) {
            $changes.Add(
                "$Name before=$($BeforeEntry.Sha256)/$($BeforeEntry.Length) after=$($AfterEntry.Sha256)/$($AfterEntry.Length)"
            )
        }
        return @($changes)
    }
    if ($beforeKind -ne "directory") {
        $changes.Add("$Name unsupported type=$beforeKind")
        return @($changes)
    }

    $directoryNames = @($BeforeEntry.Directories) + @($AfterEntry.Directories) | Sort-Object -Unique
    foreach ($directoryName in $directoryNames) {
        $beforeHasDirectory = @($BeforeEntry.Directories) -contains $directoryName
        $afterHasDirectory = @($AfterEntry.Directories) -contains $directoryName
        if ($beforeHasDirectory -ne $afterHasDirectory) {
            $changes.Add("$Name/$directoryName directory set changed")
        }
    }
    $relativePaths = @($BeforeEntry.Files.Keys) + @($AfterEntry.Files.Keys) | Sort-Object -Unique
    foreach ($relativePath in $relativePaths) {
        $beforeFile = $BeforeEntry.Files[$relativePath]
        $afterFile = $AfterEntry.Files[$relativePath]
        if ($null -eq $beforeFile -or $null -eq $afterFile) {
            $changes.Add("$Name/$relativePath file set changed")
            continue
        }
        if (
            [long]$beforeFile.Length -ne [long]$afterFile.Length -or
            [string]$beforeFile.Sha256 -ne [string]$afterFile.Sha256
        ) {
            $changes.Add(
                "$Name/$relativePath before=$($beforeFile.Sha256)/$($beforeFile.Length) after=$($afterFile.Sha256)/$($afterFile.Length)"
            )
        }
    }
    return @($changes)
}

function Restore-FormalTrackedPathEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$StateRoot,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Entry
    )

    $resolvedStateRoot = [System.IO.Path]::GetFullPath($StateRoot)
    $rootPrefix = $resolvedStateRoot.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    ) + [System.IO.Path]::DirectorySeparatorChar
    $targetPath = [System.IO.Path]::GetFullPath((Join-Path $resolvedStateRoot $Name))
    if (-not $targetPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Formal state target escaped StateRoot: $targetPath"
    }

    $kind = [string]$Entry.Kind
    if ($kind -eq "missing") {
        if (Test-Path -LiteralPath $targetPath -PathType Container) {
            Remove-Item -LiteralPath $targetPath -Recurse -Force
        }
        elseif (Test-Path -LiteralPath $targetPath) {
            Remove-Item -LiteralPath $targetPath -Force
        }
        return
    }
    if ($kind -eq "file") {
        if (Test-Path -LiteralPath $targetPath -PathType Container) {
            Remove-Item -LiteralPath $targetPath -Recurse -Force
        }
        New-Item -ItemType Directory -Path (Split-Path -Parent $targetPath) -Force | Out-Null
        [System.IO.File]::WriteAllBytes($targetPath, [byte[]]$Entry.Bytes)
        return
    }
    if ($kind -ne "directory") {
        throw "Unsupported formal state kind for ${Name}: $kind"
    }

    if (Test-Path -LiteralPath $targetPath -PathType Leaf) {
        Remove-Item -LiteralPath $targetPath -Force
    }
    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    $targetPrefix = $targetPath.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    ) + [System.IO.Path]::DirectorySeparatorChar
    $expectedRelativePaths = @($Entry.Files.Keys)
    foreach ($currentFile in @(Get-ChildItem -LiteralPath $targetPath -File -Recurse -Force)) {
        $relativePath = Get-FormalRelativePath -BasePath $targetPath -ChildPath $currentFile.FullName
        if ($expectedRelativePaths -notcontains $relativePath) {
            Remove-Item -LiteralPath $currentFile.FullName -Force
        }
    }
    $expectedDirectories = @($Entry.Directories)
    $currentDirectories = @(
        Get-ChildItem -LiteralPath $targetPath -Directory -Recurse -Force |
            Sort-Object { $_.FullName.Length } -Descending
    )
    foreach ($currentDirectory in $currentDirectories) {
        $relativePath = Get-FormalRelativePath -BasePath $targetPath -ChildPath $currentDirectory.FullName
        if ($expectedDirectories -notcontains $relativePath) {
            Remove-Item -LiteralPath $currentDirectory.FullName -Recurse -Force
        }
    }
    foreach ($relativePath in @($expectedDirectories | Sort-Object { $_.Length }, { $_ })) {
        $directoryPath = [System.IO.Path]::GetFullPath((Join-Path $targetPath $relativePath))
        if (-not $directoryPath.StartsWith($targetPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Formal state nested directory escaped target: $directoryPath"
        }
        New-Item -ItemType Directory -Path $directoryPath -Force | Out-Null
    }
    foreach ($relativePath in $expectedRelativePaths) {
        $filePath = [System.IO.Path]::GetFullPath((Join-Path $targetPath $relativePath))
        if (-not $filePath.StartsWith($targetPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Formal state nested file escaped target: $filePath"
        }
        New-Item -ItemType Directory -Path (Split-Path -Parent $filePath) -Force | Out-Null
        [System.IO.File]::WriteAllBytes($filePath, [byte[]]$Entry.Files[$relativePath].Bytes)
    }
}

function Get-FormalStateSnapshot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$StateRoot,
        [switch]$IncludeBytes
    )

    Assert-NoFormalReparsePoint -Path $StateRoot
    $snapshot = [ordered]@{}
    foreach ($stateName in @($script:FormalStateNames + $script:FormalStateDirectoryNames)) {
        $snapshot[$stateName] = Get-FormalTrackedPathEntry `
            -Path (Join-Path $StateRoot $stateName) `
            -IncludeBytes:$IncludeBytes
    }
    $sidecars = [ordered]@{}
    if (Test-Path -LiteralPath $StateRoot -PathType Container) {
        $sidecarItems = foreach ($pattern in $script:FormalStateSidecarPatterns) {
            Get-ChildItem -LiteralPath $StateRoot -Force -Filter $pattern
        }
        foreach ($item in @($sidecarItems | Sort-Object Name -Unique)) {
            $sidecars[$item.Name] = Get-FormalTrackedPathEntry `
                -Path $item.FullName `
                -IncludeBytes:$IncludeBytes
        }
    }
    $snapshot["__formal_sidecars"] = $sidecars
    return $snapshot
}

function Compare-FormalStateSnapshot {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Before,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$After
    )

    $changes = [System.Collections.Generic.List[string]]::new()
    foreach ($stateName in @($script:FormalStateNames + $script:FormalStateDirectoryNames)) {
        foreach ($change in @(
            Compare-FormalTrackedPathEntry `
                -Name $stateName `
                -BeforeEntry $Before[$stateName] `
                -AfterEntry $After[$stateName]
        )) {
            $changes.Add($change)
        }
    }
    $sidecarNames = @($Before["__formal_sidecars"].Keys) + @($After["__formal_sidecars"].Keys) | Sort-Object -Unique
    foreach ($sidecarName in $sidecarNames) {
        $beforeEntry = $Before["__formal_sidecars"][$sidecarName]
        $afterEntry = $After["__formal_sidecars"][$sidecarName]
        if ($null -eq $beforeEntry -or $null -eq $afterEntry) {
            $changes.Add("$sidecarName formal sidecar set changed")
            continue
        }
        foreach ($change in @(
            Compare-FormalTrackedPathEntry `
                -Name $sidecarName `
                -BeforeEntry $beforeEntry `
                -AfterEntry $afterEntry
        )) {
            $changes.Add($change)
        }
    }
    return @($changes)
}

function Restore-FormalStateSnapshot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$StateRoot,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Snapshot
    )

    $resolvedStateRoot = [System.IO.Path]::GetFullPath($StateRoot)
    Assert-FormalStateSnapshotRestorable -StateRoot $resolvedStateRoot -Snapshot $Snapshot
    Assert-NoVisibleGodotWindowBeforeFormalRestore -StateRoot $resolvedStateRoot
    if (Test-Path -LiteralPath $resolvedStateRoot -PathType Leaf) {
        throw "Formal StateRoot is not a directory: $resolvedStateRoot"
    }
    Assert-NoFormalReparsePoint -Path $resolvedStateRoot
    foreach ($stateName in @($script:FormalStateNames + $script:FormalStateDirectoryNames)) {
        Assert-NoFormalReparsePoint `
            -Path (Join-Path $resolvedStateRoot $stateName) `
            -Recurse
    }
    if (Test-Path -LiteralPath $resolvedStateRoot -PathType Container) {
        $currentSidecarItems = foreach ($pattern in $script:FormalStateSidecarPatterns) {
            Get-ChildItem -LiteralPath $resolvedStateRoot -Force -Filter $pattern -ErrorAction SilentlyContinue
        }
        foreach ($currentItem in @($currentSidecarItems | Sort-Object Name -Unique)) {
            Assert-NoFormalReparsePoint -Path $currentItem.FullName -Recurse
        }
    }

    New-Item -ItemType Directory -Path $resolvedStateRoot -Force | Out-Null
    foreach ($stateName in @($script:FormalStateNames + $script:FormalStateDirectoryNames)) {
        Restore-FormalTrackedPathEntry `
            -StateRoot $resolvedStateRoot `
            -Name $stateName `
            -Entry $Snapshot[$stateName]
    }
    $expectedSidecars = @($Snapshot["__formal_sidecars"].Keys)
    foreach ($pattern in $script:FormalStateSidecarPatterns) {
        foreach ($currentItem in @(Get-ChildItem -LiteralPath $StateRoot -Force -Filter $pattern -ErrorAction SilentlyContinue)) {
            if ($expectedSidecars -notcontains $currentItem.Name) {
                Restore-FormalTrackedPathEntry `
                    -StateRoot $resolvedStateRoot `
                    -Name $currentItem.Name `
                    -Entry ([ordered]@{ Kind = "missing" })
            }
        }
    }
    foreach ($sidecarName in $expectedSidecars) {
        Restore-FormalTrackedPathEntry `
            -StateRoot $resolvedStateRoot `
            -Name $sidecarName `
            -Entry $Snapshot["__formal_sidecars"][$sidecarName]
    }
}

function Get-AutomatedRunArtifactFromLog {
    param(
        [Parameter(Mandatory = $true)]
        [int]$ProcessExitCode,
        [Parameter(Mandatory = $true)]
        [string]$LogPath,
        [Parameter(Mandatory = $true)]
        [string]$MarkerPrefix,
        [Parameter(Mandatory = $true)]
        [string]$ArtifactRoot,
        [Parameter(Mandatory = $true)]
        [string]$FileNamePattern
    )

    if ($ProcessExitCode -ne 0) {
        throw "Current run process exited with code $ProcessExitCode; refusing artifact acceptance."
    }

    $resolvedLogPath = [System.IO.Path]::GetFullPath($LogPath)
    if (-not (Test-Path -LiteralPath $resolvedLogPath -PathType Leaf)) {
        throw "Current run stdout log is missing: $resolvedLogPath"
    }
    $logItem = Get-Item -LiteralPath $resolvedLogPath -Force
    if (($logItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Current run stdout log must not be a reparse point: $resolvedLogPath"
    }

    $markerValues = [System.Collections.Generic.List[string]]::new()
    foreach ($line in [System.IO.File]::ReadAllLines($resolvedLogPath)) {
        if ($line.StartsWith($MarkerPrefix, [System.StringComparison]::Ordinal)) {
            $markerValues.Add($line.Substring($MarkerPrefix.Length).Trim())
        }
    }
    if ($markerValues.Count -ne 1 -or [string]::IsNullOrWhiteSpace($markerValues[0])) {
        throw "Current run must emit exactly one non-empty artifact marker '$MarkerPrefix'; actual=$($markerValues.Count)"
    }
    if (-not [System.IO.Path]::IsPathFullyQualified($markerValues[0])) {
        throw "Current run artifact marker is not an absolute path: $($markerValues[0])"
    }

    $resolvedArtifactRoot = [System.IO.Path]::GetFullPath($ArtifactRoot).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
    $resolvedArtifactPath = [System.IO.Path]::GetFullPath($markerValues[0])
    $artifactParent = [System.IO.Path]::GetDirectoryName($resolvedArtifactPath).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
    $pathComparison = if ($env:OS -eq "Windows_NT") {
        [System.StringComparison]::OrdinalIgnoreCase
    }
    else {
        [System.StringComparison]::Ordinal
    }
    if (-not [string]::Equals($artifactParent, $resolvedArtifactRoot, $pathComparison)) {
        throw "Current run artifact marker must name a direct child of the artifact root: $resolvedArtifactPath"
    }
    $artifactName = [System.IO.Path]::GetFileName($resolvedArtifactPath)
    if ($artifactName -notlike $FileNamePattern) {
        throw "Current run artifact name '$artifactName' does not match '$FileNamePattern'"
    }
    if (-not (Test-Path -LiteralPath $resolvedArtifactPath -PathType Leaf)) {
        throw "Current run artifact is missing: $resolvedArtifactPath"
    }
    $artifactItem = Get-Item -LiteralPath $resolvedArtifactPath -Force
    if (($artifactItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Current run artifact must not be a reparse point: $resolvedArtifactPath"
    }
    if ($artifactItem.Length -le 0) {
        throw "Current run artifact is empty: $resolvedArtifactPath"
    }
    return $artifactItem
}

function Get-AutomatedRunCompanionArtifact {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$ArtifactRoot,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedFileName,
        [Parameter(Mandatory = $true)]
        [string]$ArtifactLabel
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "$ArtifactLabel path is empty"
    }
    if (
        [string]::IsNullOrWhiteSpace($ExpectedFileName) -or
        [System.IO.Path]::GetFileName($ExpectedFileName) -ne $ExpectedFileName
    ) {
        throw "$ArtifactLabel expected file name must be one leaf name: $ExpectedFileName"
    }

    $resolvedArtifactRoot = [System.IO.Path]::GetFullPath($ArtifactRoot).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
    $resolvedArtifactPath = [System.IO.Path]::GetFullPath($Path)
    $artifactParent = [System.IO.Path]::GetDirectoryName($resolvedArtifactPath).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
    $pathComparison = if ($env:OS -eq "Windows_NT") {
        [System.StringComparison]::OrdinalIgnoreCase
    }
    else {
        [System.StringComparison]::Ordinal
    }
    if (-not [string]::Equals($artifactParent, $resolvedArtifactRoot, $pathComparison)) {
        throw "$ArtifactLabel must be a direct child of the artifact root: $resolvedArtifactPath"
    }
    $actualFileName = [System.IO.Path]::GetFileName($resolvedArtifactPath)
    if (-not [string]::Equals($actualFileName, $ExpectedFileName, $pathComparison)) {
        throw "$ArtifactLabel must use the exact companion name '$ExpectedFileName'; actual='$actualFileName'"
    }
    if (-not (Test-Path -LiteralPath $resolvedArtifactPath -PathType Leaf)) {
        throw "$ArtifactLabel is missing: $resolvedArtifactPath"
    }
    $artifactItem = Get-Item -LiteralPath $resolvedArtifactPath -Force
    if (($artifactItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "$ArtifactLabel must not be a reparse point: $resolvedArtifactPath"
    }
    if ($artifactItem.Length -le 0) {
        throw "$ArtifactLabel is empty: $resolvedArtifactPath"
    }
    return $artifactItem
}
