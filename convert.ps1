# ============================================================
#  MKV -> MP4 converter
#  - Auto-downloads a portable ffmpeg on first run if missing.
#  - Tries a fast, lossless remux first (copies the video track,
#    converts audio to AAC). Falls back to a full re-encode only
#    if the fast path can't handle the file.
#  Called by "Convert MKV to MP4.bat" with file paths as arguments.
# ============================================================

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$ToolsDir    = Join-Path $ScriptDir 'tools'
$FfmpegDir   = Join-Path $ToolsDir 'ffmpeg'
$LocalFfmpeg = Join-Path $FfmpegDir 'ffmpeg.exe'

function Write-Step($msg) { Write-Host ""; Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    $msg" -ForegroundColor Green }
function Write-Warn2($msg){ Write-Host "    $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "    $msg" -ForegroundColor Red }

# ---- Locate or install ffmpeg -------------------------------------------
function Get-Ffmpeg {
    # 1. Portable copy we installed earlier?
    if (Test-Path $LocalFfmpeg) { return $LocalFfmpeg }

    # 2. Already on PATH?
    $onPath = Get-Command ffmpeg -ErrorAction SilentlyContinue
    if ($onPath) { return $onPath.Source }

    # 3. Download a portable build.
    Write-Step "ffmpeg not found - downloading a portable copy (one time only, ~30 MB)"
    $url = 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip'
    $zip = Join-Path $env:TEMP ('ffmpeg-' + [guid]::NewGuid().ToString('N') + '.zip')
    $tmp = Join-Path $env:TEMP ('ffmpeg-extract-' + [guid]::NewGuid().ToString('N'))

    try {
        Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
        Write-Ok "Downloaded. Unpacking..."
        Expand-Archive -Path $zip -DestinationPath $tmp -Force

        $found = Get-ChildItem -Path $tmp -Recurse -Filter 'ffmpeg.exe' | Select-Object -First 1
        if (-not $found) { throw "Could not find ffmpeg.exe inside the downloaded archive." }

        New-Item -ItemType Directory -Force -Path $FfmpegDir | Out-Null
        Copy-Item $found.FullName $LocalFfmpeg -Force
        # ffprobe is handy too; grab it if present.
        $probe = Get-ChildItem -Path $tmp -Recurse -Filter 'ffprobe.exe' | Select-Object -First 1
        if ($probe) { Copy-Item $probe.FullName (Join-Path $FfmpegDir 'ffprobe.exe') -Force }

        Write-Ok "ffmpeg ready: $LocalFfmpeg"
        return $LocalFfmpeg
    }
    finally {
        Remove-Item $zip -ErrorAction SilentlyContinue
        Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ---- Pick a non-clobbering output path ----------------------------------
function Get-OutputPath($mkvPath) {
    $dir  = Split-Path -Parent $mkvPath
    $name = [IO.Path]::GetFileNameWithoutExtension($mkvPath)
    $out  = Join-Path $dir ($name + '.mp4')
    $i = 1
    while (Test-Path $out) {
        $out = Join-Path $dir ($name + " ($i).mp4")
        $i++
    }
    return $out
}

# ---- Convert one file ---------------------------------------------------
function Convert-One($ffmpeg, $mkvPath) {
    $out = Get-OutputPath $mkvPath
    Write-Step ("Converting: " + (Split-Path -Leaf $mkvPath))

    # Fast path: copy video as-is, re-encode audio to AAC, drop subtitles.
    # This is lossless for the video and takes only a few seconds.
    $fastArgs = @(
        '-y', '-hide_banner', '-loglevel', 'error', '-stats',
        '-i', $mkvPath,
        '-map', '0:v:0', '-map', '0:a?',
        '-c:v', 'copy', '-c:a', 'aac', '-b:a', '192k',
        '-movflags', '+faststart',
        $out
    )
    & $ffmpeg @fastArgs
    if ($LASTEXITCODE -eq 0) {
        Write-Ok ("Done (fast remux): " + (Split-Path -Leaf $out))
        return $true
    }

    Write-Warn2 "Fast remux didn't work for this file (unusual codec). Re-encoding instead - this is slower..."
    Remove-Item $out -ErrorAction SilentlyContinue

    # Fallback: full re-encode to H.264 + AAC. Works for almost anything.
    $reArgs = @(
        '-y', '-hide_banner', '-loglevel', 'error', '-stats',
        '-i', $mkvPath,
        '-map', '0:v:0', '-map', '0:a?',
        '-c:v', 'libx264', '-preset', 'fast', '-crf', '20',
        '-c:a', 'aac', '-b:a', '192k',
        '-movflags', '+faststart',
        $out
    )
    & $ffmpeg @reArgs
    if ($LASTEXITCODE -eq 0) {
        Write-Ok ("Done (re-encoded): " + (Split-Path -Leaf $out))
        return $true
    }

    Write-Err ("FAILED: " + (Split-Path -Leaf $mkvPath))
    Remove-Item $out -ErrorAction SilentlyContinue
    return $false
}

# ---- Main ---------------------------------------------------------------
try {
    $ffmpeg = Get-Ffmpeg
} catch {
    Write-Err "Could not set up ffmpeg automatically:"
    Write-Err $_.Exception.Message
    Write-Host ""
    Write-Warn2 "Check your internet connection and try again, or install ffmpeg manually."
    exit 1
}

$files = @($args | Where-Object { $_ })
$mkvs  = @($files | Where-Object { (Test-Path $_) -and ([IO.Path]::GetExtension($_) -ieq '.mkv') })
$skipped = @($files | Where-Object { [IO.Path]::GetExtension($_) -ine '.mkv' })

if ($skipped.Count -gt 0) {
    Write-Warn2 ("Skipping " + $skipped.Count + " non-MKV file(s).")
}
if ($mkvs.Count -eq 0) {
    Write-Err "No .mkv files were given. Drag MKV files onto the icon and try again."
    exit 1
}

Write-Host ""
Write-Host ("Found " + $mkvs.Count + " MKV file(s) to convert.") -ForegroundColor White

$ok = 0; $fail = 0
foreach ($m in $mkvs) {
    if (Convert-One $ffmpeg $m) { $ok++ } else { $fail++ }
}

Write-Host ""
Write-Host ("Finished: $ok converted, $fail failed.") -ForegroundColor White
if ($fail -gt 0) { exit 1 }
