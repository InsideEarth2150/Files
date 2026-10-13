#Requires -Version 5.1
<#
.SYNOPSIS
  4K cursor fix for Reality Pump Earth-engine games.

.DESCRIPTION
  Supported:
    Earth 2150: The Moon Project (TheMoonProject.exe 2.2.2.3 / 2.2.2.5)
    World War III: Black Gold    (WW3.exe 1.2.0.0)
    WWII: Panzer Claws II        (PanzerClawsII.ex1 / PanzerClawsII.ex2 1.3.0.0)

  Root cause: the Direct3D renderer drops any triangle with a vertex Y > 2000.0. The cursor is
  drawn as two triangles, so at 3840x2160 it vanishes near the bottom of the screen.
  Fix: repoint the Direct3D renderer's Y-bound checks (fcomp dword ptr [2000.0]) to an existing
  4096.0 constant in the same exe. The 2000.0 constant itself is untouched (other code uses it).

  Place this script in the game folder. It patches every supported exe it finds next to itself,
  identified by SHA256; unknown versions are refused untouched.
  On Windows, run it via Apply-4KCursorFix.cmd (bypasses the script signing policy).

.EXAMPLE
  .\Apply-4KCursorFix.ps1
.EXAMPLE
  .\Apply-4KCursorFix.ps1 -Restore
#>
[CmdletBinding()]
param([switch]$Restore)

$ErrorActionPreference = 'Stop'

$Builds = @(
    @{ File = 'TheMoonProject.exe'; Version = '2.2.2.3'
       Orig    = '2A130D074536B224F2952AB66E615F25DB1A8797522E05E2A7FC92C780F99E25'
       Patched = '59391BF1C0DD63BEAB83078EB62D4EA7D5EE3EA1D0AADCA0EACB042642064DFD'
       Old = [byte[]](0x84, 0x82, 0x75, 0x00); New = [byte[]](0x2C, 0x80, 0x75, 0x00)
       Offsets = @(
                   0x1C3D33, 0x1C3DAF, 0x1C3E2B, 0x1C40C3, 0x1C413F, 0x1C41BB, 0x1C4462, 0x1C44DE,
                   0x1C455A, 0x1C485E, 0x1C48D7, 0x1C4950, 0x1C4C02, 0x1C4C7E, 0x1C4CFA, 0x1C4F92,
                   0x1C500E, 0x1C508A, 0x1C535D, 0x1C53D6, 0x1C544F
       ) },
    @{ File = 'TheMoonProject.exe'; Version = '2.2.2.5'
       Orig    = 'DC6049FD5BFDA5EA5706929FABB06DB0024EA1E268DC1ECC031FCFE4AAF1C10F'
       Patched = 'E0B4BB032CB58DC0D6D86A6C772111CFFFC1752AA2DB26B5E6E77D432760C5A8'
       Old = [byte[]](0x84, 0x82, 0x75, 0x00); New = [byte[]](0x2C, 0x80, 0x75, 0x00)
       Offsets = @(
                   0x1C3D33, 0x1C3DAF, 0x1C3E2B, 0x1C40C3, 0x1C413F, 0x1C41BB, 0x1C4462, 0x1C44DE,
                   0x1C455A, 0x1C485E, 0x1C48D7, 0x1C4950, 0x1C4C02, 0x1C4C7E, 0x1C4CFA, 0x1C4F92,
                   0x1C500E, 0x1C508A, 0x1C535D, 0x1C53D6, 0x1C544F
       ) },
    @{ File = 'WW3.exe'; Version = '1.2.0.0'
       Orig    = '530FBF4709B47CBE0EEB7D4F3F778E74C2317D9DC82A5A6FB21D31AB8199FD3B'
       Patched = 'D7E5586F8FEBC6D6A468C30D9D7D7A9A06F3E6EDB96CB968235D22167DEC9A2E'
       Old = [byte[]](0xA8, 0xA3, 0x82, 0x00); New = [byte[]](0x2C, 0x9D, 0x82, 0x00)
       Offsets = @(
                   0x317C23, 0x317C9F, 0x317D1B, 0x317FB3, 0x31802F, 0x3180AB, 0x318352, 0x3183CE,
                   0x31844A, 0x31873E, 0x3187B7, 0x318830, 0x318AD2, 0x318B4E, 0x318BCA, 0x318E62,
                   0x318EDE, 0x318F5A, 0x31922D, 0x3192A6, 0x31931F, 0x3195C2, 0x31963E, 0x3196BA
       ) },
    @{ File = 'PanzerClawsII.ex1'; Version = '1.3.0.0'
       Orig    = '73F9795512DEC21495AE85932256B7893865080729A1D4498603292CD7ACDDE3'
       Patched = '0FFC7AE90357FEF7155F890D55386450CCDD5E048ACB51F13B2EC39B1F59DE5B'
       Old = [byte[]](0xC0, 0x01, 0x7F, 0x00); New = [byte[]](0xB8, 0xC1, 0x7E, 0x00)
       Offsets = @(
                   0x2C12D3, 0x2C134F, 0x2C13CB, 0x2C1653, 0x2C16CF, 0x2C174B, 0x2C19E2, 0x2C1A5E,
                   0x2C1ADA, 0x2C1DCE, 0x2C1E47, 0x2C1EC0, 0x2C2152, 0x2C21CE, 0x2C224A, 0x2C24D2,
                   0x2C254E, 0x2C25CA, 0x2C2F62, 0x2C2FDD, 0x2C3058, 0x2C35D9, 0x2C3654, 0x2C36CF,
                   0x2C374A, 0x2C43ED, 0x2C4466, 0x2C44DF, 0x2C4782, 0x2C47FE, 0x2C487A
       ) },
    @{ File = 'PanzerClawsII.ex2'; Version = '1.3.0.0'
       Orig    = 'CDC00616F510C29EF1C55EECC0118D3AE2721B87F1C294EDC9C935641A25AAC2'
       Patched = '675578D20AA912BEA63FC975600D7535C6DF1B0081AAF15CDED89B1D137E48C7'
       Old = [byte[]](0xD0, 0x81, 0x82, 0x00); New = [byte[]](0xD8, 0x41, 0x82, 0x00)
       Offsets = @(
                   0x2BF673, 0x2BF6EF, 0x2BF76B, 0x2BFAD8, 0x2BFB54, 0x2BFBD0, 0x2BFF62, 0x2BFFDE,
                   0x2C005A, 0x2C043E, 0x2C04B7, 0x2C0530, 0x2C08B7, 0x2C0933, 0x2C09AF, 0x2C0D2A,
                   0x2C0DA6, 0x2C0E22, 0x2C1932, 0x2C19AD, 0x2C1A28, 0x2C1F39, 0x2C1FB4, 0x2C202F,
                   0x2C20AA, 0x2C2E6D, 0x2C2EE6, 0x2C2F5F, 0x2C32F2, 0x2C336E, 0x2C33EA
       ) }
)

function Write-Ok   ($m) { Write-Host "[ OK ] $m" -ForegroundColor Green }
function Write-Warn ($m) { Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Write-Fail ($m) { Write-Host "[FAIL] $m" -ForegroundColor Red }
function Get-Sha256 ($p) { (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToUpperInvariant() }

function Restore-One ($exe, $name) {
    $bak = "$exe.orig-4kcursor.bak"
    if (-not (Test-Path -LiteralPath $bak)) { Write-Warn "${name}: no backup found, skipped"; return $true }
    $h = Get-Sha256 $bak
    $b = $Builds | Where-Object { $_.File -eq $name -and $_.Orig -eq $h } | Select-Object -First 1
    if (-not $b) { Write-Fail "${name}: backup does not match a known original; not restoring"; return $false }
    Copy-Item -LiteralPath $bak -Destination $exe -Force
    Write-Ok "${name}: restored original $($b.Version)"
    return $true
}

function Patch-One ($exe, $name) {
    $bak = "$exe.orig-4kcursor.bak"
    $cur = Get-Sha256 $exe
    $done = $Builds | Where-Object { $_.File -eq $name -and $_.Patched -eq $cur } | Select-Object -First 1
    if ($done) { Write-Ok "${name}: already patched ($($done.Version))"; return $true }
    $b = $Builds | Where-Object { $_.File -eq $name -and $_.Orig -eq $cur } | Select-Object -First 1
    if (-not $b) { Write-Fail "${name}: unknown version (SHA256 $cur); nothing changed"; return $false }
    Write-Ok "${name}: version $($b.Version) verified (SHA256 match)"

    $bytes = [System.IO.File]::ReadAllBytes($exe)
    foreach ($off in $b.Offsets) {
        $good = ($bytes[$off - 2] -eq 0xD8) -and ($bytes[$off - 1] -eq 0x1D)
        for ($i = 0; $i -lt 4; $i++) { if ($bytes[$off + $i] -ne $b.Old[$i]) { $good = $false } }
        if (-not $good) { Write-Fail ("{0}: unexpected bytes at 0x{1:X6}; nothing changed" -f $name, $off); return $false }
    }

    if (Test-Path -LiteralPath $bak) {
        if ((Get-Sha256 $bak) -ne $b.Orig) { Write-Fail "${name}: existing backup is a different file ($bak) - move it away and re-run; nothing changed"; return $false }
        Write-Warn "${name}: backup already exists, leaving it as is"
    } else {
        Copy-Item -LiteralPath $exe -Destination $bak
        Write-Ok "${name}: backup written to $(Split-Path -Leaf $bak)"
    }

    foreach ($off in $b.Offsets) { for ($i = 0; $i -lt 4; $i++) { $bytes[$off + $i] = $b.New[$i] } }
    try { [System.IO.File]::WriteAllBytes($exe, $bytes) }
    catch { Copy-Item -LiteralPath $bak -Destination $exe -Force -ErrorAction SilentlyContinue
            Write-Fail "${name}: write failed (is the game running?) - $($_.Exception.Message)"; return $false }

    if ((Get-Sha256 $exe) -ne $b.Patched) {
        Copy-Item -LiteralPath $bak -Destination $exe -Force
        Write-Fail "${name}: patched hash mismatch; original restored"; return $false
    }
    Write-Ok "${name}: patched $($b.Offsets.Count) sites"
    return $true
}

$names = $Builds | ForEach-Object { $_.File } | Select-Object -Unique
$found = 0; $failed = 0
foreach ($n in $names) {
    $exe = Join-Path $PSScriptRoot $n
    if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) { continue }
    $found++
    $r = if ($Restore) { Restore-One $exe $n } else { Patch-One $exe $n }
    if (-not $r) { $failed++ }
}

if ($found -eq 0) { Write-Fail "No supported exe found next to this script in $PSScriptRoot (looked for: $($names -join ', '))"; exit 1 }
if ($failed -gt 0) { Write-Fail "$failed file(s) failed - see messages above"; exit 1 }
Write-Ok "Done ($found file(s)). Undo with: Apply-4KCursorFix.cmd -Restore"
