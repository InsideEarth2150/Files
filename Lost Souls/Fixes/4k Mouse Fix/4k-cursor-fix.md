# Reality Pump Earth-engine games — 4K cursor fix

Confirmed working in-game on Earth 2150: The Moon Project 2.2.2.3 (2026-10-11). The other builds use the same patch, but it hasn't yet been tested in-game on them.

## Root cause
The game draws the cursor as two triangles. The Direct3D renderer's triangle functions skip the whole triangle if any corner has Y outside ±2000.0, read from a shared .rdata constant. X is checked against a limit that depends on screen width, which is why only the bottom edge was affected. In The Moon Project the cursor reaches about 56px below its tip, so it vanished once the tip passed Y≈1944. That's why 1944 never appeared in the binary.

## Patch (same technique for every build)
Every `fcomp dword ptr [<2000.0>]` (D8 1D) in the Direct3D renderer that checks a vertex Y now points at an existing 4096.0 constant in the same exe's .rdata. No new code or data, no header edits, same file size. The 2000.0 constant itself is never edited.

| Game / file | Version | 2000.0 const | 4096.0 const | Sites (renderer range) | Original SHA256 | Patched SHA256 |
|---|---|---|---|---|---|---|
| TheMoonProject.exe | 2.2.2.3 | 0x758284 | 0x75802C | 21 (0x5C3D31–0x5C544D) | 2a130d07…f99e25 | 59391bf1…064dfd |
| TheMoonProject.exe | 2.2.2.5 | 0x758284 | 0x75802C | 21 (identical code to 2.2.2.3) | dc6049fd…c1c10f | e0b4bb03…60c5a8 |
| WW3.exe (World War III: Black Gold) | 1.2.0.0 | 0x82A3A8 | 0x829D2C | 24 (D3D8 renderer 0x717C21–0x7196B8) | 530fbf47…99fd3b | d7e5586f…ec9a2e |
| PanzerClawsII.ex1 | 1.3.0.0 | 0x7F01C0 | 0x7EC1B8 | 31 (0x6C12D1–0x6C4878) | 73f97955…acdde3 | 0ffc7ae9…59de5b |
| PanzerClawsII.ex2 | 1.3.0.0 | 0x8281D0 | 0x8241D8 | 31 (0x6BF671–0x6C33E8) | cdc00616…a25aac2 | 675578d2…37e48c7 |

The full hashes and every patch file offset are in the scripts (Apply-4KCursorFix.ps1 / apply-4k-cursor-fix.sh). Both scripts were generated from the same build table and tested against all five builds.

## Do not change (other code uses the same 2000.0 constant)
- The Moon Project: sound volume (0x688A2E, 0x688A79, as 2000 × log10 of the volume).
- WW3: two `fmul` uses at 0x6B598E and 0x6B59D9 (probably also volume).
- PanzerClawsII.ex1: 20 `fadd [2000.0]` uses that compute the X limit (screen width + 2000). Left alone: X already works.

## Not patched
- The Moon Project: the Glide (0x5E5990 family) and OpenGL (0x5FB620 family) renderers.
- WW3: Glide renderer (48 sites, 0x735xxx–0x739xxx; its init references "Graphics\Glide") and OpenGL renderer (48 sites, 0x758xxx–0x75Axxx). OpenGL also applies the 2000 limit to X.
- The Panzer Claws II exes only contain a single (D3D8) renderer, and all of their Y checks are patched.

## Scripts
- Apply-4KCursorFix.cmd launches Apply-4KCursorFix.ps1 with the execution policy bypassed. Running a .ps1 directly fails under a signing policy, and a .ps1 "runner" wrapper doesn't help because it gets blocked too.
- apply-4k-cursor-fix.sh is pure bash with no Python.
- Each script patches every supported file it finds in its own folder, identifies the build by SHA256, checks every site before writing, backs up to <file>.orig-4kcursor.bak, verifies the patched hash (restoring the backup on a mismatch), and supports undo with -Restore / --restore. It refuses to proceed if an existing backup comes from a different build.

## Earlier dead ends (The Moon Project)
- 0x67B5E0, 0x668F90 and the 0x67B7A0–0x67BF30 family are UI input/message dispatch, not drawing. 0x10F, 0x24 and 0x25 are message/event codes.
- The "vtable[0x60] render chain" (0x637260 → 0x6377B0) is a WM_TIMER (0x113) broadcast to UI layers.
- Changing the cursor-mode init gate always crashes at 4K (null pointer read at [0xa5e418]).
