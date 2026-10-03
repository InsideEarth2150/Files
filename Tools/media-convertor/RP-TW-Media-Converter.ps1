<#
.SYNOPSIS
    Video/audio converter for Reality Pump / TopWare games: TWV/TWS (KnightShift,
    World War III: Black Gold, Heli Heroes, Panzer Claws, ...) and Earth 2150 .wd1 videos.

.DESCRIPTION
    Files: RP-TW-Media-Converter.ps1 (this script), Reality_Pump___TopWare_-_Media_Converter.cmd
    (double-click / drag-and-drop launcher), README.md.
    Works in Windows PowerShell 5.1 and 7+.

    Run it without arguments for a menu that walks you through each task.

    Menu 1  game video -> video  .twv (+ .tws) or .wd1 -> raw original streams, or
                                 .mpg/.mkv/.mp4/.mov/.avi/.webm      (-Mode ToMp4)
    Menu 2  game sound -> audio  .tws or a .wd1 soundtrack -> raw, or
                                 wav/flac/mp3/m4a/ogg/opus/mp2       (-Mode TwsToAudio)
    Menu 3  video -> TWV/TWS     any video -> .twv + .tws            (-Mode ToTwv)
    Menu 4  audio -> TWS         any audio (or a soundtrack) -> .tws (-Mode AudioToTws)
    Menu 5  video -> WD1         any video -> Earth 2150 .wd1        (-Mode ToWd1)

    Defaults are the raw conversions - the original streams with their own settings:
      1: TWV -> .m1v + .mp2, WD1 -> the .avi / .mpg it really is; no ffmpeg needed
      2: TWS -> .mp2; WD1 -> its own audio track (.wav / .mp2), copied
      3: MPEG-1 I-frame video is put back into a TWV without re-encoding; MP2 is copied
      4: MP2 audio is copied into the TWS as is
      5: an AVI/MPG the game can play (Cinepak/Indeo AVI, MPEG-1 MPG) is copied in as is
    Anything that cannot be copied is encoded with the game's own settings:
      TWV 640x256, source fps, quantiser 1; TWS MP2 160k 44.1 kHz stereo;
      WD1: same format/size/fps/audio as the .wd1 being replaced, else MPEG-1 + MP2.

    What is native PowerShell (no dependencies):
      * reading / writing TWV, rewriting its MPEG-1 bitstream, repairing cut-off headers
      * reading AVI / MPEG headers of .wd1 files
      * -Info, and every raw conversion that does not change the container

    What needs ffmpeg: re-encoding, and reading/writing other containers. If ffmpeg is
    not found in PATH or .\tools, a verified build (BtbN, GitHub) is downloaded once.

    File formats (as reverse engineered):
      TWV : 20-byte big-endian header 'TWV\0', version, width, height, fps(16.16),
            followed by a stripped MPEG-1 video stream (I-frames only, no sequence
            header, 1-byte picture headers, slice headers without extra_bit_slice).
      TWS : a plain MPEG-1 Layer II (MP2) audio stream, normally 44.1 kHz stereo.
      WD1 : (Earth 2150 videos) a plain AVI (Cinepak or Indeo 5 + PCM) or MPEG-1
            system stream (MPEG-1 video + MP2) with another extension.

.EXAMPLE
    .\RP-TW-Media-Converter.ps1                                     # interactive menu
.EXAMPLE
    .\RP-TW-Media-Converter.ps1 -Mode ToMp4 .\Intro2.twv
.EXAMPLE
    .\RP-TW-Media-Converter.ps1 -Mode ToTwv .\MyIntro.mp4           # keeps source fps
.EXAMPLE
    .\RP-TW-Media-Converter.ps1 -Mode TwsToAudio .\Intro2.tws -AudioFormat mp3
.EXAMPLE
    .\RP-TW-Media-Converter.ps1 -Mode AudioToTws .\MyMusic.wav
.EXAMPLE
    .\RP-TW-Media-Converter.ps1 -Mode ToMp4 C:\Game\Video -OutputPath C:\Out
.EXAMPLE
    .\RP-TW-Media-Converter.ps1 .\Intro2.twv -Info
.EXAMPLE
    .\RP-TW-Media-Converter.ps1 .\VideoUCS.wd1                      # -> VideoUCS.avi (as is)
.EXAMPLE
    .\RP-TW-Media-Converter.ps1 -Mode ToWd1 .\New.mp4 -OutputPath C:\Earth2150\Video\VideoUCS.wd1
#>
[CmdletBinding()]
param(
    # Files or folders. Without any, an interactive menu is shown.
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$InputPath,

    # ToMp4 = 1, ToTwv = 2, TwsToAudio = 3, AudioToTws = 4, Auto = by file extension.
    # ToWd1 = 5 (video -> Earth 2150 .wd1)
    [ValidateSet('Auto', 'ToMp4', 'ToTwv', 'TwsToAudio', 'AudioToTws', 'ToWd1')]
    [string]$Mode = 'Auto',

    # Output folder, or an output file name (with extension) for a single input.
    [string]$OutputPath,

    # TWV->MP4: overrides the header fps.  MP4->TWV: target fps (default: source fps).
    [double]$Fps = 0,

    # --- game video -> video (option 1) ---
    # raw = original streams, no ffmpeg: TWV -> .m1v + .mp2, WD1 -> .avi / .mpg as is
    # ('m1v' is accepted as another name for raw)
    [ValidateSet('raw', 'm1v', 'mp4', 'mkv', 'mov', 'avi', 'webm', 'mpg')]
    [string]$Container = 'raw',
    # auto = copy (original MPEG-1, lossless) where the container allows it; webm -> vp9
    [ValidateSet('auto', 'h264', 'h265', 'vp9', 'av1', 'mpeg1', 'copy')]
    [string]$VideoCodec = 'auto',
    [ValidateRange(-1, 63)][int]$Crf = -1,    # quality, lower = better. -1 = codec default
                                              # (h264 16, h265 20, vp9 28, av1 30)
    [string]$Preset = 'slow',                 # x264/x265 preset (ultrafast..veryslow), AV1: 0-13
    [string]$VideoBitrate,                    # e.g. 4M - fixed bitrate instead of CRF
    [string]$OutSize,                         # e.g. 1280x512 - rescale the output
    # auto = copy (original MP2, lossless) where the container allows it; webm -> opus
    [ValidateSet('auto', 'aac', 'mp3', 'mp2', 'opus', 'vorbis', 'flac', 'pcm', 'copy')]
    [string]$AudioCodec = 'auto',
    [string]$Audio,                           # audio file (default: .tws next to .twv)
    [switch]$NoAudio,
    [switch]$M1v,                             # same as -Container m1v
    [switch]$Info,                            # only print TWV information

    # --- audio options shared by option 1 and option 3 ---
    [string]$AudioBitrate,                    # e.g. 192k (lossy codecs only)
    [ValidateSet(0, 22050, 32000, 44100, 48000)][int]$SampleRate = 0,   # 0 = keep
    [ValidateSet(0, 1, 2)][int]$Channels = 0,                           # 0 = keep

    # --- MP4 -> TWV ---
    [int]$Width = 640,                        # also used when repairing header-less TWVs
    [int]$Height = 256,
    [switch]$Stretch,                         # stretch instead of letterboxing
    [ValidateRange(1, 31)][int]$Q = 1,        # MPEG-1 quantiser, lower = better (originals: mostly 1)

    # --- TWS output (option 2 and option 4) ---
    [string]$TwsBitrate = '160k',             # MP2: 32k..384k (originals: 128k/160k)
    [ValidateSet(32000, 44100, 48000)][int]$TwsSampleRate = 44100,     # originals: 44100
    [ValidateSet(1, 2)][int]$TwsChannels = 2,                          # originals: stereo
    [switch]$NoTws,
    # options 2/4: always re-encode, even when the source streams could be copied as is
    [switch]$Reencode,

    # --- game audio -> audio (option 3) ---
    # raw = original stream copied as is: TWS -> .mp2, WD1 -> its own track (.wav / .mp2)
    [ValidateSet('raw', 'wav', 'flac', 'mp3', 'm4a', 'ogg', 'opus', 'mp2')]
    [string]$AudioFormat = 'raw',

    # --- video -> Earth 2150 .wd1 (option 5) ---
    # auto = same format as the .wd1 being replaced, else mpg. mpg = MPEG-1 + MP2,
    # avi = Cinepak + PCM (Indeo cannot be encoded)
    [ValidateSet('auto', 'mpg', 'avi')]
    [string]$Wd1Format = 'auto',

    # --- ffmpeg ---
    [string]$FfmpegPath,
    [switch]$NoDownload
)

$script:Bound = $PSBoundParameters
Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Numerics
Add-Type -AssemblyName System.IO.Compression
try { Add-Type -AssemblyName System.IO.Compression.FileSystem } catch { }

# ============================================================== constants

$script:Here = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$script:OnWindows = ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT)
$script:Latin1 = [Text.Encoding]::GetEncoding(28591)       # 1 byte <-> 1 char
$script:SCStr = [string][char]0 + [char]0 + [char]1        # MPEG start code prefix
$script:SC = [byte[]](0, 0, 1)
$script:Magic = [byte[]](0x54, 0x57, 0x56, 0x00)           # 'TWV\0'
$script:HdrLen = 20
$script:DefaultFps = 25.0
# MPEG-1 frame_rate_code -> fps (index = code; 0 is reserved)
$script:FpsCodes = @(0.0, (24000 / 1001), 24.0, 25.0, (30000 / 1001), 30.0, 50.0, (60000 / 1001), 60.0)
$script:VideoExt = @('.mp4', '.mkv', '.avi', '.mov', '.webm', '.m4v', '.mpg', '.mpeg',
                     '.m1v', '.wmv', '.flv', '.gif')
$script:AudioExt = @('.wav', '.mp3', '.mp2', '.ogg', '.oga', '.opus', '.flac', '.m4a', '.aac',
                     '.wma', '.aif', '.aiff', '.ac3')
$script:FfmpegExe = $null
$script:Mp2Rates = @(32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384)

# ============================================================== output helpers

function Write-Info([string]$m) { Write-Host "[i] $m" }
function Write-Ok([string]$m)   { Write-Host "[ok] $m" -ForegroundColor Green }
function Write-Warn2([string]$m){ Write-Host "[!] $m" -ForegroundColor Yellow }
function Write-Err([string]$m)  { Write-Host "[!] $m" -ForegroundColor Red }

# ============================================================== byte helpers

function Get-UInt32BE([byte[]]$d, [int]$o) {
    return ([uint64]$d[$o] -shl 24) -bor ([uint64]$d[$o + 1] -shl 16) -bor
           ([uint64]$d[$o + 2] -shl 8) -bor [uint64]$d[$o + 3]
}

function Get-BE32Bytes([uint64]$x) {
    $b = New-Object byte[] 4
    $b[0] = [byte](($x -shr 24) -band 0xFF); $b[1] = [byte](($x -shr 16) -band 0xFF)
    $b[2] = [byte](($x -shr 8) -band 0xFF);  $b[3] = [byte]($x -band 0xFF)
    return , $b
}

function Write-Bytes([IO.Stream]$s, [byte[]]$b) { $s.Write($b, 0, $b.Length) }

# Positions of every 00 00 01 from $Start, plus Length as sentinel.
# Done with an ordinal string search (native, fast) instead of a PowerShell byte loop.
function Get-StartCodes([byte[]]$Data, [int]$Start = 0) {
    $s = $script:Latin1.GetString($Data)
    $list = New-Object 'System.Collections.Generic.List[int]'
    $i = $s.IndexOf($script:SCStr, $Start, [StringComparison]::Ordinal)
    while ($i -ge 0) {
        $list.Add($i)
        $i = $s.IndexOf($script:SCStr, $i + 3, [StringComparison]::Ordinal)
    }
    $list.Add($Data.Length)
    return , $list
}

# zlib-wrapped files are inflated transparently (as in the Python version)
function Expand-MaybeZlib([byte[]]$d) {
    if ($d.Length -gt 2 -and $d[0] -eq 0x78 -and (@(0x01, 0x5E, 0x9C, 0xDA) -contains $d[1])) {
        try {
            $in = [IO.MemoryStream]::new($d, 2, $d.Length - 2)
            $z = New-Object IO.Compression.DeflateStream($in, [IO.Compression.CompressionMode]::Decompress)
            $out = New-Object IO.MemoryStream
            $z.CopyTo($out); $z.Dispose()
            return , $out.ToArray()
        } catch { }
    }
    return , $d
}

# --- slice bit surgery -------------------------------------------------------
# A slice body is treated as one big-endian integer v of n bits (native BigInteger,
# no per-byte PowerShell loop). With hiS = (v >> (n-5)) << (n-5) (= the 5-bit quantiser
# kept in place):
#   TWV -> MPEG-1  insert extra_bit_slice=0 after quantiser :  r = (v + hiS) << 7   (n+8 bits)
#   MPEG-1 -> TWV  remove extra_bit_slice (must be 0)        :  r = 2v - hiS         (n bits)
# Both are inlined in the conversion loops below for speed.
# (PowerShell's own + - * % operators are used: they are ~20x faster than calling
#  [BigInteger]::op_LeftShift etc. through PowerShell's method binder.)

function Get-Pow2([int]$k) {                    # 2^k without BigInteger::Pow
    $b = [byte[]]::new([int][Math]::Floor($k / 8) + 2)
    $b[[int][Math]::Floor($k / 8)] = [byte](1 -shl ($k % 8))
    return [System.Numerics.BigInteger]::new($b)
}

# Insert/remove helpers used by the loops. Fast path = PowerShell operators; if this
# PowerShell build does not apply them to BigInteger correctly, fall back to the
# (slower, always-correct) static methods. Decided once by a self-test.
$script:BigFast = $true
function Get-HiS($v, [int]$n) {
    if ($script:BigFast) { return $v - ($v % (Get-Pow2 ($n - 5))) }
    return [System.Numerics.BigInteger]::op_LeftShift([System.Numerics.BigInteger]::op_RightShift($v, $n - 5), $n - 5)
}
function Test-BigFast {
    try {
        $v = [System.Numerics.BigInteger]::new([byte[]](0x5A, 0xC3, 0xF1, 0x00))     # 0xF1C35A, 24 bits
        $hiS = $v - ($v % (Get-Pow2 19))
        $ins = (($v + $hiS) * 128); $rem = ($v + $v - $hiS)
        return ($hiS.ToString() -eq '15728640' -and $ins.ToString() -eq '4041321728' -and $rem.ToString() -eq '15959732')
    } catch { return $false }
}

# ============================================================== TWV header

function Test-Magic([byte[]]$d) {
    if ($d.Length -lt $script:HdrLen) { return $false }
    for ($i = 0; $i -lt 4; $i++) { if ($d[$i] -ne $script:Magic[$i]) { return $false } }
    return $true
}

# Returns Ver, W, H, Fps (0 = unknown), DataStart, Repaired, RawFps
function Read-TwvHeader([byte[]]$d) {
    if (Test-Magic $d) {
        $ver = Get-UInt32BE $d 4; $w = Get-UInt32BE $d 8; $h = Get-UInt32BE $d 12
        $raw = Get-UInt32BE $d 16
        if (-not (16 -le $w -and $w -le 4095 -and 16 -le $h -and $h -le 4095)) {
            throw "invalid dimensions in header: ${w}x${h}"
        }
        $fps = $raw / 65536.0
        if (-not (1 -le $fps -and $fps -le 120)) {
            if (1 -le $raw -and $raw -le 120) { $fps = [double]$raw } else { $fps = 0.0 }
        }
        return @{ Ver = $ver; W = [int]$w; H = [int]$h; Fps = $fps; RawFps = $raw
                  DataStart = $script:HdrLen; Repaired = $false }
    }

    # No 'TWV\0': check for a truncated file (header + start of first frame cut off,
    # seen in some World War III: Black Gold files). Rebuild it if the payload is a TWV stream.
    $pos = Get-StartCodes $d 0
    $first = -1; $maxSlice = 0; $pics = 0
    for ($k = 0; $k -lt $pos.Count - 1; $k++) {
        $p = $pos[$k]
        if ($p + 3 -ge $d.Length) { break }
        $c = $d[$p + 3]
        if ($c -eq 0) {
            $pics++
            if ($first -lt 0) { $first = $p }
            # TWV picture header is exactly 1 byte; real MPEG-1 has a longer one
            if ($pos[$k + 1] - $p -ne 5 -and $pics -lt 3) { $first = -2; break }
        } elseif ($c -ge 1 -and $c -le 0xAF) {
            if ($c -gt $maxSlice) { $maxSlice = $c }
        }
    }
    if ($first -lt 0 -or $pics -lt 1 -or $maxSlice -lt 1) {
        throw "no 'TWV\0' signature - not a TWV file"
    }
    return @{ Ver = 1; W = $Width; H = [int]($maxSlice * 16); Fps = 0.0; RawFps = 0
              DataStart = $first; Repaired = $true }
}

function Get-FpsCode([double]$fps) {
    $best = 3; $bd = 1e9
    for ($k = 1; $k -lt $script:FpsCodes.Count; $k++) {
        $dd = [Math]::Abs($script:FpsCodes[$k] - $fps)
        if ($dd -lt $bd) { $bd = $dd; $best = $k }
    }
    return $best
}

function Get-SeqHeader([int]$w, [int]$h, [double]$fps) {
    $code = Get-FpsCode $fps
    $w1 = ([uint64]$w -shl 20) -bor ([uint64]$h -shl 8) -bor (1 -shl 4) -bor $code   # aspect 1:1
    $w2 = ([uint64]0x3FFFF -shl 14) -bor (1 -shl 13) -bor (112 -shl 3)               # VBR, marker, vbv
    $ms = New-Object IO.MemoryStream
    Write-Bytes $ms $script:SC; $ms.WriteByte(0xB3)
    Write-Bytes $ms (Get-BE32Bytes $w1); Write-Bytes $ms (Get-BE32Bytes $w2)
    return , $ms.ToArray()
}

# ============================================================== TWV <-> MPEG-1

function Convert-TwvToM1v([byte[]]$d, $hdr, [double]$fps) {
    $fast = $script:BigFast
    $out = New-Object IO.MemoryStream
    $seq = Get-SeqHeader $hdr.W $hdr.H $fps
    Write-Bytes $out $seq
    $frames = 0
    $pos = Get-StartCodes $d $hdr.DataStart
    for ($k = 0; $k -lt $pos.Count - 1; $k++) {
        $a = $pos[$k]; $b = $pos[$k + 1]
        if ($b - $a -lt 4) { continue }
        $c = $d[$a + 3]
        if ($c -eq 0x00) {                                   # picture
            $ptype = 1
            if ($b - $a -gt 4) { $ptype = ($d[$a + 4] -shr 5) -band 7 }
            if ($frames -gt 0 -and ($frames % 1024) -eq 0) { Write-Bytes $out $seq }
            $ph = ([uint64]($frames % 1024) -shl 22) -bor ([uint64]$ptype -shl 19) -bor ([uint64]0xFFFF -shl 3)
            $out.Write($d, $a, 4)
            $out.WriteByte([byte](($ph -shr 24) -band 0xFF)); $out.WriteByte([byte](($ph -shr 16) -band 0xFF))
            $out.WriteByte([byte](($ph -shr 8) -band 0xFF));  $out.WriteByte([byte]($ph -band 0xFF))
            $frames++
        } elseif ($c -ge 0x01 -and $c -le 0xAF) {            # slice
            if ($frames -eq 0) { continue }                  # partial frame before first picture
            $len = $b - $a - 4; $n = $len * 8
            $le = [byte[]]::new($len + 1)
            [Array]::Copy($d, $a + 4, $le, 0, $len); [Array]::Reverse($le, 0, $len)
            $v = [System.Numerics.BigInteger]::new($le)
            if ($fast) { $hiS = $v - ($v % (Get-Pow2 ($n - 5))); $le = (($v + $hiS) * 128).ToByteArray() }
            else { $hiS = Get-HiS $v $n; $le = [System.Numerics.BigInteger]::op_LeftShift([System.Numerics.BigInteger]::Add($v, $hiS), 7).ToByteArray() }
            $body = [byte[]]::new($len + 1)
            [Array]::Copy($le, $body, [Math]::Min($len + 1, $le.Length)); [Array]::Reverse($body)
            $out.Write($d, $a, 4); $out.Write($body, 0, $body.Length)
        } elseif ($c -eq 0xB7) { break }
    }
    Write-Bytes $out $script:SC; $out.WriteByte(0xB7)
    return @{ Es = $out.ToArray(); Frames = $frames }
}

function Convert-M1vToTwv([byte[]]$es, [int]$w, [int]$h, [double]$fps) {
    $fast = $script:BigFast
    $out = New-Object IO.MemoryStream
    Write-Bytes $out $script:Magic
    Write-Bytes $out (Get-BE32Bytes 1); Write-Bytes $out (Get-BE32Bytes $w)
    Write-Bytes $out (Get-BE32Bytes $h); Write-Bytes $out (Get-BE32Bytes ([uint64][Math]::Round($fps * 65536)))
    $frames = 0
    $pos = Get-StartCodes $es 0
    for ($k = 0; $k -lt $pos.Count - 1; $k++) {
        $a = $pos[$k]; $b = $pos[$k + 1]
        if ($b - $a -lt 4) { continue }
        $c = $es[$a + 3]
        if ($c -eq 0x00) {                                   # picture
            $ptype = ($es[$a + 5] -shr 3) -band 7
            if ($ptype -ne 1) { throw "frame $frames is not an I-frame (type $ptype)" }
            $out.Write($es, $a, 4); $out.WriteByte([byte]($ptype -shl 5))
            $frames++
        } elseif ($c -ge 0x01 -and $c -le 0xAF) {            # slice
            if ($es[$a + 4] -band 0x04) { throw 'slice with extra_information_slice is not supported' }
            $len = $b - $a - 4; $n = $len * 8
            $le = [byte[]]::new($len + 1)
            [Array]::Copy($es, $a + 4, $le, 0, $len); [Array]::Reverse($le, 0, $len)
            $v = [System.Numerics.BigInteger]::new($le)
            if ($fast) { $hiS = $v - ($v % (Get-Pow2 ($n - 5))); $le = ($v + $v - $hiS).ToByteArray() }
            else { $hiS = Get-HiS $v $n; $le = [System.Numerics.BigInteger]::Subtract([System.Numerics.BigInteger]::Add($v, $v), $hiS).ToByteArray() }
            $body = [byte[]]::new($len)
            [Array]::Copy($le, $body, [Math]::Min($len, $le.Length)); [Array]::Reverse($body)
            # removing the bit leaves one all-zero padding byte at the end (the one added
            # by TWV -> MPEG-1). Dropping it is safe (the next start code begins with zeros)
            # and makes TWV -> M1V -> TWV reproduce the original file exactly.
            $n2 = $len
            if ($n2 -gt 1 -and $body[$n2 - 1] -eq 0) { $n2-- }
            $out.Write($es, $a, 4); $out.Write($body, 0, $n2)
        }
        # B3 (sequence), B8 (GOP), B2 (user data), B5 (extension) are dropped
    }
    Write-Bytes $out $script:SC; $out.WriteByte(0xB7)
    return @{ Twv = $out.ToArray(); Frames = $frames }
}

# Can an MPEG-1 elementary stream be put into a TWV without re-encoding?
# Needs: MPEG-1 (no extensions), I-frames only, default intra matrix, width/height
# multiples of 16, one slice per macroblock row, no extra slice information.
function Test-TwvCopyable([byte[]]$es) {
    $r = @{ Ok = $false; Reason = ''; W = 0; H = 0; Fps = 0.0 }
    $pos = Get-StartCodes $es 0
    $rows = 0; $expect = 0; $pics = 0
    for ($k = 0; $k -lt $pos.Count - 1; $k++) {
        $a = $pos[$k]; $b = $pos[$k + 1]
        if ($b - $a -lt 4) { continue }
        $c = $es[$a + 3]
        if ($c -eq 0xB3) {                                   # sequence header
            if ($b - $a -lt 12) { $r.Reason = 'short sequence header'; return $r }
            $w = ([int]$es[$a + 4] -shl 4) -bor ($es[$a + 5] -shr 4)
            $h = (([int]$es[$a + 5] -band 0xF) -shl 8) -bor $es[$a + 6]
            $frc = $es[$a + 7] -band 0xF
            if (($es[$a + 11] -shr 1) -band 1) { $r.Reason = 'custom quantiser matrix'; return $r }
            if ($frc -lt 1 -or $frc -gt 8) { $r.Reason = 'unknown frame rate'; return $r }
            if (($w % 16) -or ($h % 16)) { $r.Reason = "size ${w}x${h} is not a multiple of 16"; return $r }
            if ($r.W -and ($r.W -ne $w -or $r.H -ne $h)) { $r.Reason = 'size changes mid-stream'; return $r }
            $r.W = $w; $r.H = $h; $r.Fps = $script:FpsCodes[$frc]; $rows = $h / 16
        } elseif ($c -eq 0xB5) { $r.Reason = 'MPEG-2 stream'; return $r }
        elseif ($c -eq 0x00) {                               # picture
            if (-not $rows) { $r.Reason = 'no sequence header'; return $r }
            if ($pics -gt 0 -and $expect -ne $rows) { $r.Reason = "frame $($pics - 1) has $expect slices, needs $rows (one per row)"; return $r }
            if ((($es[$a + 5] -shr 3) -band 7) -ne 1) { $r.Reason = 'not all frames are I-frames'; return $r }
            $pics++; $expect = 0
        } elseif ($c -ge 0x01 -and $c -le 0xAF) {            # slice
            $expect++
            if ($c -ne $expect) { $r.Reason = "frame $($pics - 1): slices are not one per row"; return $r }
            if ($es[$a + 4] -band 0x04) { $r.Reason = 'extra slice information'; return $r }
        }
    }
    if ($pics -eq 0) { $r.Reason = 'no frames'; return $r }
    if ($expect -ne $rows) { $r.Reason = 'last frame is incomplete'; return $r }
    $r.Ok = $true
    return $r
}

# ============================================================== TWS (MP2) helpers

# Duration of a CBR MPEG-1 Layer II stream, from its first frame header. 0 if unknown.
function Get-Mp2Duration([string]$path) {
    try {
        $fs = [IO.File]::OpenRead($path)
        $hb = New-Object byte[] 4; [void]$fs.Read($hb, 0, 4); $len = $fs.Length; $fs.Dispose()
        if ($hb[0] -ne 0xFF -or ($hb[1] -band 0xF0) -ne 0xF0) { return 0 }
        $rates = @(0, 32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384, 0)
        $kbps = $rates[($hb[2] -shr 4) -band 0xF]
        if ($kbps -le 0) { return 0 }
        return ($len * 8.0) / ($kbps * 1000.0)
    } catch { return 0 }
}

function Find-Sibling([string]$path, [string]$ext) {
    foreach ($e in @($ext.ToLower(), $ext.ToUpper())) {
        $p = [IO.Path]::ChangeExtension($path, $e)
        if (Test-Path -LiteralPath $p -PathType Leaf) { return $p }
    }
    return $null
}

# ============================================================== ffmpeg

function ConvertTo-ArgString([string[]]$list) {
    $parts = foreach ($a in $list) {
        if ($a.Length -gt 0 -and $a -notmatch '[\s"]') { $a }
        else {
            $s = $a -replace '(\\*)"', '$1$1\"'
            $s = $s -replace '(\\+)$', '$1$1'
            '"' + $s + '"'
        }
    }
    return ($parts -join ' ')
}

function Invoke-Ffmpeg([string[]]$FfArgs) {
    $psi = New-Object Diagnostics.ProcessStartInfo
    $psi.FileName = $script:FfmpegExe
    $psi.Arguments = ConvertTo-ArgString (@('-nostdin', '-y', '-hide_banner', '-loglevel', 'error') + $FfArgs)
    $psi.UseShellExecute = $false
    $psi.RedirectStandardError = $true
    $psi.StandardErrorEncoding = [Text.Encoding]::UTF8
    $psi.CreateNoWindow = $true
    $p = [Diagnostics.Process]::Start($psi)
    $err = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    return @{ Code = $p.ExitCode; Err = $err }
}

# Stream info from "ffmpeg -i" output (no ffprobe needed):
#   VCodec, W, H, Fps, ACodec, ARate, ACh   (missing values are '' / 0)
function Get-MediaInfo([string]$path) {
    $info = @{ VCodec = ''; W = 0; H = 0; Fps = 0.0; ACodec = ''; ARate = 0; ACh = 0; AKbps = 0 }
    $psi = New-Object Diagnostics.ProcessStartInfo
    $psi.FileName = $script:FfmpegExe
    $psi.Arguments = ConvertTo-ArgString @('-nostdin', '-hide_banner', '-i', $path)
    $psi.UseShellExecute = $false; $psi.RedirectStandardError = $true; $psi.CreateNoWindow = $true
    $psi.StandardErrorEncoding = [Text.Encoding]::UTF8
    $p = [Diagnostics.Process]::Start($psi)
    $err = $p.StandardError.ReadToEnd(); $p.WaitForExit()
    $inv = [Globalization.CultureInfo]::InvariantCulture
    foreach ($line in ($err -split "`n")) {
        if (-not $info.VCodec -and $line -match 'Stream #.*Video: (\w+)') {
            $info.VCodec = $Matches[1]
            if ($line -match '[ ,](\d{2,5})x(\d{2,5})[ ,\[]') { $info.W = [int]$Matches[1]; $info.H = [int]$Matches[2] }
            if ($line -match '[ ,](\d+(?:\.\d+)?) fps') { $info.Fps = [double]::Parse($Matches[1], $inv) }
            elseif ($line -match '[ ,](\d+(?:\.\d+)?) tbr') { $info.Fps = [double]::Parse($Matches[1], $inv) }
        }
        if (-not $info.ACodec -and $line -match 'Stream #.*Audio: (\w+)') {
            $info.ACodec = $Matches[1]
            if ($line -match ', (\d+) Hz') { $info.ARate = [int]$Matches[1] }
            if ($line -match ', stereo') { $info.ACh = 2 } elseif ($line -match ', mono') { $info.ACh = 1 }
            elseif ($line -match ', (\d+) channels') { $info.ACh = [int]$Matches[1] }
            if ($line -match ', (\d+) kb/s') { $info.AKbps = [int]$Matches[1] }
        }
    }
    return $info
}

function Get-SourceFps([string]$path) { return (Get-MediaInfo $path).Fps }

# Native check of an MPEG-1 Layer II file (.mp2/.tws). Returns $null if it is not one.
function Get-Mp2Header([string]$path) {
    try {
        $fs = [IO.File]::OpenRead($path)
        $hb = [byte[]]::new(4); [void]$fs.Read($hb, 0, 4); $fs.Dispose()
    } catch { return $null }
    if ($hb[0] -ne 0xFF -or ($hb[1] -band 0xFE) -ne 0xFC) { return $null }   # sync + MPEG-1 + Layer II
    $kbps = $script:Mp2Rates[((($hb[2] -shr 4) -band 0xF) - 1)]
    $rate = @(44100, 48000, 32000, 0)[($hb[2] -shr 2) -band 3]
    if (((($hb[2] -shr 4) -band 0xF) -eq 0) -or (($hb[2] -shr 4) -band 0xF) -eq 15 -or $rate -eq 0) { return $null }
    $ch = if ((($hb[3] -shr 6) -band 3) -eq 3) { 1 } else { 2 }
    return @{ Kbps = $kbps; Rate = $rate; Ch = $ch; Duration = (Get-Mp2Duration $path) }
}

function Get-ToolsDir {
    $d = Join-Path $script:Here 'tools'
    try {
        if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d | Out-Null }
        $t = Join-Path $d '.write-test'; [IO.File]::WriteAllText($t, 'x'); Remove-Item -LiteralPath $t -Force
        return $d
    } catch {
        $base = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { [IO.Path]::GetTempPath() }
        $d = Join-Path (Join-Path $base 'RP-TW-Media-Converter') 'tools'
        if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
        return $d
    }
}

function Install-Ffmpeg {
    if (-not $script:OnWindows) {
        throw 'ffmpeg not found. Install it with your package manager (e.g. "sudo apt install ffmpeg" or "brew install ffmpeg").'
    }
    $plat = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'winarm64' } else { 'win64' }
    $name = "ffmpeg-master-latest-$plat-gpl-shared.zip"
    $base = 'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest'
    $tools = Get-ToolsDir
    $zip = Join-Path ([IO.Path]::GetTempPath()) $name

    Write-Info "ffmpeg not found - downloading $name (~85 MB, one time only)..."
    Write-Info "  from $base"
    Write-Info "  into $tools"
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $oldPP = $ProgressPreference; $ProgressPreference = 'SilentlyContinue'   # huge speed-up on PS 5.1
    try {
        Invoke-WebRequest -Uri "$base/$name" -OutFile $zip -UseBasicParsing
        $sums = (Invoke-WebRequest -Uri "$base/checksums.sha256" -UseBasicParsing).Content
        if ($sums -is [byte[]]) { $sums = [Text.Encoding]::ASCII.GetString($sums) }
    } finally { $ProgressPreference = $oldPP }

    $expected = $null
    foreach ($line in ($sums -split "`n")) {
        $f = $line.Trim() -split '\s+'
        if ($f.Count -ge 2 -and $f[1] -eq $name) { $expected = $f[0].ToLower() }
    }
    $actual = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLower()
    if (-not $expected) { Remove-Item -LiteralPath $zip; throw 'could not find a checksum for the ffmpeg download' }
    if ($expected -ne $actual) {
        Remove-Item -LiteralPath $zip
        throw 'ffmpeg download failed SHA-256 verification (the build may have just been updated - try again)'
    }
    Write-Info 'checksum OK, unpacking...'

    # Extract only bin\ffmpeg.exe and its DLLs
    $za = [IO.Compression.ZipFile]::OpenRead($zip)
    try {
        foreach ($e in $za.Entries) {
            if ($e.FullName -match '/bin/([^/]+\.(exe|dll))$' -and $Matches[1] -notmatch '^(ffplay|ffprobe)\.exe$') {
                [IO.Compression.ZipFileExtensions]::ExtractToFile($e, (Join-Path $tools $Matches[1]), $true)
            }
        }
    } finally { $za.Dispose() }
    Remove-Item -LiteralPath $zip -ErrorAction SilentlyContinue

    $exe = Join-Path $tools 'ffmpeg.exe'
    if (-not (Test-Path -LiteralPath $exe)) { throw 'ffmpeg.exe was not found in the downloaded archive' }
    Write-Ok "ffmpeg installed: $exe"
    return $exe
}

function Initialize-Ffmpeg {
    if ($script:FfmpegExe) { return }
    $cands = @()
    if ($FfmpegPath) { $cands += $FfmpegPath }
    $cands += (Join-Path (Join-Path $script:Here 'tools') 'ffmpeg.exe')
    if ($env:LOCALAPPDATA) {
        $cands += (Join-Path $env:LOCALAPPDATA 'RP-TW-Media-Converter\tools\ffmpeg.exe')
        $cands += (Join-Path $env:LOCALAPPDATA 'TWV-Converter\tools\ffmpeg.exe')      # older versions
    }
    foreach ($c in $cands) {
        if ($c -and (Test-Path -LiteralPath $c -PathType Leaf)) { $script:FfmpegExe = (Resolve-Path -LiteralPath $c).Path; return }
    }
    $cmd = Get-Command ffmpeg -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd) { $script:FfmpegExe = $cmd.Source; if (-not $script:FfmpegExe) { $script:FfmpegExe = $cmd.Path }; return }
    if ($FfmpegPath) { throw "ffmpeg not found at $FfmpegPath" }
    if ($NoDownload) { throw 'ffmpeg not found (and -NoDownload was given)' }
    $script:FfmpegExe = Install-Ffmpeg
}

# Before overwriting a .twv/.tws/.wd1 (likely an original game file), keep one backup copy.
function Backup-IfExists([string]$path) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return }
    $bak = $path + '.bak'
    if (Test-Path -LiteralPath $bak) { return }        # first original already backed up
    Copy-Item -LiteralPath $path -Destination $bak
    Write-Info "existing file backed up: $bak"
}

function New-TempFile([string]$ext) {
    return (Join-Path ([IO.Path]::GetTempPath()) ("twv_" + [guid]::NewGuid().ToString('N') + $ext))
}

# ============================================================== settings

function Get-KbpsValue([string]$b) {                # '160k' / '160' -> 160 ; '' -> 0
    if (-not $b) { return 0 }
    if ($b -match '^\s*(\d+)\s*[kK]?\s*$') { return [int]$Matches[1] }
    throw "invalid bitrate '$b' (use e.g. 160k)"
}

# MPEG-1 Layer II only allows some bitrates per channel mode
function Test-Mp2Combo([int]$k, [int]$ch, [string]$what) {
    if ($ch -eq 2 -and @(32, 48, 56, 80) -contains $k) { throw "$what ${k}k is not allowed for stereo MP2 (stereo: 64k-384k, not 80k)" }
    if ($ch -eq 1 -and $k -gt 192) { throw "$what ${k}k is not allowed for mono MP2 (mono: 32k-192k)" }
}

# Fill in 'auto' values and reject combinations that cannot work. Runs once, before any file.
function Resolve-Settings {
    if ($M1v -or $Container -eq 'm1v') { $script:Container = 'raw' }
    $c = $Container
    if ($VideoCodec -eq 'auto') {
        $script:VideoCodec = if ($c -eq 'webm') { 'vp9' } else { 'copy' }
    }
    if ($AudioCodec -eq 'auto') {
        $script:AudioCodec = if ($c -eq 'webm') { 'opus' } else { 'copy' }
    }
    $v = $VideoCodec; $a = $AudioCodec
    $allowV = @{ webm = @('vp9', 'av1'); mpg = @('copy', 'mpeg1'); raw = @('copy')
                 mp4 = @('copy', 'h264', 'h265', 'av1', 'mpeg1'); mov = @('copy', 'h264', 'h265', 'mpeg1')
                 avi = @('copy', 'h264', 'mpeg1'); mkv = @('copy', 'h264', 'h265', 'vp9', 'av1', 'mpeg1') }
    $allowA = @{ webm = @('opus', 'vorbis'); mpg = @('copy', 'mp2', 'mp3'); raw = @('copy')
                 mp4 = @('copy', 'aac', 'mp3', 'mp2', 'opus', 'flac'); mov = @('copy', 'aac', 'mp3', 'mp2', 'pcm')
                 avi = @('copy', 'mp3', 'mp2', 'aac', 'pcm'); mkv = @('copy', 'aac', 'mp3', 'mp2', 'opus', 'vorbis', 'flac', 'pcm') }
    if ($allowV[$c] -notcontains $v) { throw "video codec '$v' is not available for .$c (use: $($allowV[$c] -join ', '))" }
    if ($allowA[$c] -notcontains $a) { throw "audio codec '$a' is not available for .$c (use: $($allowA[$c] -join ', '))" }
    if ($v -eq 'copy' -and ($OutSize -or $VideoBitrate)) { throw '-OutSize / -VideoBitrate need a re-encode: pick -VideoCodec h264/h265/vp9/av1/mpeg1' }
    if ($OutSize -and $OutSize -notmatch '^\d+x\d+$') { throw "invalid -OutSize '$OutSize' (use e.g. 1280x512)" }
    $script:CrfAuto = ($Crf -lt 0)
    if (-not $script:CrfAuto -and ($v -eq 'h264' -or $v -eq 'h265') -and $Crf -gt 51) { throw "-Crf for $v must be 0-51" }
    if (-not (Test-Path variable:script:MenuSet)) { $script:MenuSet = @{} }

    # options 2/4: copy compatible streams unless told otherwise (menus may already have set these)
    $vKeys = @('Width', 'Height', 'Q', 'Stretch', 'Fps')
    $aKeys = @('TwsBitrate', 'TwsSampleRate', 'TwsChannels')
    if (-not (Test-Path variable:script:ForceVideoEncode)) {
        $script:ForceVideoEncode = [bool]$Reencode -or [bool]($vKeys | Where-Object { $script:Bound.ContainsKey($_) })
    }
    if (-not (Test-Path variable:script:ForceAudioEncode)) {
        $script:ForceAudioEncode = [bool]$Reencode -or [bool]($aKeys | Where-Object { $script:Bound.ContainsKey($_) })
    }

    $tk = Get-KbpsValue $TwsBitrate
    if ($script:Mp2Rates -notcontains $tk) { throw "-TwsBitrate $TwsBitrate is not an MP2 bitrate (use: $(($script:Mp2Rates | ForEach-Object { "${_}k" }) -join ', '))" }
    $script:TwsBitrate = "${tk}k"
    Test-Mp2Combo $tk $TwsChannels '-TwsBitrate'
    if ($AudioFormat -eq 'mp2' -and $AudioBitrate) {
        $ch = if ($Channels -gt 0) { $Channels } else { 2 }
        Test-Mp2Combo (Get-KbpsValue $AudioBitrate) $ch '-AudioBitrate'
    }
    if ($AudioBitrate) { $script:AudioBitrate = "$(Get-KbpsValue $AudioBitrate)k" }
    if ($AudioFormat -eq 'mp2' -and $AudioBitrate -and $script:Mp2Rates -notcontains (Get-KbpsValue $AudioBitrate)) {
        throw "-AudioBitrate $AudioBitrate is not an MP2 bitrate"
    }
}

function Get-CrfFor([string]$codec) {
    if (-not $script:CrfAuto) { return $Crf }
    switch ($codec) { 'h264' { 16 } 'h265' { 20 } 'vp9' { 28 } 'av1' { 30 } 'mpeg1' { 2 } default { 16 } }
}

# ffmpeg video encoder args. $srcFps is used to give MPEG-1 an allowed frame rate.
function Get-VideoArgs([string]$codec, [double]$srcFps) {
    $out = @()
    $crf = Get-CrfFor $codec
    switch ($codec) {
        'copy'  { return @('-c:v', 'copy') }
        'h264'  { $out += @('-c:v', 'libx264', '-preset', $Preset) }
        'h265'  { $out += @('-c:v', 'libx265', '-preset', $Preset, '-x265-params', 'log-level=error')
                  if ($Container -eq 'mp4' -or $Container -eq 'mov') { $out += @('-tag:v', 'hvc1') } }
        'vp9'   { $out += @('-c:v', 'libvpx-vp9', '-row-mt', '1', '-deadline', 'good', '-cpu-used', '2') }
        'av1'   { $p = if ($Preset -match '^\d+$') { $Preset } else { '6' }
                  $out += @('-c:v', 'libsvtav1', '-preset', $p) }
        'mpeg1' { $out += @('-c:v', 'mpeg1video', '-g', '15', '-bf', '2')
                  $f = if ($srcFps -gt 0) { $script:FpsCodes[(Get-FpsCode $srcFps)] } else { 25.0 }
                  $out += @('-r', $f.ToString('0.######', [Globalization.CultureInfo]::InvariantCulture)) }
    }
    if ($VideoBitrate) { $out += @('-b:v', $VideoBitrate) }
    elseif ($codec -eq 'mpeg1') { $out += @('-q:v', "$([Math]::Max(1, [Math]::Min(31, $crf)))") }
    else {
        $out += @('-crf', "$crf")
        if ($codec -eq 'vp9') { $out += @('-b:v', '0') }
    }
    if ($OutSize) { $wh = $OutSize -split 'x'; $out += @('-vf', "scale=$($wh[0]):$($wh[1]):flags=lanczos") }
    $out += @('-pix_fmt', 'yuv420p')
    return $out
}

# codec name -> ffmpeg args, with a default bitrate for lossy codecs
function Get-AudioCodecArgs([string]$codec, [string]$defaultBitrate) {
    $br = if ($AudioBitrate) { $AudioBitrate } else { $defaultBitrate }
    $a = switch ($codec) {
        'aac'    { @('-c:a', 'aac', '-b:a', $br) }
        'mp3'    { @('-c:a', 'libmp3lame', '-b:a', $br) }
        'opus'   { @('-c:a', 'libopus', '-b:a', $br) }
        'vorbis' { @('-c:a', 'libvorbis', '-b:a', $br) }
        'mp2'    { @('-c:a', 'mp2', '-b:a', $br) }
        'flac'   { @('-c:a', 'flac') }
        'pcm'    { @('-c:a', 'pcm_s16le') }
        'copy'   { return @('-c:a', 'copy') }
    }
    return ($a + (Get-RateArgs))
}

function Get-RateArgs {
    $a = @()
    if ($SampleRate -gt 0) { $a += @('-ar', "$SampleRate") }
    if ($Channels -gt 0) { $a += @('-ac', "$Channels") }
    return $a
}

function Get-TwsSummary {
    $e = "MP2 $TwsBitrate $TwsSampleRate Hz $TwsChannels ch"
    if ($script:ForceAudioEncode) { return ".tws re-encoded $e" }
    return ".tws: copy MP2 audio as is when possible (else encode $e)"
}

function Get-SettingsSummary([string]$mode) {
    switch ($mode) {
        'ToMp4' {
            if ($Container -eq 'raw') { return 'raw original streams (TWV -> .m1v + .mp2, WD1 -> .avi/.mpg as is, no ffmpeg)' }
            $vq = if ($VideoCodec -eq 'copy') { 'original stream (re-encoded only where the container cannot hold it)' }
                  elseif ($VideoBitrate) { "$VideoCodec $VideoBitrate" } else { "$VideoCodec quality $(Get-CrfFor $VideoCodec)" }
            if ($OutSize) { $vq += " @ $OutSize" }
            $ab = if (@('copy', 'flac', 'pcm') -contains $AudioCodec) { '' } elseif ($AudioBitrate) { " $AudioBitrate" } else { ' (default bitrate)' }
            $aq = if ($AudioCodec -eq 'copy') { 'original stream' } else { "$AudioCodec$ab" }
            return ".$Container : video $vq, audio $aq"
        }
        'ToTwv' { $f = if ($Fps -gt 0) { "$Fps fps" } else { 'source fps' }
                  $v = if ($script:ForceVideoEncode) { ".twv re-encoded ${Width}x${Height}, $f, Q $Q" }
                       else { ".twv: copy MPEG-1 video as is when possible (else encode ${Width}x${Height}, $f, Q $Q)" }
                  $t = if ($NoTws) { 'no .tws' } else { Get-TwsSummary }
                  return "$v; $t" }
        'TwsToAudio' {
            if ($AudioFormat -eq 'raw' -and -not ($AudioBitrate -or $SampleRate -or $Channels)) { return 'raw original audio (TWS -> .mp2, WD1 -> .wav/.mp2), copied' }
            $b = if ($AudioBitrate) { " $AudioBitrate" } elseif ($AudioFormat -eq 'mp2') { ' (copied if the source is MP2)' }
                 elseif (@('wav', 'flac') -contains $AudioFormat) { ' (lossless)' } else { ' (default quality)' }
            $r = ''; if ($SampleRate -gt 0) { $r += " $SampleRate Hz" }; if ($Channels -gt 0) { $r += " $Channels ch" }
            return ".$AudioFormat$b$r" }
        'AudioToTws' { return (Get-TwsSummary) }
        'ToWd1' {
            $e = if ($Wd1Format -eq 'auto') { 'same format as the .wd1 being replaced, else MPEG-1' } elseif ($Wd1Format -eq 'mpg') { 'MPEG-1 + MP2' } else { 'AVI Cinepak + PCM' }
            if ($script:ForceVideoEncode) { return ".wd1 re-encoded: $e" }
            return ".wd1: copy AVI/MPG as is when the game can play it (else encode: $e)"
        }
    }
}

# ============================================================== conversions

function Convert-ToMp4([string]$path, [string]$out) {
    if ([IO.Path]::GetExtension($path).ToLower() -eq '.wd1') { return (Convert-Wd1ToVideo $path $out) }
    $data = Expand-MaybeZlib ([IO.File]::ReadAllBytes($path))
    $hdr = Read-TwvHeader $data

    $tws = $null
    if (-not $NoAudio) {
        if ($Audio) { $tws = $Audio } else { $tws = Find-Sibling $path '.tws' }
    }

    # resolve fps: -Fps > header > (repaired files) estimate from TWS length > 25
    $fps = $hdr.Fps; $fpsNote = $null
    if ($Fps -gt 0) { $fps = $Fps }
    elseif (-not $fps) {
        $fps = $script:DefaultFps; $fpsNote = "header has no fps - assumed $fps (override with -Fps)"
        if ($hdr.Repaired -and $tws) {
            $dur = Get-Mp2Duration $tws
            if ($dur -gt 0) {
                $tmp = Convert-TwvToM1v $data $hdr $fps
                $est = $tmp.Frames / $dur
                $fps = $script:FpsCodes[(Get-FpsCode $est)]
                $fpsNote = ('fps estimated from {0} length: {1:0.##} -> {2:0.###} (override with -Fps)' -f [IO.Path]::GetFileName($tws), $est, $fps)
            }
        }
    }

    $r = Convert-TwvToM1v $data $hdr $fps
    if ($hdr.Repaired) { Write-Warn2 "${path}: header missing (truncated file) - rebuilt as $($hdr.W)x$($hdr.H), partial first frame dropped (wrong picture? try -Width)" }
    if ($fpsNote) { Write-Info "${path}: $fpsNote" }
    if ($r.Frames -eq 0) { Write-Err "${path}: file contains no frames"; return $false }
    Write-Info ('{0}: TWV v{1}, {2}x{3}, {4:0.###} fps, {5} frames ({6:0.0} s)' -f $path, $hdr.Ver, $hdr.W, $hdr.H, $fps, $r.Frames, ($r.Frames / $fps))
    if ($tws) {
        $d = Get-Mp2Duration $tws
        if ($d -gt 0) { Write-Info ('{0}: MP2 audio, {1:0.0} s' -f [IO.Path]::GetFileName($tws), $d) }
    }
    if ($Info) { return $true }

    if ($Container -eq 'raw') {                         # fully native path
        $o = [IO.Path]::ChangeExtension($out, '.m1v')
        [IO.File]::WriteAllBytes($o, $r.Es)
        Write-Ok $o
        if ($tws) {
            $oa = [IO.Path]::ChangeExtension($out, '.mp2')
            Copy-Item -LiteralPath $tws -Destination $oa -Force
            Write-Ok "$oa (TWS audio is already MP2 - copied as is)"
        }
        return $true
    }

    Initialize-Ffmpeg
    $tmp = New-TempFile '.m1v'
    [IO.File]::WriteAllBytes($tmp, $r.Es)
    $fpsStr = $fps.ToString('0.######', [Globalization.CultureInfo]::InvariantCulture)
    try {
        $vargs = Get-VideoArgs $VideoCodec $fps
        $aargs = Get-AudioCodecArgs $AudioCodec $(if ($AudioCodec -eq 'opus') { '160k' } else { '192k' })
        $run = {
            param($aud)
            $a = @('-fflags', '+genpts', '-f', 'mpegvideo', '-framerate', $fpsStr, '-i', $tmp)
            if ($aud) { $a += @('-i', $aud, '-map', '0:v:0', '-map', '1:a:0') + $aargs }
            $a += $vargs
            if ($Container -eq 'mp4' -or $Container -eq 'mov') { $a += @('-movflags', '+faststart') }
            $a += @($out)
            Invoke-Ffmpeg $a
        }
        $res = & $run $tws
        if ($res.Code -ne 0 -and $tws -and -not $Audio) {
            Write-Info "ffmpeg could not read $([IO.Path]::GetFileName($tws)) - exporting without sound"
            $tws = $null
            $res = & $run $null
        }
        if ($res.Code -ne 0) {
            Write-Host $res.Err
            Write-Err "ffmpeg failed for $path"
            return $false
        }
    } finally { Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue }
    $suffix = if ($tws) { '' } else { ' (no sound)' }
    Write-Ok "$out$suffix"
    return $true
}

function Get-TwvFps([string]$path) {
    if ($Fps -gt 0) {
        foreach ($v in ($script:FpsCodes | Select-Object -Skip 1)) { if ([Math]::Abs($Fps - $v) -lt 0.01) { return $Fps } }
        throw "fps $Fps is not allowed in MPEG-1 (allowed: 23.976, 24, 25, 29.97, 30, 50, 59.94, 60)"
    }
    # keep the source frame rate, snapped to the nearest rate MPEG-1 can store
    $src = Get-SourceFps $path
    if ($src -gt 0) {
        $fps = $script:FpsCodes[(Get-FpsCode $src)]
        if ([Math]::Abs($fps - $src) -lt 0.01) { Write-Info ('{0}: source {1:0.###} fps - kept' -f $path, $src) }
        else { Write-Info ('{0}: source {1:0.###} fps is not allowed in MPEG-1 - using nearest {2:0.###} fps (override with -Fps)' -f $path, $src, $fps) }
        return $fps
    }
    Write-Info "${path}: could not read source fps - using $($script:DefaultFps) (override with -Fps)"
    return $script:DefaultFps
}

function Get-EncodedM1v([string]$path, [int]$w, [int]$h, [double]$fps) {
    if ($Stretch) { $vf = "scale=${w}:${h}" }
    else { $vf = "scale=${w}:${h}:force_original_aspect_ratio=decrease,pad=${w}:${h}:(ow-iw)/2:(oh-ih)/2:black" }
    $vf += ',setsar=1'
    $fpsStr = $fps.ToString('0.######', [Globalization.CultureInfo]::InvariantCulture)
    $tmp = New-TempFile '.m1v'
    try {
        $res = Invoke-Ffmpeg @('-i', $path, '-an', '-vf', $vf, '-r', $fpsStr,
            '-c:v', 'mpeg1video', '-g', '1', '-bf', '0',
            '-qscale:v', "$Q", '-qmin', '1', '-qmax', "$([Math]::Max($Q, 31))",
            '-slices', "$($h / 16)", '-f', 'mpeg1video', $tmp)
        if ($res.Code -ne 0) { Write-Host $res.Err; throw "ffmpeg failed for $path" }
        return , ([IO.File]::ReadAllBytes($tmp))
    } finally { Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue }
}

function Convert-ToTwv([string]$path, [string]$out) {
    $w = $Width; $h = $Height
    if (($w % 16) -or ($h % 16)) { Write-Err 'width and height must be multiples of 16'; return $false }
    $ext = [IO.Path]::GetExtension($path).ToLower()
    $isEs = @('.m1v', '.mpv') -contains $ext

    # 1) raw path: copy an MPEG-1 I-frame stream straight into the TWV
    $es = $null; $how = 're-encoded'
    if (-not $script:ForceVideoEncode) {
        if ($isEs) { $es = [IO.File]::ReadAllBytes($path) }        # native, no ffmpeg
        else {
            Initialize-Ffmpeg
            $vc = (Get-MediaInfo $path).VCodec
            if ($vc -and $vc -ne 'mpeg1video') { Write-Info "${path}: source video is $vc, not MPEG-1 - encoding with the game's settings" }
            if ($vc -eq 'mpeg1video') {
                $tmp = New-TempFile '.m1v'
                try {
                    $res = Invoke-Ffmpeg @('-i', $path, '-map', '0:v:0', '-c:v', 'copy', '-f', 'mpeg1video', $tmp)
                    if ($res.Code -eq 0) { $es = [IO.File]::ReadAllBytes($tmp) }
                } finally { Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue }
            }
        }
        if ($es) {
            $chk = Test-TwvCopyable $es
            if ($chk.Ok) {
                $w = $chk.W; $h = $chk.H; $fps = $chk.Fps; $how = 'video copied as is (lossless)'
                if ($w -ne 640 -or $h -ne 256) { Write-Warn2 "${path}: stream is ${w}x${h} - game intros are 640x256 (use -Reencode to resize)" }
            } else {
                Write-Info "${path}: video can't be copied into a TWV ($($chk.Reason)) - re-encoding"
                $es = $null
            }
        }
    }
    # 2) encode path
    if (-not $es) {
        Initialize-Ffmpeg
        try { $fps = Get-TwvFps $path } catch { Write-Err $_.Exception.Message; return $false }
        $es = Get-EncodedM1v $path $w $h $fps
    }

    $t = Convert-M1vToTwv $es $w $h $fps
    # self-check: the TWV must read back to the same number of frames
    $back = Convert-TwvToM1v $t.Twv (Read-TwvHeader $t.Twv) $fps
    if ($back.Frames -ne $t.Frames) { Write-Err "${path}: consistency check failed"; return $false }

    Backup-IfExists $out
    [IO.File]::WriteAllBytes($out, $t.Twv)
    Write-Ok ('{0}: {1}x{2} @ {3:0.###} fps, {4} frames ({5:0.0} s), {6:0.0} MB, {7}' -f $out, $w, $h, $fps, $t.Frames, ($t.Frames / $fps), ($t.Twv.Length / 1e6), $how)

    if (-not $NoTws) {
        # audio source: -Audio, else for a raw .m1v the .mp2 (or .tws) beside it, else the video itself
        $src = $path
        if ($Audio) { $src = $Audio }
        elseif ($isEs) {
            $src = Find-Sibling $path '.mp2'
            if (-not $src) { $src = Find-Sibling $path '.tws' }
            if (-not $src) { Write-Info "${path}: no .mp2 beside this .m1v - .tws not created"; return $true }
        }
        [void](Write-Tws $src ([IO.Path]::ChangeExtension($out, '.tws')) $true)
    }
    return $true
}

# Audio -> TWS. Raw path: MP2 audio is copied unchanged (natively for .mp2/.tws files).
# Otherwise encoded as MP2 with the TWS settings (default 160k, 44.1 kHz, stereo).
function Write-Tws([string]$path, [string]$tws, [bool]$optional) {
    if ([IO.Path]::GetFullPath($path) -eq [IO.Path]::GetFullPath($tws)) { Write-Err "${path}: output would overwrite input"; return $false }
    if (-not $script:ForceAudioEncode) {
        $mp2 = Get-Mp2Header $path
        if ($mp2) {                                           # native copy, no ffmpeg
            Backup-IfExists $tws
            Copy-Item -LiteralPath $path -Destination $tws -Force
            return (Write-TwsResult $tws $mp2 'copied as is (lossless)')
        }
        Initialize-Ffmpeg
        $ac = (Get-MediaInfo $path).ACodec
        # MPEG audio inside a container: demux only. (MP4 labels MP2 as "mp3", so the
        # frame header decides: Layer II is copied, real MP3 is re-encoded.)
        if ($ac -eq 'mp2' -or $ac -eq 'mp3') {
            $tmp = New-TempFile '.mp2'
            $res = Invoke-Ffmpeg @('-i', $path, '-vn', '-map', '0:a:0', '-c:a', 'copy', '-f', 'mp2', $tmp)
            if ($res.Code -eq 0 -and (Get-Mp2Header $tmp)) {
                Backup-IfExists $tws; Move-Item -LiteralPath $tmp -Destination $tws -Force
                return (Write-TwsResult $tws (Get-Mp2Header $tws) 'copied as is (lossless)')
            }
            Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue
            if ($ac -eq 'mp3') { $ac = 'MP3 (Layer III)' }
        }
        if ($ac) { Write-Info "${path}: source audio is $ac, not MP2 - encoding with the TWS settings" }
    }
    Initialize-Ffmpeg
    $tmp = New-TempFile '.mp2'
    $res = Invoke-Ffmpeg @('-i', $path, '-vn', '-map', '0:a:0', '-ac', "$TwsChannels", '-ar', "$TwsSampleRate",
        '-c:a', 'mp2', '-b:a', $TwsBitrate, '-f', 'mp2', $tmp)
    if ($res.Code -ne 0) {
        Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue
        if ($optional) { Write-Info "${path}: no usable audio track - .tws not created"; return $false }
        Write-Host $res.Err
        Write-Err "${path}: no usable audio track (or ffmpeg failed)"
        return $false
    }
    Backup-IfExists $tws; Move-Item -LiteralPath $tmp -Destination $tws -Force
    return (Write-TwsResult $tws (Get-Mp2Header $tws) 'encoded')
}

function Write-TwsResult([string]$tws, $h, [string]$how) {
    if (-not $h) { Write-Ok "$tws ($how)"; return $true }
    $ch = if ($h.Ch -eq 1) { 'mono' } else { 'stereo' }
    Write-Ok ('{0}: TWS (MP2 {1} Hz {2} {3}k), {4:0.0} s, {5}' -f $tws, $h.Rate, $ch, $h.Kbps, $h.Duration, $how)
    $hint = if ($how -like 'copied*') { ' (use -Reencode to convert it)' } else { '' }
    if ($h.Rate -ne 44100 -or $h.Ch -ne 2) { Write-Warn2 "the game's own TWS files are 44100 Hz stereo - this may not play in-game$hint" }
    elseif ($h.Kbps -ne 128 -and $h.Kbps -ne 160) { Write-Info "note: $($h.Kbps)k - the game's own TWS files use 128k or 160k" }
    return $true
}

function Convert-AudioToTws([string]$path, [string]$out) { return (Write-Tws $path $out $false) }

function Convert-TwsToAudio([string]$path, [string]$out) {
    if ([IO.Path]::GetExtension($path).ToLower() -eq '.wd1') { return (Convert-Wd1ToAudio $path $out) }
    $dur = Get-Mp2Duration $path
    if ($dur -le 0) { Write-Warn2 "${path}: does not start with an MPEG audio header - trying anyway" }
    else { Write-Info ('{0}: TWS (MP2), {1:0.0} s' -f $path, $dur) }
    if ($Info) { return $true }

    $reencode = ($AudioBitrate -or $SampleRate -gt 0 -or $Channels -gt 0)
    if (($AudioFormat -eq 'mp2' -or $AudioFormat -eq 'raw') -and -not $reencode) {   # native: TWS already is MP2
        Copy-Item -LiteralPath $path -Destination $out -Force
        Write-Ok "$out (original stream copied as is, no re-encode)"
        return $true
    }
    Initialize-Ffmpeg
    $codec = switch ($AudioFormat) {
        'wav'  { Get-AudioCodecArgs 'pcm' '' }
        'flac' { Get-AudioCodecArgs 'flac' '' }
        'mp3'  { if ($AudioBitrate) { Get-AudioCodecArgs 'mp3' '' }
                 else { @('-c:a', 'libmp3lame', '-q:a', '2') + (Get-RateArgs) } }
        'm4a'  { (Get-AudioCodecArgs 'aac' '192k') + @('-movflags', '+faststart') }
        'ogg'  { if ($AudioBitrate) { Get-AudioCodecArgs 'vorbis' '' }
                 else { @('-c:a', 'libvorbis', '-q:a', '6') + (Get-RateArgs) } }
        'opus' { Get-AudioCodecArgs 'opus' '160k' }
        'mp2'  { Get-AudioCodecArgs 'mp2' '160k' }
        'raw'  { Get-AudioCodecArgs 'mp2' '160k' }
    }
    $res = Invoke-Ffmpeg (@('-i', $path, '-vn') + $codec + @($out))
    if ($res.Code -ne 0) { Write-Host $res.Err; Write-Err "ffmpeg failed for $path"; return $false }
    Write-Ok $out
    return $true
}

# ============================================================== Earth 2150 .wd1
# A .wd1 video is an ordinary AVI (Cinepak / Indeo + PCM) or MPEG-1 system stream
# (MPEG-1 video + MP2) with another extension. Detected by content, natively.

function Get-UInt32LE([byte[]]$d, [int]$o) {
    return [uint32]$d[$o] -bor ([uint32]$d[$o + 1] -shl 8) -bor ([uint32]$d[$o + 2] -shl 16) -bor ([uint32]$d[$o + 3] -shl 24)
}
function Get-UInt16LE([byte[]]$d, [int]$o) { return [int]$d[$o] -bor ([int]$d[$o + 1] -shl 8) }

function Read-Head([string]$path, [int]$max) {
    $fs = [IO.File]::OpenRead($path)
    try {
        $n = [int][Math]::Min($fs.Length, $max)
        $d = [byte[]]::new($n); $got = 0
        while ($got -lt $n) { $r = $fs.Read($d, $got, $n - $got); if ($r -le 0) { break }; $got += $r }
        return , $d
    } finally { $fs.Dispose() }
}

# @{ Ext = 'avi' | 'mpg'; Mpeg2 = bool } or $null
function Get-Wd1Kind([string]$path) {
    try { $d = Read-Head $path 16 } catch { return $null }
    if ($d.Length -lt 12) { return $null }
    $a = [Text.Encoding]::ASCII
    if ($a.GetString($d, 0, 4) -eq 'RIFF' -and $a.GetString($d, 8, 4) -eq 'AVI ') { return @{ Ext = 'avi'; Mpeg2 = $false } }
    if ($d[0] -eq 0 -and $d[1] -eq 0 -and $d[2] -eq 1 -and $d[3] -eq 0xBA) {
        return @{ Ext = 'mpg'; Mpeg2 = (($d[4] -band 0xC0) -eq 0x40) }
    }
    return $null
}

$script:FourccNames = @{ cvid = 'Cinepak'; iv50 = 'Indeo 5'; iv41 = 'Indeo 4'; iv32 = 'Indeo 3'; iv31 = 'Indeo 3'
                         msvc = 'Microsoft Video 1'; cram = 'Microsoft Video 1'; mpg1 = 'MPEG-1' }
$script:WaveNames = @{ 1 = 'PCM'; 2 = 'MS ADPCM'; 17 = 'IMA ADPCM'; 80 = 'MPEG audio'; 85 = 'MP3' }
# what the game is known / expected to play (codecs found in Earth 2150 files)
$script:Wd1Fourccs = @('cvid', 'iv50', 'iv41', 'iv32', 'iv31', 'msvc', 'cram')
$script:Wd1WaveTags = @(0, 1, 2, 17, 80, 85)

function Get-AviInfo([string]$path) {
    $d = Read-Head $path 1048576
    $a = [Text.Encoding]::ASCII
    $r = @{ VFourcc = ''; W = 0; H = 0; Fps = 0.0; Frames = 0; ATag = 0; ARate = 0; ACh = 0; ABits = 0; HasAudio = $false }
    $pos = 12; $cur = ''
    while ($pos + 8 -le $d.Length) {
        $id = $a.GetString($d, $pos, 4); $sz = [long](Get-UInt32LE $d ($pos + 4))
        if ($id -eq 'LIST') {
            $lt = $a.GetString($d, $pos + 8, 4)
            if ($lt -eq 'movi') { break }
            if ($lt -eq 'hdrl' -or $lt -eq 'strl') { $pos += 12; continue }
        } elseif ($id -eq 'avih' -and $pos + 48 -le $d.Length) {
            $us = Get-UInt32LE $d ($pos + 8); if ($us) { $r.Fps = 1e6 / $us }
            $r.Frames = Get-UInt32LE $d ($pos + 24)
            $r.W = [int](Get-UInt32LE $d ($pos + 40)); $r.H = [int](Get-UInt32LE $d ($pos + 44))
        } elseif ($id -eq 'strh' -and $pos + 36 -le $d.Length) {
            $cur = $a.GetString($d, $pos + 8, 4)
            if ($cur -eq 'vids') {
                $r.VFourcc = $a.GetString($d, $pos + 12, 4).ToLower()
                $sc = Get-UInt32LE $d ($pos + 28); $rt = Get-UInt32LE $d ($pos + 32)
                if ($sc) { $r.Fps = $rt / $sc }
            }
        } elseif ($id -eq 'strf' -and $pos + 28 -le $d.Length) {
            if ($cur -eq 'vids') {
                $bc = $a.GetString($d, $pos + 24, 4).ToLower()
                if ($bc.Trim([char]0)) { $r.VFourcc = $bc }
            } elseif ($cur -eq 'auds') {
                $r.HasAudio = $true
                $r.ATag = Get-UInt16LE $d ($pos + 8); $r.ACh = Get-UInt16LE $d ($pos + 10)
                $r.ARate = [int](Get-UInt32LE $d ($pos + 12)); $r.ABits = Get-UInt16LE $d ($pos + 22)
            }
        }
        if ($sz -lt 0 -or $sz -gt [int]::MaxValue) { break }
        $pos += 8 + [int]$sz + ([int]$sz % 2)
    }
    return $r
}

function Get-PsInfo([string]$path) {
    $d = Read-Head $path 1048576
    $r = @{ Mpeg2 = (($d.Length -gt 4) -and (($d[4] -band 0xC0) -eq 0x40)); W = 0; H = 0; Fps = 0.0; ALayer = 0; AKbps = 0; ARate = 0; ACh = 0 }
    $s = $script:Latin1.GetString($d)
    $i = $s.IndexOf([string][char]0 + [char]0 + [char]1 + [char]0xB3, [StringComparison]::Ordinal)
    if ($i -ge 0 -and $i + 8 -le $d.Length) {
        $r.W = ([int]$d[$i + 4] -shl 4) -bor ($d[$i + 5] -shr 4)
        $r.H = (([int]$d[$i + 5] -band 0xF) -shl 8) -bor $d[$i + 6]
        $frc = $d[$i + 7] -band 0xF
        if ($frc -ge 1 -and $frc -le 8) { $r.Fps = $script:FpsCodes[$frc] }
    }
    $i = $s.IndexOf([string][char]0 + [char]0 + [char]1 + [char]0xC0, [StringComparison]::Ordinal)
    if ($i -ge 0 -and $i + 16 -lt $d.Length) {
        # MPEG-1 PES header: stuffing 0xFF, optional STD buffer, then PTS/DTS
        $k = $i + 6
        while ($k -lt $d.Length -and $d[$k] -eq 0xFF) { $k++ }
        if ($k -lt $d.Length -and ($d[$k] -band 0xC0) -eq 0x40) { $k += 2 }
        if ($k -lt $d.Length) {
            $t = $d[$k] -band 0xF0
            if ($t -eq 0x20) { $k += 5 } elseif ($t -eq 0x30) { $k += 10 } else { $k += 1 }
        }
        $end = [Math]::Min($d.Length - 4, $k + 4096)
        for (; $k -lt $end; $k++) {
            if ($d[$k] -ne 0xFF -or ($d[$k + 1] -band 0xF0) -ne 0xF0) { continue }
            $layer = 4 - (($d[$k + 1] -shr 1) -band 3)
            $bi = ($d[$k + 2] -shr 4) -band 0xF; $si = ($d[$k + 2] -shr 2) -band 3
            if ($layer -gt 3 -or $bi -eq 0 -or $bi -eq 15 -or $si -eq 3) { continue }
            $r.ALayer = $layer
            if ($layer -eq 2) { $r.AKbps = $script:Mp2Rates[$bi - 1] }
            $r.ARate = @(44100, 48000, 32000)[$si]
            $r.ACh = if ((($d[$k + 3] -shr 6) -band 3) -eq 3) { 1 } else { 2 }
            break
        }
    }
    return $r
}

function Get-Wd1InfoText([string]$path, $kind) {
    $inv = [Globalization.CultureInfo]::InvariantCulture
    if ($kind.Ext -eq 'avi') {
        $i = Get-AviInfo $path
        $vn = $script:FourccNames[$i.VFourcc]; if (-not $vn) { $vn = $i.VFourcc.ToUpper() }
        $dur = if ($i.Fps -gt 0) { ' ({0:0.0} s)' -f ($i.Frames / $i.Fps) } else { '' }
        $t = 'AVI: {0} {1}x{2} {3} fps, {4} frames{5}' -f $vn, $i.W, $i.H, $i.Fps.ToString('0.###', $inv), $i.Frames, $dur
        if ($i.HasAudio) {
            $an = $script:WaveNames[$i.ATag]; if (-not $an) { $an = 'audio tag 0x{0:X}' -f $i.ATag }
            $t += '; audio {0} {1}-bit {2} Hz {3}' -f $an, $i.ABits, $i.ARate, $(if ($i.ACh -eq 1) { 'mono' } else { 'stereo' })
        } else { $t += '; no audio' }
        return $t
    }
    $i = Get-PsInfo $path
    $t = '{0} system stream: {1} video {2}x{3} {4} fps' -f $(if ($i.Mpeg2) { 'MPEG-2' } else { 'MPEG-1' }), $(if ($i.Mpeg2) { 'MPEG-2' } else { 'MPEG-1' }), $i.W, $i.H, $i.Fps.ToString('0.###', $inv)
    if ($i.ALayer) {
        $an = @{ 1 = 'MP1'; 2 = 'MP2'; 3 = 'MP3' }[$i.ALayer]
        $t += '; audio {0}{1} {2} Hz {3}' -f $an, $(if ($i.AKbps) { " $($i.AKbps)k" } else { '' }), $i.ARate, $(if ($i.ACh -eq 1) { 'mono' } else { 'stereo' })
    }
    return $t
}

# Is this AVI/MPG something the game should play when copied in unchanged?
function Test-Wd1Playable([string]$path, $kind) {
    if ($kind.Ext -eq 'avi') {
        $i = Get-AviInfo $path
        if ($script:Wd1Fourccs -notcontains $i.VFourcc) { return "video codec '$($i.VFourcc.ToUpper())' is not one the game uses (Cinepak, Indeo, MPEG-1)" }
        if ($i.HasAudio -and $script:Wd1WaveTags -notcontains $i.ATag) { return ('audio format 0x{0:X} is not one the game uses (PCM)' -f $i.ATag) }
        return ''
    }
    if ($kind.Mpeg2) { return 'MPEG-2 stream (the game files are MPEG-1)' }
    $i = Get-PsInfo $path
    if (-not $i.W) { return 'no MPEG-1 video found' }
    if ($i.ALayer -and $i.ALayer -ne 2) { return "audio is MPEG layer $($i.ALayer) (the game files use MP2)" }
    return ''
}

# what each container can take as a stream copy, and what to encode when it can't
$script:CopyV = @{ mkv = @('indeo5', 'indeo4', 'indeo3', 'cinepak', 'msvideo1', 'mpeg1video'); avi = @('*')
                   mov = @('indeo5', 'cinepak', 'mpeg1video'); mp4 = @('mpeg1video'); mpg = @('mpeg1video'); webm = @() }
$script:CopyA = @{ mkv = @('pcm_s16le', 'pcm_u8', 'mp2', 'mp3', 'adpcm_ms', 'adpcm_ima_wav'); avi = @('*')
                   mov = @('pcm_s16le', 'pcm_u8', 'mp2'); mp4 = @('mp2', 'mp3'); mpg = @('mp2', 'mp3'); webm = @() }
$script:FallV = @{ mkv = 'h264'; avi = 'h264'; mov = 'h264'; mp4 = 'h264'; mpg = 'mpeg1'; webm = 'vp9' }
$script:FallA = @{ mkv = 'aac'; avi = 'mp3'; mov = 'aac'; mp4 = 'aac'; mpg = 'mp2'; webm = 'opus' }

function Test-CanCopy($table, [string]$container, [string]$codec) {
    $l = $table[$container]
    return ($l -contains '*' -or $l -contains $codec)
}

# Option 1 for .wd1: raw = the file under its real extension; otherwise remux / re-encode.
function Convert-Wd1ToVideo([string]$path, [string]$out) {
    $kind = Get-Wd1Kind $path
    if (-not $kind) { Write-Err "${path}: not an AVI or MPEG file - unknown .wd1 content"; return $false }
    Write-Info "${path}: $(Get-Wd1InfoText $path $kind)"
    if ($Info) { return $true }

    if ($Container -eq 'raw') {                         # native: it already is an AVI / MPG
        $o = [IO.Path]::ChangeExtension($out, '.' + $kind.Ext)
        Copy-Item -LiteralPath $path -Destination $o -Force
        Write-Ok "$o (original file, copied as is)"
        return $true
    }
    Initialize-Ffmpeg
    $mi = Get-MediaInfo $path
    $c = $Container
    $vc = $VideoCodec; $ac = $AudioCodec
    if ($vc -eq 'copy' -and -not (Test-CanCopy $script:CopyV $c $mi.VCodec)) {
        $vc = $script:FallV[$c]
        Write-Info "${path}: $($mi.VCodec) video can't go into .$c as is - encoding $vc"
    }
    $hasA = [bool]$mi.ACodec -and -not $NoAudio
    if ($hasA -and $ac -eq 'copy' -and -not (Test-CanCopy $script:CopyA $c $mi.ACodec)) {
        $ac = $script:FallA[$c]
        Write-Info "${path}: $($mi.ACodec) audio can't go into .$c as is - encoding $ac"
    }
    $a = @('-fflags', '+genpts', '-i', $path, '-map', '0:v:0')
    if ($hasA) {
        $a += @('-map', '0:a:0') + (Get-AudioCodecArgs $ac $(if ($ac -eq 'opus') { '160k' } else { '192k' }))
        # MP2 only has 32 / 44.1 / 48 kHz in MPEG-1 (e.g. 22050 Hz Indeo AVIs need resampling)
        if ($ac -eq 'mp2' -and $SampleRate -eq 0 -and @(32000, 44100, 48000) -notcontains $mi.ARate) { $a += @('-ar', '44100') }
    }
    else { $a += @('-an') }
    $a += Get-VideoArgs $vc $mi.Fps
    if ($c -eq 'mp4' -or $c -eq 'mov') { $a += @('-movflags', '+faststart') }
    $a += @($out)
    $res = Invoke-Ffmpeg $a
    if ($res.Code -ne 0) { Write-Host $res.Err; Write-Err "ffmpeg failed for $path"; return $false }
    $how = @()
    $how += $(if ($vc -eq 'copy') { 'video copied' } else { "video $vc" })
    if ($hasA) { $how += $(if ($ac -eq 'copy') { 'audio copied' } else { "audio $ac" }) }
    Write-Ok "$out ($($how -join ', '))"
    return $true
}

# Option 3 for .wd1: raw = its own audio track, unchanged (PCM -> .wav, MP2 -> .mp2)
function Convert-Wd1ToAudio([string]$path, [string]$out) {
    $kind = Get-Wd1Kind $path
    if (-not $kind) { Write-Err "${path}: not an AVI or MPEG file - unknown .wd1 content"; return $false }
    Write-Info "${path}: $(Get-Wd1InfoText $path $kind)"
    if ($Info) { return $true }
    Initialize-Ffmpeg
    $mi = Get-MediaInfo $path
    if (-not $mi.ACodec) { Write-Err "${path}: has no audio track"; return $false }
    $reencode = ($AudioBitrate -or $SampleRate -gt 0 -or $Channels -gt 0)
    $fmt = $AudioFormat
    if ($fmt -eq 'raw') { $fmt = if ($mi.ACodec -eq 'mp2') { 'mp2' } elseif ($mi.ACodec -eq 'mp3') { 'mp3' } else { 'wav' } }
    $copy = -not $reencode -and (($fmt -eq 'mp2' -and $mi.ACodec -eq 'mp2') -or ($fmt -eq 'mp3' -and $mi.ACodec -eq 'mp3') -or
                                 ($fmt -eq 'wav' -and $mi.ACodec -eq 'pcm_s16le'))
    $codec = if ($copy) { @('-c:a', 'copy') } else {
        switch ($fmt) {
            'wav'  { Get-AudioCodecArgs 'pcm' '' }
            'flac' { Get-AudioCodecArgs 'flac' '' }
            'mp3'  { if ($AudioBitrate) { Get-AudioCodecArgs 'mp3' '' } else { @('-c:a', 'libmp3lame', '-q:a', '2') + (Get-RateArgs) } }
            'm4a'  { (Get-AudioCodecArgs 'aac' '192k') + @('-movflags', '+faststart') }
            'ogg'  { if ($AudioBitrate) { Get-AudioCodecArgs 'vorbis' '' } else { @('-c:a', 'libvorbis', '-q:a', '6') + (Get-RateArgs) } }
            'opus' { Get-AudioCodecArgs 'opus' '160k' }
            'mp2'  { Get-AudioCodecArgs 'mp2' '160k' }
        }
    }
    $out = [IO.Path]::ChangeExtension($out, '.' + $fmt)
    if ($fmt -eq 'mp2') { $codec += @('-f', 'mp2') }
    $res = Invoke-Ffmpeg (@('-i', $path, '-vn', '-map', '0:a:0') + $codec + @($out))
    if ($res.Code -ne 0) { Write-Host $res.Err; Write-Err "ffmpeg failed for $path"; return $false }
    Write-Ok "$out ($(if ($copy) { 'original audio, copied as is' } else { 'encoded' }))"
    return $true
}

function Test-SetByUser([string]$name) { return ($script:Bound.ContainsKey($name) -or $script:MenuSet.ContainsKey($name)) }

# Option 5: video -> Earth 2150 .wd1
function Convert-ToWd1([string]$path, [string]$out) {
    # the .wd1 being replaced (if any) decides the format to match
    $tgt = $null
    if (Test-Path -LiteralPath $out -PathType Leaf) {
        $tk = Get-Wd1Kind $out
        if ($tk) {
            $tgt = @{ Kind = $tk.Ext }
            if ($tk.Ext -eq 'avi') { $i = Get-AviInfo $out; $tgt.W = $i.W; $tgt.H = $i.H; $tgt.Fps = $i.Fps; $tgt.ARate = $i.ARate; $tgt.ACh = $i.ACh; $tgt.AKbps = 0 }
            else { $i = Get-PsInfo $out; $tgt.W = $i.W; $tgt.H = $i.H; $tgt.Fps = $i.Fps; $tgt.ARate = $i.ARate; $tgt.ACh = $i.ACh; $tgt.AKbps = $i.AKbps }
            Write-Info "replacing $([IO.Path]::GetFileName($out)): $(Get-Wd1InfoText $out $tk)"
        }
    }

    # 1) raw path: an AVI / MPG the game can play is copied in unchanged
    $force = $script:ForceVideoEncode -or $Wd1Format -ne 'auto' -or $AudioBitrate -or $SampleRate -gt 0 -or $Channels -gt 0
    if (-not $force) {
        $sk = Get-Wd1Kind $path
        if ($sk) {
            $why = Test-Wd1Playable $path $sk
            if (-not $why) {
                if ($tgt -and $tgt.Kind -ne $sk.Ext) { Write-Warn2 "${path}: is $($sk.Ext.ToUpper()) but the file being replaced is $($tgt.Kind.ToUpper()) - use -Reencode to match it" }
                Backup-IfExists $out
                Copy-Item -LiteralPath $path -Destination $out -Force
                Write-Ok "${out}: $(Get-Wd1InfoText $out $sk), copied as is (lossless)"
                return $true
            }
            Write-Info "${path}: can't be copied as is ($why) - re-encoding"
        } else {
            Write-Info "${path}: is not an AVI or MPEG file - encoding it for the game"
        }
    }

    # 2) encode, matching the file being replaced where possible
    Initialize-Ffmpeg
    $src = Get-MediaInfo $path
    if (-not $src.VCodec) { Write-Err "${path}: no video stream"; return $false }
    $fmt = $Wd1Format
    if ($fmt -eq 'auto') { $fmt = if ($tgt) { $tgt.Kind } else { 'mpg' } }

    if ((Test-SetByUser 'Width') -or (Test-SetByUser 'Height')) { $w = $Width; $h = $Height }
    elseif ($tgt -and $tgt.W) { $w = $tgt.W; $h = $tgt.H }
    else { $w = $src.W; $h = $src.H }
    $m = if ($fmt -eq 'avi') { 4 } else { 2 }                 # Cinepak: multiple of 4; MPEG-1: even
    $w = [int]($w - ($w % $m)); $h = [int]($h - ($h % $m))
    if ($w -lt 16 -or $h -lt 16) { Write-Err "${path}: could not determine a frame size - give -Width and -Height"; return $false }

    $fps = if ($Fps -gt 0) { $Fps } elseif ($tgt -and $tgt.Fps -gt 0) { $tgt.Fps } elseif ($src.Fps -gt 0) { $src.Fps } else { 25.0 }
    if ($fmt -eq 'mpg') { $fps = $script:FpsCodes[(Get-FpsCode $fps)] }
    $fpsStr = $fps.ToString('0.######', [Globalization.CultureInfo]::InvariantCulture)

    $rate = if ($SampleRate -gt 0) { $SampleRate } elseif ($tgt -and $tgt.ARate) { $tgt.ARate } else { 44100 }
    if ($fmt -eq 'mpg' -and @(32000, 44100, 48000) -notcontains $rate) {
        Write-Info "${path}: MPEG-1 audio can't be $rate Hz - using 44100 Hz"; $rate = 44100
    }
    $ch = if ($Channels -gt 0) { $Channels } elseif ($tgt -and $tgt.ACh) { $tgt.ACh } else { 2 }

    if ($Stretch) { $vf = "scale=${w}:${h}" }
    else { $vf = "scale=${w}:${h}:force_original_aspect_ratio=decrease,pad=${w}:${h}:(ow-iw)/2:(oh-ih)/2:black" }
    $vf += ',setsar=1'

    $a = @('-i', $path, '-map', '0:v:0')
    if ($src.ACodec) { $a += @('-map', '0:a:0') }
    $a += @('-vf', $vf, '-r', $fpsStr)
    if ($fmt -eq 'mpg') {
        $q = if (Test-SetByUser 'Q') { $Q } else { 2 }
        $br = if ($AudioBitrate) { $AudioBitrate } elseif ($tgt -and $tgt.AKbps) { "$($tgt.AKbps)k" } else { '160k' }
        Test-Mp2Combo (Get-KbpsValue $br) $ch 'audio bitrate'
        $a += @('-c:v', 'mpeg1video', '-q:v', "$q", '-g', '15', '-bf', '2', '-pix_fmt', 'yuv420p')
        if ($src.ACodec) { $a += @('-c:a', 'mp2', '-b:a', $br, '-ar', "$rate", '-ac', "$ch") }
        $a += @('-f', 'mpeg')
        $fpsShow = $fps.ToString('0.###', [Globalization.CultureInfo]::InvariantCulture)
        $desc = "MPEG-1 ${w}x${h} $fpsShow fps" + $(if ($src.ACodec) { ", MP2 $br $rate Hz" } else { '' })
    } else {
        $a += @('-c:v', 'cinepak')
        if ($src.ACodec) { $a += @('-c:a', 'pcm_s16le', '-ar', "$rate", '-ac', "$ch") }
        $a += @('-f', 'avi')
        $desc = "AVI Cinepak ${w}x${h} $($fps.ToString('0.###', [Globalization.CultureInfo]::InvariantCulture)) fps" + $(if ($src.ACodec) { ", PCM $rate Hz" } else { '' })
    }
    $tmp = New-TempFile ".$fmt"
    $res = Invoke-Ffmpeg ($a + @($tmp))
    if ($res.Code -ne 0) { Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue; Write-Host $res.Err; Write-Err "ffmpeg failed for $path"; return $false }
    Backup-IfExists $out
    Move-Item -LiteralPath $tmp -Destination $out -Force
    $match = if ($tgt -and $Wd1Format -eq 'auto') { ' (matching the file it replaces)' } else { '' }
    Write-Ok "${out}: $desc, encoded$match"
    return $true
}

# ============================================================== CLI

function Clear-PathText([string]$p) {
    $p = $p.Trim()
    if ($p.StartsWith('& ')) { $p = $p.Substring(2).Trim() }
    while ($p.Length -ge 2 -and $p[0] -eq $p[$p.Length - 1] -and ($p[0] -eq '"' -or $p[0] -eq "'")) {
        $p = $p.Substring(1, $p.Length - 2).Trim()
    }
    return $p
}

# ============================================================== interactive menu

$script:ActionNames = @{
    ToMp4 = 'Game video -> normal video'; TwsToAudio = 'Game sound -> normal audio'
    ToTwv = 'Video -> TWV + TWS game files'; AudioToTws = 'Audio -> TWS game file'
    ToWd1 = 'Video -> WD1 game file (Earth 2150)'; Info = 'Inspect game files'
}
$script:ActionInputs = @{
    ToMp4 = '.twv or .wd1 files, or a folder with them'
    TwsToAudio = '.tws or .wd1 files, or a folder with them'
    ToTwv = 'video files (.mp4 .mkv .avi .mpg .m1v ...), or a folder with them'
    AudioToTws = 'audio files (.wav .mp3 .flac .mp2 ...), or a folder with them'
    ToWd1 = 'video files (.mp4 .mkv .avi .mpg ...), or a folder with them'
    Info = '.twv, .tws or .wd1 files, or a folder with them'
}
$script:NoInput = $false                       # set when the input stream has ended

function Test-ConsoleInput { try { return -not [Console]::IsInputRedirected } catch { return $true } }
function Clear-Screen { if (Test-ConsoleInput) { try { Clear-Host } catch { } } }

function Read-Line([string]$prompt) {
    if ($script:NoInput) { return $null }
    $v = Read-Host $prompt
    if ($null -eq $v) { $script:NoInput = $true; return $null }
    return $v.Trim()
}

function Write-Title([string]$t) {
    Write-Host ''
    Write-Host "  $t" -ForegroundColor Cyan
    Write-Host ('  ' + ('=' * $t.Length)) -ForegroundColor Cyan
}

function Write-Section([string]$t) { Write-Host ''; Write-Host "  $t" -ForegroundColor White }

function Write-Note([string]$t) { foreach ($l in ($t -split "`n")) { Write-Host "  $l" -ForegroundColor DarkGray } }

function Write-Item([string]$key, [string]$label, [string]$note, [switch]$Default) {
    Write-Host ('  {0,3}) ' -f $key) -NoNewline -ForegroundColor Yellow
    Write-Host $label -NoNewline
    if ($Default) { Write-Host '   <- Enter' -NoNewline -ForegroundColor Green }
    Write-Host ''
    if ($note) { foreach ($l in ($note -split "`n")) { Write-Host "       $l" -ForegroundColor DarkGray } }
}

# Returns the key typed (upper case), the default on Enter, or 'Q' when input has ended.
function Read-Choice([string[]]$keys, [string]$default) {
    for ($try = 0; $try -lt 20; $try++) {
        $p = if ($default) { "  Your choice (Enter = $default)" } else { '  Your choice' }
        $v = Read-Line $p
        if ($null -eq $v) { return 'Q' }
        $v = $v.ToUpper()
        if ($v -eq '' -and $default) { return $default.ToUpper() }
        if ($keys -contains $v) { return $v }
        Write-Err "please type one of: $($keys -join ', ')"
    }
    return 'Q'
}

# Numbered list; returns 1..n, or 0 for Back. $items = @( @('label', 'note'), ... )
function Read-Menu([string]$question, [object[]]$items, [int]$default = 1, [switch]$NoBack) {
    Write-Section $question
    $keys = @()
    for ($i = 0; $i -lt $items.Count; $i++) {
        $k = "$($i + 1)"; $keys += $k
        Write-Item $k $items[$i][0] $items[$i][1] -Default:(($i + 1) -eq $default)
    }
    if (-not $NoBack) { Write-Item 'B' 'Back'; $keys += @('B', 'Q') }
    $c = Read-Choice $keys "$default"
    if ($c -eq 'B' -or $c -eq 'Q') { return 0 }
    return [int]$c
}

function Read-Default([string]$prompt, [string]$default) {
    $v = Read-Line "  $prompt (Enter = $default)"
    if ($null -eq $v -or $v -eq '') { return $default }
    return $v
}

function Read-Pick([string]$prompt, [string[]]$allowed, [string]$default) {
    for ($try = 0; $try -lt 20; $try++) {
        $v = (Read-Default "$prompt [$($allowed -join '/')]" $default).ToLower()
        if ($allowed -contains $v) { return $v }
        Write-Err "choose one of: $($allowed -join ', ')"
    }
    return $default
}

function Read-Bitrate([string]$prompt, [string]$default, [int[]]$allowed) {
    for ($try = 0; $try -lt 20; $try++) {
        $v = Read-Default $prompt $default
        try {
            $k = Get-KbpsValue $v
            if ($k -gt 0 -and (-not $allowed -or $allowed -contains $k)) { return "${k}k" }
        } catch { }
        if ($allowed) { Write-Err "use one of: $(($allowed | ForEach-Object { "${_}k" }) -join ', ')" }
        else { Write-Err 'type a bitrate like 192k' }
    }
    return $default
}

function Read-Size([string]$prompt, [int]$multiple) {
    for ($try = 0; $try -lt 20; $try++) {
        $v = Read-Line "  $prompt (e.g. 640x480)"
        if ($null -eq $v) { return $null }
        if ($v -match '^(\d+)\s*[xX]\s*(\d+)$' -and ([int]$Matches[1] % $multiple) -eq 0 -and ([int]$Matches[2] % $multiple) -eq 0) {
            return @([int]$Matches[1], [int]$Matches[2])
        }
        Write-Err "type width x height$(if ($multiple -gt 1) { " (multiples of $multiple)" })"
    }
    return $null
}

# ---------------------------------------------------------------- 1) game video -> video
function Show-VideoOptions {
    Write-Title 'Game video -> normal video'
    Write-Note "Turns .twv videos (KnightShift-style games) and .wd1 videos (Earth 2150)`ninto files you can play or edit."
    Write-Section 'Keep the original quality  (nothing is re-encoded)'
    Write-Item '1' 'Exact copy of the original streams' ".twv -> .m1v video + .mp2 sound (2 files)    .wd1 -> .avi or .mpg`nPlays in VLC / MPC-HC. No download needed." -Default
    Write-Item '2' 'One MKV file with the original streams' 'Video and sound in one file. Plays in VLC / MPC-HC.'
    Write-Item '3' 'One MPG file (classic MPEG)' 'Lossless for .twv; .wd1 AVI videos are converted to MPEG-1.'
    Write-Section 'Convert  (plays everywhere / smaller; uses ffmpeg, downloaded once)'
    Write-Item '4' 'MP4 - plays everywhere (Windows, phones, browsers)' 'H.264 video + AAC sound'
    Write-Item '5' 'MP4 - smaller file' 'H.265 video + AAC sound (older devices may not play it)'
    Write-Item '6' 'WebM - for web pages' 'VP9 video + Opus sound'
    Write-Item '7' 'Advanced - choose everything yourself' 'container, codecs, quality, size, sound'
    Write-Host ''
    Write-Item 'B' 'Back to the main menu'
    $c = Read-Choice @('1', '2', '3', '4', '5', '6', '7', 'B', 'Q') '1'
    switch ($c) {
        '1' { $script:Container = 'raw'; $script:ChoiceText = 'exact copy of the original streams (.m1v + .mp2, or .avi / .mpg)' }
        '2' { $script:Container = 'mkv'; $script:VideoCodec = 'copy'; $script:AudioCodec = 'copy'; $script:ChoiceText = 'one MKV file, original streams' }
        '3' { $script:Container = 'mpg'; $script:VideoCodec = 'copy'; $script:AudioCodec = 'copy'; $script:ChoiceText = 'one MPG file, original streams where possible' }
        '4' { $script:Container = 'mp4'; $script:VideoCodec = 'h264'; $script:AudioCodec = 'aac'; $script:ChoiceText = 'MP4, H.264 + AAC 192 kbps' }
        '5' { $script:Container = 'mp4'; $script:VideoCodec = 'h265'; $script:AudioCodec = 'aac'; $script:ChoiceText = 'MP4, H.265 + AAC 192 kbps' }
        '6' { $script:Container = 'webm'; $script:VideoCodec = 'vp9'; $script:AudioCodec = 'opus'; $script:ChoiceText = 'WebM, VP9 + Opus 160 kbps' }
        '7' { return (Show-VideoAdvanced) }
        default { return $false }
    }
    return $true
}

function Show-VideoAdvanced {
    $cont = @('mp4', 'mkv', 'mov', 'avi', 'webm', 'mpg')
    $n = Read-Menu 'File type (container)' @(
        @('MP4', 'plays everywhere'), @('MKV', 'holds any stream, plays in VLC / MPC-HC'), @('MOV', 'QuickTime'),
        @('AVI', 'classic Windows video'), @('WebM', 'for web pages (VP9 / AV1 only)'), @('MPG', 'classic MPEG-1'))
    if (-not $n) { return $false }
    $script:Container = $cont[$n - 1]
    $vOk = switch ($Container) { 'webm' { @('vp9', 'av1') } 'mpg' { @('copy', 'mpeg1') } 'mov' { @('copy', 'h264', 'h265', 'mpeg1') }
                                 'avi' { @('copy', 'h264', 'mpeg1') } 'mp4' { @('copy', 'h264', 'h265', 'av1', 'mpeg1') }
                                 default { @('copy', 'h264', 'h265', 'vp9', 'av1', 'mpeg1') } }
    $vNames = @{ copy = @('Keep the original video', 'no quality loss; converted only if the file type cannot hold it')
                 h264 = @('H.264', 'plays everywhere'); h265 = @('H.265', 'smaller, newer devices')
                 vp9 = @('VP9', 'web'); av1 = @('AV1', 'smallest, slow to make, newest devices'); mpeg1 = @('MPEG-1', 'very old players') }
    $n = Read-Menu 'Video' @($vOk | ForEach-Object { , $vNames[$_] })
    if (-not $n) { return $false }
    $script:VideoCodec = $vOk[$n - 1]
    if ($VideoCodec -ne 'copy') {
        $script:CrfAuto = $true
        $d = Get-CrfFor $VideoCodec
        $q = Read-Default "Video quality: a number (lower = better, $d is very good) or a bitrate like 4M" "$d"
        if ($q -match '^\d+$') { $script:Crf = [int]$q; $script:CrfAuto = $false } else { $script:VideoBitrate = $q }
        $n = Read-Menu 'Picture size' @(@('Keep the original size', ''), @('Double size', 'e.g. 640x256 -> 1280x512'), @('Type a size', ''))
        if (-not $n) { return $false }
        if ($n -eq 2) { $script:OutSize = 'double' }
        if ($n -eq 3) { $wh = Read-Size 'Size' 2; if ($wh) { $script:OutSize = "$($wh[0])x$($wh[1])" } }
    }
    $aOk = switch ($Container) { 'webm' { @('opus', 'vorbis') } 'mpg' { @('copy', 'mp2', 'mp3') } 'mov' { @('copy', 'aac', 'mp3', 'mp2', 'pcm') }
                                 'avi' { @('copy', 'mp3', 'mp2', 'aac', 'pcm') } 'mp4' { @('copy', 'aac', 'mp3', 'mp2', 'opus', 'flac') }
                                 default { @('copy', 'aac', 'mp3', 'mp2', 'opus', 'vorbis', 'flac', 'pcm') } }
    $aNames = @{ copy = @('Keep the original sound', 'no quality loss; converted only if the file type cannot hold it')
                 aac = @('AAC', 'plays everywhere'); mp3 = @('MP3', ''); mp2 = @('MP2', ''); opus = @('Opus', 'small, good quality')
                 vorbis = @('Vorbis', ''); flac = @('FLAC', 'lossless'); pcm = @('PCM / WAV', 'lossless, large') }
    $n = Read-Menu 'Sound' @($aOk | ForEach-Object { , $aNames[$_] })
    if (-not $n) { return $false }
    $script:AudioCodec = $aOk[$n - 1]
    if (@('aac', 'mp3', 'mp2', 'opus', 'vorbis') -contains $AudioCodec) {
        $d = if ($AudioCodec -eq 'opus') { '160k' } else { '192k' }
        $script:AudioBitrate = Read-Bitrate 'Sound bitrate' $d $null
    }
    $sz = ''
    if ($OutSize -eq 'double') { $script:OutSize = ''; $script:DoubleSize = $true; $sz = ', double size' }
    elseif ($OutSize) { $sz = ", $OutSize" }
    $vq = if ($VideoCodec -eq 'copy') { 'original' } elseif ($VideoBitrate) { "$VideoCodec $VideoBitrate" } else { "$VideoCodec quality $(Get-CrfFor $VideoCodec)" }
    $script:ChoiceText = ".$Container, video $vq$sz, sound $(if ($AudioCodec -eq 'copy') { 'original' } else { "$AudioCodec $AudioBitrate".Trim() })"
    return $true
}

# ---------------------------------------------------------------- 2) game sound -> audio
function Show-AudioOptions {
    Write-Title 'Game sound -> normal audio'
    Write-Note "Takes the sound from .tws files (KnightShift-style games) or from .wd1`nvideos (Earth 2150)."
    Write-Section 'Keep the original quality'
    Write-Item '1' 'Exact copy of the original sound' ".tws -> .mp2     .wd1 -> .wav or .mp2 (whatever is inside)`nNo download needed for .tws." -Default
    Write-Item '2' 'WAV  - lossless, plays everywhere, large'
    Write-Item '3' 'FLAC - lossless, about half the size of WAV'
    Write-Section 'Convert to a smaller file  (uses ffmpeg, downloaded once)'
    Write-Item '4' 'MP3  - plays everywhere'
    Write-Item '5' 'M4A  - AAC, plays everywhere'
    Write-Item '6' 'OGG  - Vorbis'
    Write-Item '7' 'Opus - smallest for the quality'
    Write-Item '8' 'MP2  - same format as the game, different bitrate'
    Write-Host ''
    Write-Item 'B' 'Back to the main menu'
    $c = Read-Choice @('1', '2', '3', '4', '5', '6', '7', '8', 'B', 'Q') '1'
    if ($c -eq 'B' -or $c -eq 'Q') { return $false }
    $script:AudioFormat = @{ '1' = 'raw'; '2' = 'wav'; '3' = 'flac'; '4' = 'mp3'; '5' = 'm4a'; '6' = 'ogg'; '7' = 'opus'; '8' = 'mp2' }[$c]
    $script:ChoiceText = @{ raw = 'exact copy of the original sound'; wav = 'WAV (lossless)'; flac = 'FLAC (lossless)'
                            mp3 = 'MP3'; m4a = 'M4A (AAC)'; ogg = 'OGG (Vorbis)'; opus = 'Opus'; mp2 = 'MP2' }[$AudioFormat]
    $q = $null
    switch ($AudioFormat) {
        'mp3'  { $n = Read-Menu 'MP3 quality' @(@('Best - variable bitrate, about 190 kbps', ''), @('320 kbps', ''), @('256 kbps', ''), @('192 kbps', ''), @('128 kbps', 'smallest'))
                 if (-not $n) { return $false }; $q = @($null, '320k', '256k', '192k', '128k')[$n - 1] }
        'm4a'  { $n = Read-Menu 'M4A quality' @(@('192 kbps', 'very good'), @('256 kbps', ''), @('128 kbps', 'smaller'))
                 if (-not $n) { return $false }; $q = @('192k', '256k', '128k')[$n - 1] }
        'ogg'  { $n = Read-Menu 'OGG quality' @(@('Best - variable bitrate, about 190 kbps', ''), @('256 kbps', ''), @('128 kbps', 'smaller'))
                 if (-not $n) { return $false }; $q = @($null, '256k', '128k')[$n - 1] }
        'opus' { $n = Read-Menu 'Opus quality' @(@('160 kbps', 'very good'), @('128 kbps', ''), @('96 kbps', 'smaller'))
                 if (-not $n) { return $false }; $q = @('160k', '128k', '96k')[$n - 1] }
        'mp2'  { $n = Read-Menu 'MP2 bitrate' @(@('160 kbps', 'like most game files'), @('128 kbps', ''), @('192 kbps', ''), @('256 kbps', ''), @('384 kbps', 'highest'))
                 if (-not $n) { return $false }; $q = @('160k', '128k', '192k', '256k', '384k')[$n - 1] }
    }
    if ($q) { $script:AudioBitrate = $q; $script:ChoiceText += " $q" }
    elseif (@('mp3', 'ogg') -contains $AudioFormat) { $script:ChoiceText += ' best quality' }
    if ($AudioFormat -ne 'raw') {
        $n = Read-Menu 'Sample rate and channels' @(@('Keep them as they are', ''), @('44.1 kHz stereo', 'CD quality'), @('48 kHz stereo', ''), @('22 kHz mono', 'small, for voice'))
        if (-not $n) { return $false }
        switch ($n) { 2 { $script:SampleRate = 44100; $script:Channels = 2 } 3 { $script:SampleRate = 48000; $script:Channels = 2 } 4 { $script:SampleRate = 22050; $script:Channels = 1 } }
    }
    return $true
}

# ---------------------------------------------------------------- 3) video -> TWV/TWS
function Show-TwvOptions {
    Write-Title 'Video -> TWV + TWS game files'
    Write-Note "Makes a .twv video and its .tws sound for the TWV games (KnightShift,`nWorld War III, Heli Heroes, Panzer Claws ...)."
    $n = Read-Menu 'How?' @(
        @('Automatic', "Original quality where possible: MPEG-1 video made by option 1 goes back`nunchanged. Anything else is converted to the game's own format:`n640x256, same frame rate, best quality, MP2 160 kbps stereo sound."),
        @('Choose the settings yourself', 'frame rate, size, quality, sound'))
    if (-not $n) { return $false }
    if ($n -eq 1) {
        $script:ForceVideoEncode = $false; $script:ForceAudioEncode = $false
        $script:ChoiceText = "automatic (original quality where possible, else the game's own format)"
        return $true
    }
    $script:ForceVideoEncode = $true
    $n = Read-Menu 'Frame rate' @(@('Same as the source video', 'rounded to the nearest the game supports'), @('25 fps', ''), @('24 fps', ''), @('30 fps', ''), @('29.97 fps', ''), @('23.976 fps', ''))
    if (-not $n) { return $false }
    if ($n -gt 1) { $script:Fps = @(0, 0, 25, 24, 30, (30000 / 1001), (24000 / 1001))[$n] }
    $n = Read-Menu 'Picture size' @(@('640 x 256', 'the size the game uses'), @('Type another size', 'multiples of 16'))
    if (-not $n) { return $false }
    if ($n -eq 2) { $wh = Read-Size 'Size' 16; if ($wh) { $script:Width = $wh[0]; $script:Height = $wh[1] } }
    $n = Read-Menu 'If the shape is different' @(@('Add black bars', 'keeps the picture shape'), @('Stretch to fill', ''))
    if (-not $n) { return $false }
    $script:Stretch = ($n -eq 2)
    $n = Read-Menu 'Picture quality' @(@('Best', 'what the game files use (quantiser 1)'), @('Very good', 'smaller file (2)'), @('Good', 'much smaller (4)'), @('Type a value', '1-31, lower = better'))
    if (-not $n) { return $false }
    if ($n -le 3) { $script:Q = @(1, 2, 4)[$n - 1] }
    else { $v = Read-Default 'Quality 1-31' '1'; if ($v -match '^\d+$' -and [int]$v -ge 1 -and [int]$v -le 31) { $script:Q = [int]$v } }
    $n = Read-Menu 'Sound (.tws)' @(@('Make it - MP2 160 kbps stereo', 'like most game files'), @('Make it - MP2 128 kbps stereo', ''), @('Make it - choose the settings', ''), @('No sound file', 'video only'))
    if (-not $n) { return $false }
    $script:ForceAudioEncode = $true
    switch ($n) { 1 { $script:TwsBitrate = '160k' } 2 { $script:TwsBitrate = '128k' } 3 { if (-not (Show-TwsEncodeOptions)) { return $false } } 4 { $script:NoTws = $true } }
    $script:ChoiceText = "${Width}x${Height}, $(if ($Fps -gt 0) { '{0:0.###} fps' -f $Fps } else { 'same frame rate' }), quality $Q; $(if ($NoTws) { 'no .tws' } else { ".tws MP2 $TwsBitrate" })"
    return $true
}

function Show-TwsEncodeOptions {
    $n = Read-Menu 'Channels' @(@('Stereo', 'like the game files'), @('Mono', ''))
    if (-not $n) { return $false }
    $script:TwsChannels = @(2, 1)[$n - 1]
    $rates = if ($TwsChannels -eq 2) { @(160, 128, 192, 224, 256, 320, 384, 112, 96, 64) } else { @(160, 128, 192, 112, 96, 80, 64, 56, 48, 32) }
    $n = Read-Menu 'Bitrate' @($rates | ForEach-Object { , @("$_ kbps", $(if ($_ -eq 160 -or $_ -eq 128) { 'used by the game files' } else { '' })) })
    if (-not $n) { return $false }
    $script:TwsBitrate = "$($rates[$n - 1])k"
    $n = Read-Menu 'Sample rate' @(@('44.1 kHz', 'like the game files'), @('48 kHz', ''), @('32 kHz', ''))
    if (-not $n) { return $false }
    $script:TwsSampleRate = @(44100, 48000, 32000)[$n - 1]
    return $true
}

# ---------------------------------------------------------------- 4) audio -> TWS
function Show-TwsOptions {
    Write-Title 'Audio -> TWS game file'
    Write-Note 'Makes a .tws sound file for the TWV games.'
    $n = Read-Menu 'How?' @(
        @('Automatic', "MP2 sound goes in unchanged. Anything else is converted to the`ngame's own format: MP2 160 kbps, 44.1 kHz stereo."),
        @('Choose the settings yourself', 'bitrate, channels, sample rate'))
    if (-not $n) { return $false }
    if ($n -eq 1) {
        $script:ForceAudioEncode = $false
        $script:ChoiceText = "automatic (MP2 kept as is, else MP2 160 kbps 44.1 kHz stereo)"
        return $true
    }
    $script:ForceAudioEncode = $true
    if (-not (Show-TwsEncodeOptions)) { return $false }
    $script:ChoiceText = "MP2 $TwsBitrate, $TwsSampleRate Hz, $(if ($TwsChannels -eq 1) { 'mono' } else { 'stereo' })"
    return $true
}

# ---------------------------------------------------------------- 5) video -> WD1
function Show-Wd1Options {
    Write-Title 'Video -> WD1 game file (Earth 2150)'
    Write-Note 'Makes a .wd1 video for Earth 2150.'
    $n = Read-Menu 'How?' @(
        @('Automatic', "An AVI / MPG the game can already play goes in unchanged. Anything`nelse is converted to match the .wd1 it replaces (format, size, frame`nrate, sound), or to MPEG-1 if it replaces nothing."),
        @('Choose the settings yourself', 'format, size, frame rate, quality, sound'))
    if (-not $n) { return $false }
    if ($n -eq 1) {
        $script:ForceVideoEncode = $false; $script:ForceAudioEncode = $false
        $script:ChoiceText = 'automatic (copied if the game can play it, else converted to match)'
        return $true
    }
    $script:ForceVideoEncode = $true; $script:ForceAudioEncode = $true
    $script:MenuSet = @{}
    $n = Read-Menu 'Format' @(@('Same as the .wd1 it replaces', 'MPEG-1 if it replaces nothing'), @('MPEG-1 video + MP2 sound', 'like videoED.wd1'), @('AVI Cinepak video + PCM sound', 'like the AVI game videos'))
    if (-not $n) { return $false }
    $script:Wd1Format = @('auto', 'mpg', 'avi')[$n - 1]
    $n = Read-Menu 'Picture size' @(@('Same as the .wd1 it replaces', 'else the size of your video'), @('256 x 192', 'in-game briefing videos'), @('640 x 480', ''), @('Type a size', ''))
    if (-not $n) { return $false }
    switch ($n) {
        2 { $script:Width = 256; $script:Height = 192; $script:MenuSet['Width'] = 1 }
        3 { $script:Width = 640; $script:Height = 480; $script:MenuSet['Width'] = 1 }
        4 { $wh = Read-Size 'Size' 4; if ($wh) { $script:Width = $wh[0]; $script:Height = $wh[1]; $script:MenuSet['Width'] = 1 } }
    }
    $n = Read-Menu 'Frame rate' @(@('Same as the .wd1 it replaces', 'else the frame rate of your video'), @('15 fps', ''), @('24 fps', ''), @('25 fps', ''), @('30 fps', ''))
    if (-not $n) { return $false }
    if ($n -gt 1) { $script:Fps = @(0, 0, 15, 24, 25, 30)[$n] }
    $n = Read-Menu 'If the shape is different' @(@('Add black bars', 'keeps the picture shape'), @('Stretch to fill', ''))
    if (-not $n) { return $false }
    $script:Stretch = ($n -eq 2)
    if ($Wd1Format -ne 'avi') {
        $n = Read-Menu 'Picture quality (MPEG-1)' @(@('Very good', 'quantiser 2'), @('Best', 'bigger file (1)'), @('Good', 'smaller (4)'))
        if (-not $n) { return $false }
        $script:Q = @(2, 1, 4)[$n - 1]; $script:MenuSet['Q'] = 1
        $n = Read-Menu 'Sound bitrate (MP2)' @(@('Same as the .wd1 it replaces', 'else 160 kbps'), @('112 kbps', 'like videoED.wd1'), @('160 kbps', ''), @('192 kbps', ''))
        if (-not $n) { return $false }
        if ($n -gt 1) { $script:AudioBitrate = @('', '112k', '160k', '192k')[$n - 1] }
    }
    $n = Read-Menu 'Sound sample rate' @(@('Same as the .wd1 it replaces', 'else 44.1 kHz'), @('22 kHz', 'like the AVI game videos'), @('44.1 kHz', ''))
    if (-not $n) { return $false }
    if ($n -eq 2) { $script:SampleRate = 22050 } elseif ($n -eq 3) { $script:SampleRate = 44100 }
    $f = @{ auto = 'same format as the file it replaces'; mpg = 'MPEG-1 + MP2'; avi = 'AVI Cinepak + PCM' }[$Wd1Format]
    $script:ChoiceText = "converted: $f"
    return $true
}

# ---------------------------------------------------------------- help
function Show-Help {
    Write-Title 'Help'
    Write-Section 'Game file types'
    Write-Note "  .twv   video of the TWV games: KnightShift, World War III: Black Gold,`n         Heli Heroes, Panzer Claws ... (MPEG-1 video inside)"
    Write-Note "  .tws   the sound for the .twv with the same name (MP2 audio inside)"
    Write-Note "  .wd1   Earth 2150 video - really an AVI or MPG file with another name"
    Write-Section 'Original quality vs. converted'
    Write-Note "  Original quality copies the video / sound exactly as it is in the game"
    Write-Note "  file - nothing is lost, and copying a file back gives the identical game"
    Write-Note "  file. Converting re-encodes it: you can pick any format, but some quality"
    Write-Note "  is lost each time."
    Write-Section 'Replacing game files'
    Write-Note "  Options 3-5 ask which game file to replace. The original is kept next to"
    Write-Note "  it as  name.twv.bak / name.tws.bak / name.wd1.bak  - rename it back to undo."
    Write-Note "  For .wd1 files the new video is made to match the one it replaces."
    Write-Section 'Downloads'
    Write-Note "  Converting needs ffmpeg. The first time it is needed it is downloaded"
    Write-Note "  (about 85 MB, checked) into the 'tools' folder next to this script."
    Write-Section 'Choosing files'
    Write-Note "  Drag files or a folder into this window and press Enter. Several files"
    Write-Note "  can be dropped at once, or separated with  |"
    [void](Read-Line "`n  Press Enter to go back")
}

# ---------------------------------------------------------------- file selection

# Splits a typed / dropped line into paths: handles "quoted paths", & 'paths' from
# PowerShell drag-and-drop, several dropped files, and | as separator.
function Split-PathList([string]$line) {
    $out = @()
    foreach ($part in ($line -split '\|')) {
        $tokens = @(); $quoted = @()
        $rx = [regex]'"([^"]*)"|''([^'']*)''|(\S+)'
        foreach ($m in $rx.Matches($part)) {
            if ($m.Groups[1].Success) { $tokens += $m.Groups[1].Value; $quoted += $true }
            elseif ($m.Groups[2].Success) { $tokens += $m.Groups[2].Value; $quoted += $true }
            elseif ($m.Groups[3].Value -ne '&') { $tokens += $m.Groups[3].Value; $quoted += $false }
        }
        $i = 0
        while ($i -lt $tokens.Count) {
            if ($quoted[$i] -or (Test-Path -LiteralPath $tokens[$i])) { $out += $tokens[$i]; $i++; continue }
            # unquoted path with spaces: join words until it names something that exists
            $found = $false
            for ($j = $i + 1; $j -lt $tokens.Count; $j++) {
                $cand = ($tokens[$i..$j]) -join ' '
                if (Test-Path -LiteralPath $cand) { $out += $cand; $i = $j + 1; $found = $true; break }
            }
            if (-not $found) { $out += $tokens[$i]; $i++ }
        }
    }
    return , @($out | Where-Object { $_ })
}

function Read-Inputs([string]$mode) {
    Write-Section 'Which files?'
    Write-Note "Expected: $($script:ActionInputs[$mode])"
    Write-Note 'Drag them (or a folder) into this window and press Enter.  B = back'
    for ($try = 0; $try -lt 20; $try++) {
        $line = Read-Line '  Files'
        if ($null -eq $line) { return $null }
        if ($line -eq '') { continue }
        if ($line.ToUpper() -eq 'B' -or $line.ToUpper() -eq 'Q') { return $null }
        $list = Split-PathList $line
        $missing = @($list | Where-Object { -not (Test-Path -LiteralPath $_) })
        if ($list.Count -and -not $missing.Count) { return , $list }
        foreach ($m in $missing) { Write-Err "not found: $m" }
        Write-Note 'Try again, or type B to go back.'
    }
    return $null
}

# Options 3-5 with one input file: which game file should the result replace?
function Read-ReplaceTarget([string]$mode, [string[]]$inputs) {
    $ext = @{ ToTwv = '.twv'; AudioToTws = '.tws'; ToWd1 = '.wd1' }[$mode]
    Write-Section 'Replace a game file?  (optional)'
    if ($inputs.Count -eq 1 -and (Test-Path -LiteralPath $inputs[0] -PathType Leaf)) {
        Write-Note "Drag the game's $ext file to replace into this window (it is kept as $ext.bak),"
        Write-Note 'drag a folder to save into, or just press Enter to save next to your file.'
        if ($mode -eq 'ToWd1') { Write-Note 'Replacing a .wd1 makes the new video match its format, size and sound.' }
    } else {
        Write-Note 'Drag a folder to save the new files into (files with the same names are'
        Write-Note "replaced and kept as $ext.bak), or just press Enter to save next to each input."
    }
    for ($try = 0; $try -lt 20; $try++) {
        $line = Read-Line '  Replace / save to'
        if ($null -eq $line -or $line -eq '') { return }
        $t = @(Split-PathList $line)
        if ($t.Count -ne 1) { Write-Err 'please give one file or folder'; continue }
        $t = $t[0]
        if (Test-Path -LiteralPath $t -PathType Container) { $script:OutputPath = (Resolve-Path -LiteralPath $t).Path; return }
        if ($inputs.Count -eq 1) {
            $dir = [IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($t))
            if (Test-Path -LiteralPath $dir -PathType Container) { $script:OutputPath = [IO.Path]::ChangeExtension([IO.Path]::GetFullPath($t), $ext); return }
        }
        Write-Err "not found: $t"
    }
}

function Get-SaveToText([string]$mode, [string[]]$inputs) {
    if (-not $OutputPath) { return 'next to each input file' }
    if (Test-Path -LiteralPath $OutputPath -PathType Leaf) { return "$OutputPath  (replaces it; the original is kept as .bak)" }
    return $OutputPath
}

# 'go' | 'back' | 'quit'
function Confirm-Run([string]$mode, [string[]]$inputs) {
    for ($try = 0; $try -lt 20; $try++) {
        Write-Section 'Ready'
        $names = @($inputs | ForEach-Object { if (Test-Path -LiteralPath $_ -PathType Container) { "folder $(Split-Path -Leaf $_)" } else { [IO.Path]::GetFileName($_) } })
        $files = if ($names.Count -le 3) { $names -join ', ' } else { "$($names[0..2] -join ', ') and $($names.Count - 3) more" }
        Write-Host '    Task   : ' -NoNewline -ForegroundColor DarkGray; Write-Host $script:ActionNames[$mode]
        Write-Host '    How    : ' -NoNewline -ForegroundColor DarkGray; Write-Host $script:ChoiceText
        Write-Host '    Files  : ' -NoNewline -ForegroundColor DarkGray; Write-Host $files
        Write-Host '    Save to: ' -NoNewline -ForegroundColor DarkGray; Write-Host (Get-SaveToText $mode $inputs)
        Write-Host ''
        Write-Host '  Enter' -NoNewline -ForegroundColor Green; Write-Host ' = start    ' -NoNewline
        if ($mode -ne 'Info') { Write-Host 'S' -NoNewline -ForegroundColor Yellow; Write-Host ' = save somewhere else    ' -NoNewline }
        Write-Host 'B' -NoNewline -ForegroundColor Yellow; Write-Host ' = back to the menu    ' -NoNewline
        Write-Host 'Q' -NoNewline -ForegroundColor Yellow; Write-Host ' = quit'
        $v = Read-Line '  Your choice (Enter = start)'
        if ($null -eq $v) { return 'quit' }
        switch ($v.ToUpper()) {
            ''  { return 'go' }
            'B' { return 'back' }
            'Q' { return 'quit' }
            'S' {
                if ($mode -eq 'Info') { continue }
                $l = Read-Line '  Drag a folder here (or type one; it is created if needed)'
                if ($l) {
                    $t = @(Split-PathList $l)
                    if ($t.Count -eq 1) { $script:OutputPath = [IO.Path]::GetFullPath($t[0]) }
                }
            }
            default { Write-Err 'press Enter, S, B or Q' }
        }
    }
    return 'quit'
}

# ---------------------------------------------------------------- main menu
function Show-Menu {
    Clear-Screen
    Write-Title 'Reality Pump / TopWare - Media Converter'
    Write-Note "Videos and sounds of the TWV games (KnightShift, World War III, Heli Heroes,`nPanzer Claws ...) and Earth 2150."
    Write-Section 'Get media OUT of the game  (to watch, share or edit)'
    Write-Item '1' 'Game video  -> normal video' '.twv  .wd1   ->  .avi  .mpg  .mkv  .mp4 ...'
    Write-Item '2' 'Game sound  -> normal audio' '.tws  .wd1   ->  .wav  .mp3  .flac ...'
    Write-Section 'Make files FOR the game  (to mod or replace)'
    Write-Item '3' 'Video -> TWV + TWS           (TWV games)' 'any video  ->  .twv + .tws'
    Write-Item '4' 'Audio -> TWS                 (TWV games)' 'any audio  ->  .tws'
    Write-Item '5' 'Video -> WD1                 (Earth 2150)' 'any video  ->  .wd1'
    Write-Section 'Other'
    Write-Item 'I' 'Inspect files - show what is inside, change nothing'
    Write-Item 'H' 'Help - file types, original quality, backups'
    Write-Item 'Q' 'Quit'
    $c = Read-Choice @('1', '2', '3', '4', '5', 'I', 'H', 'Q') ''
    switch ($c) { '1' { 'ToMp4' } '2' { 'TwsToAudio' } '3' { 'ToTwv' } '4' { 'AudioToTws' } '5' { 'ToWd1' } 'I' { 'Info' } 'H' { 'Help' } default { $null } }
}

# remember the start-up settings so every menu round starts from the defaults
$script:DefaultNames = @('Container', 'VideoCodec', 'AudioCodec', 'Crf', 'Preset', 'VideoBitrate', 'OutSize', 'Audio', 'NoAudio',
    'M1v', 'Info', 'AudioBitrate', 'SampleRate', 'Channels', 'Width', 'Height', 'Stretch', 'Q', 'TwsBitrate', 'TwsSampleRate',
    'TwsChannels', 'NoTws', 'Reencode', 'AudioFormat', 'Wd1Format', 'Fps', 'OutputPath')
$script:Defaults = @{}
foreach ($n in $script:DefaultNames) { $script:Defaults[$n] = (Get-Variable -Name $n -Scope Script).Value }
$script:DoubleSize = $false; $script:ChoiceText = ''

function Restore-Defaults {
    foreach ($n in $script:DefaultNames) { Set-Variable -Name $n -Scope Script -Value $script:Defaults[$n] }
    foreach ($n in @('ForceVideoEncode', 'ForceAudioEncode', 'MenuSet', 'CrfAuto')) {
        Remove-Variable -Name $n -Scope Script -ErrorAction SilentlyContinue
    }
    $script:ChoiceText = ''; $script:DoubleSize = $false
}

function Invoke-Interactive {
    while ($true) {
        Restore-Defaults
        $mode = Show-Menu
        if (-not $mode) { return 0 }
        if ($mode -eq 'Help') { Show-Help; if ($script:NoInput) { return 0 }; continue }
        $ok = switch ($mode) {
            'ToMp4'      { Show-VideoOptions }
            'TwsToAudio' { Show-AudioOptions }
            'ToTwv'      { Show-TwvOptions }
            'AudioToTws' { Show-TwsOptions }
            'ToWd1'      { Show-Wd1Options }
            'Info'       { $script:Info = $true; $script:ChoiceText = 'show what is inside, change nothing'; $true }
        }
        if ($script:NoInput) { return 0 }
        if (-not $ok) { continue }
        $inputs = Read-Inputs $mode
        if ($script:NoInput -and -not $inputs) { return 0 }
        if (-not $inputs) { continue }
        if (@('ToTwv', 'AudioToTws', 'ToWd1') -contains $mode) { Read-ReplaceTarget $mode $inputs }
        $go = Confirm-Run $mode $inputs
        if ($go -eq 'quit') { return 0 }
        if ($go -eq 'back') { continue }
        Write-Host ''
        $runMode = if ($mode -eq 'Info') { 'Auto' } else { $mode }
        try { Resolve-Settings; [void](Invoke-Jobs $runMode $inputs) } catch { Write-Err $_.Exception.Message }
        $a = Read-Line "`n  Finished. Press Enter for the menu, or Q to quit"
        if ($null -eq $a -or $a.ToUpper() -eq 'Q') { return 0 }
    }
}

function Invoke-Main {
    if (-not $InputPath -or $InputPath.Count -eq 0) { return (Invoke-Interactive) }
    $inputs = @($InputPath | ForEach-Object { Clear-PathText $_ } | Where-Object { $_ })
    Resolve-Settings
    $failed = Invoke-Jobs $Mode $inputs
    if ($failed) { return 1 } else { return 0 }
}

# Runs one batch. Returns the number of failed files.
function Invoke-Jobs([string]$mode, [string[]]$inputs) {
    $missing = @($inputs | Where-Object { -not (Test-Path -LiteralPath $_) })
    foreach ($m in $missing) { Write-Err "not found: $m" }
    if ($missing.Count) { return 1 }
    $expect = @{ ToMp4 = 'a game video (.twv / .wd1)'; ToTwv = 'a video file'; TwsToAudio = 'a game sound (.tws / .wd1)'
                 AudioToTws = 'an audio or video file'; ToWd1 = 'a video file' }

    # build job list: @{ Path; Dir = ToMp4 | ToTwv | TwsToAudio | AudioToTws | ToWd1 }
    $jobs = @()
    $outIsDir = ($inputs.Count -gt 1) -or [bool]($inputs | Where-Object { Test-Path -LiteralPath $_ -PathType Container })
    foreach ($i in $inputs) {
        if (Test-Path -LiteralPath $i -PathType Container) {
            $dirMode = if ($mode -eq 'Auto') { 'ToMp4' } else { $mode }
            foreach ($f in (Get-ChildItem -LiteralPath $i -File | Sort-Object Name)) {
                $ext = $f.Extension.ToLower()
                $take = switch ($dirMode) {
                    'ToMp4'      { $ext -eq '.twv' -or $ext -eq '.wd1' -or ($Info -and $ext -eq '.tws') }
                    'ToTwv'      { $script:VideoExt -contains $ext }
                    'TwsToAudio' { $ext -eq '.tws' -or $ext -eq '.wd1' }
                    'AudioToTws' { $script:AudioExt -contains $ext }
                    'ToWd1'      { $script:VideoExt -contains $ext }
                }
                if ($take) {
                    $d = if ($Info -and $ext -eq '.tws') { 'TwsToAudio' } else { $dirMode }
                    $jobs += @{ Path = $f.FullName; Dir = $d }
                }
            }
            if (-not $take -and -not $jobs.Count) { Write-Warn2 "$($i): no matching files in this folder" }
        } else {
            $full = (Resolve-Path -LiteralPath $i).Path
            $ext = [IO.Path]::GetExtension($full).ToLower()
            $kind = if ($ext -eq '.twv') { 'twv' } elseif ($ext -eq '.tws') { 'tws' } elseif ($ext -eq '.wd1') { 'wd1' }
                    elseif ($script:AudioExt -contains $ext) { 'audio' } else { 'video' }
            $dir = $mode
            if ($dir -eq 'Auto') {
                $dir = switch ($kind) { 'twv' { 'ToMp4' } 'wd1' { 'ToMp4' } 'tws' { 'TwsToAudio' } 'audio' { 'AudioToTws' } default { 'ToTwv' } }
            }
            if ($Info -and @('ToMp4', 'TwsToAudio') -notcontains $dir) {
                Write-Warn2 "$([IO.Path]::GetFileName($full)): not a game file (.twv / .tws / .wd1) - nothing to inspect"; continue
            }
            if ($dir -eq 'ToMp4' -and $kind -eq 'tws') {      # TWS given for game video: use its .twv
                $tw = Find-Sibling $full '.twv'
                if (-not $tw) { Write-Err "${full}: no matching .twv next to this .tws (use 'game sound -> normal audio' for sound only)"; continue }
                $full = $tw; $kind = 'twv'
            }
            $bad = switch ($dir) {
                'ToMp4'      { $kind -ne 'twv' -and $kind -ne 'wd1' }
                'ToTwv'      { $kind -ne 'video' -and $kind -ne 'wd1' }
                'TwsToAudio' { $kind -ne 'tws' -and $kind -ne 'wd1' }
                'AudioToTws' { $kind -eq 'twv' -or $kind -eq 'tws' }
                'ToWd1'      { $kind -ne 'video' -and $kind -ne 'wd1' }
            }
            if ($bad) { Write-Warn2 "$([IO.Path]::GetFileName($full)): is not $($expect[$dir]) - skipped"; continue }
            $jobs += @{ Path = $full; Dir = $dir }
        }
    }

    $failed = 0
    $seen = New-Object "System.Collections.Generic.Dictionary[string,string]" ([StringComparer]::Ordinal)
    foreach ($j in $jobs) {
        $f = $j.Path
        $isWd1 = [IO.Path]::GetExtension($f).ToLower() -eq '.wd1'
        $ext = switch ($j.Dir) {
            'ToTwv'      { '.twv' }
            'ToWd1'      { '.wd1' }
            'AudioToTws' { '.tws' }
            'ToMp4'      { if ($Container -ne 'raw') { '.' + $Container }
                           elseif ($isWd1) { $k = Get-Wd1Kind $f; if ($k) { '.' + $k.Ext } else { '.avi' } }
                           else { '.m1v' } }
            'TwsToAudio' { if ($AudioFormat -eq 'raw') { '.mp2' } else { '.' + $AudioFormat } }    # .wd1: final extension set by the converter
        }
        $base = [IO.Path]::GetFileNameWithoutExtension($f) + $ext
        if ($OutputPath -and -not $outIsDir -and [IO.Path]::HasExtension($OutputPath) -and -not (Test-Path -LiteralPath $OutputPath -PathType Container)) {
            $out = $OutputPath
        } else {
            $d = if ($OutputPath) { $OutputPath } else { [IO.Path]::GetDirectoryName($f) }
            if (-not $Info -and -not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
            $out = Join-Path $d $base
        }
        $out = [IO.Path]::GetFullPath($out)
        if (-not $Info) {
            if ($out -eq [IO.Path]::GetFullPath($f)) { Write-Err "${f}: the result would overwrite this file - choose another place to save"; $failed++; continue }
            $key = if ($script:OnWindows) { $out.ToLower() } else { $out }
            if ($seen.ContainsKey($key)) { Write-Err "${f}: same output as $($seen[$key]) - skipped (rename one, or save somewhere else)"; $failed++; continue }
            $seen[$key] = $f
        }
        if ($script:DoubleSize -and $j.Dir -eq 'ToMp4') { Set-DoubleSize $f }
        try {
            $ok = switch ($j.Dir) {
                'ToTwv'      { Convert-ToTwv $f $out }
                'ToMp4'      { Convert-ToMp4 $f $out }
                'TwsToAudio' { Convert-TwsToAudio $f $out }
                'AudioToTws' { Convert-AudioToTws $f $out }
                'ToWd1'      { Convert-ToWd1 $f $out }
            }
        } catch {
            Write-Err "${f}: $($_.Exception.Message)"
            $ok = $false
        }
        if (-not $ok) { $failed++ }
    }
    if ($jobs.Count -gt 1) {
        Write-Host ''
        Write-Host ('Summary: {0} OK, {1} failed (of {2} files)' -f ($jobs.Count - $failed), $failed, $jobs.Count)
    }
    if ($jobs.Count -eq 0) { Write-Err 'no files to convert'; $failed = 1 }
    return $failed
}

# "Double size" from the advanced menu: per file, since sizes differ
function Set-DoubleSize([string]$f) {
    $w = 0; $h = 0
    if ([IO.Path]::GetExtension($f).ToLower() -eq '.wd1') {
        $k = Get-Wd1Kind $f
        if ($k -and $k.Ext -eq 'avi') { $i = Get-AviInfo $f; $w = $i.W; $h = $i.H }
        elseif ($k) { $i = Get-PsInfo $f; $w = $i.W; $h = $i.H }
    } else {
        try { $hd = Read-TwvHeader (Expand-MaybeZlib ([IO.File]::ReadAllBytes($f))); $w = $hd.W; $h = $hd.H } catch { }
    }
    $script:OutSize = if ($w -gt 0) { "$($w * 2)x$($h * 2)" } else { '' }
}

$script:BigFast = Test-BigFast
if (-not $script:BigFast) { Write-Info 'using compatibility mode for bit operations (slower)' }
try { $code = Invoke-Main } catch { Write-Err $_.Exception.Message; $code = 1 }
exit $code
