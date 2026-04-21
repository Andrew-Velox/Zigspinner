param(
    [string]$RustExe = "../rattles/target/release/examples/bench_controlled.exe",
    [string]$ZigExe = "./zig-out/bin/example-bench-controlled.exe",
    [int]$Runs = 12,
    [long]$Iters = 100000000,
    [string]$OutJson = "benchmark/latest.json",
    [string]$OutMd = "benchmark/latest.md",
    [string]$ReadmePath = "README.md",
    [switch]$UpdateReadme
)

$ErrorActionPreference = "Stop"

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8NoBom([string]$pathValue, [string]$content) {
    Ensure-ParentDir $pathValue
    [System.IO.File]::WriteAllText($pathValue, $content, $Utf8NoBom)
}

function Resolve-PathSafe([string]$pathValue) {
    $resolved = Resolve-Path -LiteralPath $pathValue -ErrorAction SilentlyContinue
    if ($null -ne $resolved) { return $resolved.Path }
    return (Join-Path (Get-Location).Path $pathValue)
}

function Run-Benchmark([string]$exePath, [string]$name, [int]$runs, [long]$iters) {
    if (-not (Test-Path -LiteralPath $exePath)) {
        throw "Executable not found for ${name}: $exePath"
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $exePath
    $psi.EnvironmentVariables["BENCH_ITERS"] = "$iters"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true

    Write-Host "Warming up $name..."
    $warm = [System.Diagnostics.Process]::Start($psi)
    $pinFailed = $false
    try {
        $warm.ProcessorAffinity = [IntPtr]1
    } catch {
        $pinFailed = $true
    }
    $null = $warm.StandardOutput.ReadToEnd()
    $null = $warm.StandardError.ReadToEnd()
    $warm.WaitForExit()

    $samples = @()
    Write-Host "Running $runs iterations for $name..."
    for ($i = 1; $i -le $runs; $i++) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $p = [System.Diagnostics.Process]::Start($psi)
        try {
            $p.ProcessorAffinity = [IntPtr]1
        } catch {
            $pinFailed = $true
        }

        $null = $p.StandardOutput.ReadToEnd()
        $null = $p.StandardError.ReadToEnd()
        $p.WaitForExit()
        $sw.Stop()

        if ($p.ExitCode -ne 0) {
            throw "$name run $i failed with exit code $($p.ExitCode)"
        }

        $seconds = $sw.Elapsed.TotalSeconds
        $samples += $seconds
        Write-Host ("{0} run {1}: {2:F7}s" -f $name, $i, $seconds)
    }

    $sorted = @($samples | Sort-Object)
    $mean = ($sorted | Measure-Object -Average).Average
    $median = if ($runs % 2 -eq 0) {
        ($sorted[$runs / 2 - 1] + $sorted[$runs / 2]) / 2
    } else {
        $sorted[[int][math]::Floor($runs / 2)]
    }

    return [PSCustomObject]@{
        Name = $name
        Raw = $sorted
        Min = [double]$sorted[0]
        Mean = [double]$mean
        Median = [double]$median
        Max = [double]$sorted[-1]
        PinningHadFailure = $pinFailed
    }
}

function Ensure-ParentDir([string]$pathValue) {
    $parent = Split-Path -Parent $pathValue
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
}

function Build-Markdown(
    [pscustomobject]$rust,
    [pscustomobject]$zig,
    [string]$date,
    [int]$runs,
    [long]$iters,
    [bool]$pinningWarning
) {
    $meanDiff = (($rust.Mean - $zig.Mean) / $rust.Mean) * 100.0
    $medianDiff = (($rust.Median - $zig.Median) / $rust.Median) * 100.0

    $lines = @()
    $lines += "### Benchmark Snapshot ($date)"
    $lines += ""
    $lines += "Method:"
    $lines += ""
    $lines += "- Controlled, non-interactive spinner loop"
    $lines += "- Same workload in both implementations"
    $lines += "- BENCH_ITERS=$iters"
    $lines += "- CPU affinity pinned to one core when supported"
    $lines += "- 1 warmup + $runs measured runs each"
    if ($pinningWarning) {
        $lines += "- Note: CPU pinning failed on at least one run; timing still completed"
    }
    $lines += ""
    $lines += "Results (seconds, lower is better):"
    $lines += ""
    $lines += "| Impl | Min | Mean | Median | Max |"
    $lines += "|---|---:|---:|---:|---:|"
    $lines += ("| Rust (rattles) | {0:F4} | {1:F4} | {2:F4} | {3:F4} |" -f $rust.Min, $rust.Mean, $rust.Median, $rust.Max)
    $lines += ("| Zig (Zigspinner) | {0:F4} | {1:F4} | {2:F4} | {3:F4} |" -f $zig.Min, $zig.Mean, $zig.Median, $zig.Max)
    $lines += ""
    $lines += "Winner:"
    $lines += ""
    $lines += ("- By mean: Zig ({0:F2}% faster)" -f $meanDiff)
    $lines += ("- By median: Zig ({0:F2}% faster)" -f $medianDiff)

    return ($lines -join "`n")
}

function Build-MarkdownZigOnly(
    [pscustomobject]$zig,
    [string]$date,
    [int]$runs,
    [long]$iters,
    [bool]$pinningWarning
) {
    $lines = @()
    $lines += "### Benchmark Snapshot ($date)"
    $lines += ""
    $lines += "Mode: Zig-only (Rust baseline not found in this checkout)"
    $lines += ""
    $lines += "Method:"
    $lines += ""
    $lines += "- Controlled, non-interactive spinner loop"
    $lines += "- BENCH_ITERS=$iters"
    $lines += "- CPU affinity pinned to one core when supported"
    $lines += "- 1 warmup + $runs measured runs"
    if ($pinningWarning) {
        $lines += "- Note: CPU pinning failed on at least one run; timing still completed"
    }
    $lines += ""
    $lines += "Results (seconds, lower is better):"
    $lines += ""
    $lines += "| Impl | Min | Mean | Median | Max |"
    $lines += "|---|---:|---:|---:|---:|"
    $lines += ("| Zig (Zigspinner) | {0:F4} | {1:F4} | {2:F4} | {3:F4} |" -f $zig.Min, $zig.Mean, $zig.Median, $zig.Max)
    $lines += ""
    $lines += "To enable cross-language comparison, run with a valid Rust benchmark executable path using -RustExe."

    return ($lines -join "`n")
}

$rustExeResolved = Resolve-PathSafe $RustExe
$zigExeResolved = Resolve-PathSafe $ZigExe

$rustAvailable = Test-Path -LiteralPath $rustExeResolved
$zigAvailable = Test-Path -LiteralPath $zigExeResolved

if (-not $zigAvailable) {
    throw "Zig benchmark executable not found: $zigExeResolved"
}

if (-not $rustAvailable) {
    Write-Host "Rust benchmark executable not found at: $rustExeResolved"
    Write-Host "Falling back to Zig-only benchmark mode."
}

$zigStats = Run-Benchmark -exePath $zigExeResolved -name "Zig" -runs $Runs -iters $Iters
$rustStats = $null

if ($rustAvailable) {
    $rustStats = Run-Benchmark -exePath $rustExeResolved -name "Rust" -runs $Runs -iters $Iters
}

$today = Get-Date -Format "yyyy-MM-dd"
$pinningWarning = $zigStats.PinningHadFailure
if ($rustStats -ne $null) {
    $pinningWarning = $pinningWarning -or $rustStats.PinningHadFailure
    $md = Build-Markdown -rust $rustStats -zig $zigStats -date $today -runs $Runs -iters $Iters -pinningWarning $pinningWarning
} else {
    $md = Build-MarkdownZigOnly -zig $zigStats -date $today -runs $Runs -iters $Iters -pinningWarning $pinningWarning
}

$payload = [PSCustomObject]@{
    date = $today
    runs = $Runs
    iterations = $Iters
    mode = if ($rustStats -ne $null) { "cross-language" } else { "zig-only" }
    rust = $rustStats
    zig = $zigStats
}

$json = $payload | ConvertTo-Json -Depth 6
Write-Utf8NoBom -pathValue $OutJson -content $json
Write-Utf8NoBom -pathValue $OutMd -content $md

Write-Host ""
Write-Host "Zig raw:  $($zigStats.Raw -join ', ')"
Write-Host ("Zig stats:  min={0:F4} mean={1:F4} median={2:F4} max={3:F4}" -f $zigStats.Min, $zigStats.Mean, $zigStats.Median, $zigStats.Max)
if ($rustStats -ne $null) {
    Write-Host "Rust raw: $($rustStats.Raw -join ', ')"
    Write-Host ("Rust stats: min={0:F4} mean={1:F4} median={2:F4} max={3:F4}" -f $rustStats.Min, $rustStats.Mean, $rustStats.Median, $rustStats.Max)
}

if ($UpdateReadme) {
    if (-not (Test-Path -LiteralPath $ReadmePath)) {
        throw "README not found: $ReadmePath"
    }

    $readme = Get-Content -LiteralPath $ReadmePath -Raw -Encoding UTF8
    $startTag = "<!-- BENCHMARK:START -->"
    $endTag = "<!-- BENCHMARK:END -->"

    $start = $readme.IndexOf($startTag)
    $end = $readme.IndexOf($endTag)

    if ($start -lt 0 -or $end -lt 0 -or $end -le $start) {
        throw "README benchmark markers not found or invalid"
    }

    $before = $readme.Substring(0, $start + $startTag.Length)
    $after = $readme.Substring($end)

    $newReadme = $before + "`n" + $md + "`n" + $after
    Write-Utf8NoBom -pathValue $ReadmePath -content $newReadme
    Write-Host "README benchmark section updated"
}
