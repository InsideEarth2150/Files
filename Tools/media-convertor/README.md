# Reality Pump / TopWare - Media Converter

Converts Reality Pump / TopWare cutscenes and their sound:
**TWV/TWS** (KnightShift, World War III: Black Gold, Heli Heroes, Panzer Claws, ...) and
**Earth 2150 `.wd1`** videos. It started as a PowerShell port of `twv2mp4-v4.py` and
works in Windows PowerShell 5.1 and PowerShell 7+.

## Files

|File|What it is|
|-|-|
|`Reality\_Pump\_-\_TopWare\_-\_Media\_Converter.cmd`|The launcher. Double-click it for the menu, or drag files / folders onto it|
|`RP-TW-Media-Converter.ps1`|The converter itself; can also be run from a PowerShell prompt|
|`README.md`|This file|
|`tools\\`|Created on first use if ffmpeg has to be downloaded|

Keep the `.cmd` and the `.ps1` in the same folder. The launcher runs the script by
name, so if you rename the `.ps1`, change the name inside the `.cmd` as well.

## Defaults = raw conversions

By default every option **keeps the original streams and their settings**.
Nothing is re-encoded, and none of the defaults need ffmpeg.

|Menu|Default (raw)|Other choices|
|-|-|-|
|1 game video -> video|`.twv` -> `.m1v` + `.tws` -> `.mp2`; `.wd1` -> the `.avi` / `.mpg` it really is (byte copy)|`.mpg` / `.mkv` / `.mp4` / `.mov` / `.avi` with the original streams where the container allows it, or re-encoded H.264 / H.265 / VP9 / AV1 / MPEG-1 + AAC / MP3 / MP2 / Opus / Vorbis / FLAC / PCM, or WebM|
|2 game sound -> audio|`.tws` -> `.mp2`; `.wd1` -> its own track (`.wav` for PCM, `.mp2` for MP2), copied|WAV, FLAC, MP3, M4A, OGG, Opus, or MP2 at a new bitrate|
|3 video -> TWV/TWS|MPEG-1 I-frame video is copied into the `.twv`, MP2 audio is copied into the `.tws`|re-encode with your own frame rate, size, quality and TWS settings|
|4 audio -> TWS|MP2 audio is copied into the `.tws` as is|re-encode with your own bitrate, channels and sample rate|
|5 video -> WD1|an AVI / MPG the game can play (Cinepak / Indeo AVI, MPEG-1 MPG) is copied in as is|re-encode as MPEG-1 + MP2 or AVI Cinepak + PCM|

The raw path is exact in both directions. TWV -> `.m1v` + `.mp2` -> TWV + TWS gives back
the game's original files byte for byte (tested on Intro2/4/5). That holds for the `.mpg`,
`.mkv` and `.mp4` copy outputs of menu 1 too. WD1 -> `.avi` / `.mpg` -> WD1 is a plain
byte copy each way.

If a source can't be copied, menu options 3 and 4 say why and encode it with **the game's
own settings** instead: 640x256, source frame rate, MPEG-1 quantiser 1 (what the
originals mostly use), MP2 160k 44.1 kHz stereo. Examples are H.264 video, an MPEG-1
file with P/B-frames, or MP3/AAC audio.

## Earth 2150 `.wd1` videos

A `.wd1` video isn't a special format. It's an ordinary **AVI** (Cinepak or Indeo 5
video, PCM audio) or **MPEG-1 system stream** (MPEG-1 video, MP2 audio) with another
extension. The script recognises which by its content.

* **Export** (menu 1): by default you get the file under its real extension, unchanged.
It plays in VLC or MPC-HC. Other containers copy the streams where they can. MP4 can't
hold Cinepak, Indeo or PCM, so those parts are re-encoded (H.264 / AAC) and the
script says so.
* **Import** (menu 5): name the output after the file you are replacing, e.g.
`-OutputPath C:\\Earth2150\\Video\\VideoUCS.wd1`. If the source can't be copied in as is,
the script encodes it to **match the `.wd1` already there**: its container,
frame size, frame rate, audio sample rate and channels (and MP2 bitrate). With nothing
to replace, the default is MPEG-1 + MP2 at the source size. The original is backed up
to `.wd1.bak` first.
* **Indeo 5** can be read but not written: ffmpeg has no Indeo encoder. A replacement for
an Indeo file is encoded as Cinepak AVI (same container, size and audio). Use
`-Wd1Format mpg` for MPEG-1 instead.
* `-Mode ToWd1 VideoUCS.wd1 -Wd1Format mpg -OutputPath fixed` re-encodes a game file
itself, e.g. turning an Indeo video into MPEG-1.

## Usage

* **Double-click `Reality\_Pump\_\_\_TopWare\_-\_Media\_Converter.cmd`** for the menu:

```
  Get media OUT of the game  (to watch, share or edit)
    1) Game video  -> normal video      .twv .wd1  ->  .avi .mpg .mkv .mp4 ...
    2) Game sound  -> normal audio      .tws .wd1  ->  .wav .mp3 .flac ...
  Make files FOR the game  (to mod or replace)
    3) Video -> TWV + TWS   (TWV games)
    4) Audio -> TWS         (TWV games)
    5) Video -> WD1         (Earth 2150)
  Other
    I) Inspect files    H) Help    Q) Quit
  ```

  Each task then asks, in this order:

  1. **How?** Numbered choices in plain words. The default (marked `<- Enter`) is always
"original quality" / "automatic".
  2. **Which files?** Drag files or a folder into the window. Several can be dropped at once.
  3. **Replace a game file?** (menu 3-5 only). Drag the game file to replace; the original
is kept as `.bak`. For `.wd1` this also makes the new video match it.
  4. **Ready.** A summary of what will happen. Enter starts, `S` picks another place to
save, `B` goes back.

  After each job you're back at the menu. `B` goes back from any question.

* **Drag files onto `Reality\_Pump\_\_\_TopWare\_-\_Media\_Converter.cmd`**: raw defaults, picked by extension:
`.twv` -> `.m1v` + `.mp2`, `.wd1` -> `.avi` / `.mpg`, `.m1v`/`.mpg`/other video -> `.twv` + `.tws`,
`.tws` -> `.mp2`, `.mp2`/other audio -> `.tws`. Making a `.wd1` is menu 5, or `-Mode ToWd1`.
* **Command line**:

```powershell
# menu 1: game video -> video
.\\RP-TW-Media-Converter.ps1 .\\Intro2.twv                                    # raw .m1v + .mp2
.\\RP-TW-Media-Converter.ps1 .\\Intro2.twv -Container mpg                     # original streams, one file
.\\RP-TW-Media-Converter.ps1 .\\Intro2.twv -Container mp4 -VideoCodec h264 -AudioCodec aac   # plays everywhere
.\\RP-TW-Media-Converter.ps1 .\\Intro2.twv -Container mp4 -VideoCodec h265 -Crf 20 -AudioCodec aac -AudioBitrate 256k
.\\RP-TW-Media-Converter.ps1 .\\Intro2.twv -Container mkv -VideoCodec h264 -OutSize 1280x512
.\\RP-TW-Media-Converter.ps1 C:\\Game\\Video -OutputPath C:\\Out                # whole folder

# menu 3: video -> TWV/TWS
.\\RP-TW-Media-Converter.ps1 .\\Intro2.m1v                                    # raw: uses Intro2.mp2 beside it
.\\RP-TW-Media-Converter.ps1 .\\MyIntro.mp4                                   # H.264 source: encoded, game settings
.\\RP-TW-Media-Converter.ps1 .\\MyIntro.mp4 -Reencode -Q 2 -TwsBitrate 128k

# menu 2: game sound -> audio
.\\RP-TW-Media-Converter.ps1 .\\Intro2.tws                                    # raw .mp2
.\\RP-TW-Media-Converter.ps1 .\\Intro2.tws -AudioFormat flac
.\\RP-TW-Media-Converter.ps1 .\\Intro2.tws -AudioFormat mp3 -AudioBitrate 320k

# menu 1 / 2 with Earth 2150 files
.\\RP-TW-Media-Converter.ps1 .\\VideoUCS.wd1                                  # raw: VideoUCS.avi, unchanged
.\\RP-TW-Media-Converter.ps1 .\\VideoUCS.wd1 -Container mkv                   # Indeo + PCM copied into MKV
.\\RP-TW-Media-Converter.ps1 .\\VideoUCS.wd1 -Container mp4                   # H.264 + AAC (MP4 can't hold Indeo)
.\\RP-TW-Media-Converter.ps1 -Mode TwsToAudio .\\VideoUCS.wd1                 # raw soundtrack: VideoUCS.wav

# menu 5: video -> WD1
.\\RP-TW-Media-Converter.ps1 -Mode ToWd1 .\\VideoUCS.avi                      # raw: byte copy back to .wd1
.\\RP-TW-Media-Converter.ps1 -Mode ToWd1 .\\New.mp4 -OutputPath C:\\Earth2150\\Video\\videoED.wd1   # matches videoED
.\\RP-TW-Media-Converter.ps1 -Mode ToWd1 .\\New.mp4 -Wd1Format avi -Width 640 -Height 320

# menu 4: audio -> TWS
.\\RP-TW-Media-Converter.ps1 .\\Intro2.mp2                                    # raw copy
.\\RP-TW-Media-Converter.ps1 .\\NewMusic.wav                                  # encoded, game settings
.\\RP-TW-Media-Converter.ps1 .\\NewMusic.wav -TwsBitrate 128k

.\\RP-TW-Media-Converter.ps1 .\\Intro2.twv -Info                              # inspect only
```

If PowerShell refuses to run the script because it was downloaded, run
`Unblock-File .\\RP-TW-Media-Converter.ps1` once, or use the `Reality\_Pump\_\_\_TopWare\_-\_Media\_Converter.cmd` launcher.

## Dependencies

The TWV container, the bitstream rewriting and all raw `.m1v` / `.mp2` conversions are
pure PowerShell. **ffmpeg** is needed only for re-encoding and for reading or writing
other containers (`.mpg`, `.mkv`, `.mp4`, ...). If ffmpeg isn't in `PATH` or `.\\tools`
when it's first needed, the script downloads the BtbN GPL shared build (\~85 MB) from
GitHub into `.\\tools` **once**. It checks the download against the published SHA-256
before using it. Use `-NoDownload` or `-FfmpegPath C:\\path\\ffmpeg.exe` to control this.

## Options

**General**

|Parameter|Default|Meaning|
|-|-|-|
|`-Mode`|Auto|`ToMp4` (menu 1), `TwsToAudio` (menu 2), `ToTwv` (menu 3), `AudioToTws` (menu 4), `ToWd1` (menu 5), or Auto (by extension; folders default to menu 1)|
|`-OutputPath`|beside input|output folder, or a file name (with extension) for one input|
|`-Fps`|header / source|menu 1: override the header fps. Menu 3: target fps (23.976/24/25/29.97/30/50/59.94/60); forces re-encode|

**Menu 1: game video -> video**

|Parameter|Default|Meaning|
|-|-|-|
|`-Container`|raw|`raw` (TWV -> `.m1v` + `.mp2`, WD1 -> `.avi`/`.mpg`; no ffmpeg; `m1v` also accepted), `mpg`, `mkv`, `mp4`, `mov`, `avi`, `webm`|
|`-VideoCodec`|auto|`copy` (original stream), `h264`, `h265`, `vp9`, `av1`, `mpeg1`. auto = copy, or vp9 for webm. If a stream can't be copied into the container, it's encoded instead and the script says so|
|`-AudioCodec`|auto|`copy` (original stream), `aac`, `mp3`, `mp2`, `opus`, `vorbis`, `flac`, `pcm`. auto = copy, or opus for webm|
|`-Crf`|per codec|quality, lower = better (h264 16, h265 20, vp9 28, av1 30, mpeg1 2)|
|`-VideoBitrate`|-|e.g. `4M`: fixed bitrate instead of CRF|
|`-Preset`|slow|x264/x265 speed preset (`ultrafast`..`veryslow`); AV1: `0`-`13`|
|`-OutSize`|keep|e.g. `1280x512`: rescale (Lanczos)|
|`-AudioBitrate`|192k (opus 160k)|lossy audio bitrate|
|`-SampleRate` / `-Channels`|keep|`22050`/`32000`/`44100`/`48000`; `1`/`2`|
|`-Audio` / `-NoAudio`|`.tws` beside `.twv`|audio source|

Codec choices per container (anything else is rejected before any work starts):

|Container|Video|Audio|
|-|-|-|
|raw|copy|copy|
|mpg|copy, mpeg1|copy, mp2, mp3|
|mkv|copy, h264, h265, vp9, av1, mpeg1|copy, aac, mp3, mp2, opus, vorbis, flac, pcm|
|mp4|copy, h264, h265, av1, mpeg1|copy, aac, mp3, mp2, opus, flac|
|mov|copy, h264, h265, mpeg1|copy, aac, mp3, mp2, pcm|
|avi|copy, h264, mpeg1|copy, mp3, mp2, aac, pcm|
|webm|vp9, av1|opus, vorbis|

What `copy` can actually keep, per source:

|Source stream|mkv|avi|mov|mp4|mpg|otherwise encoded as|
|-|-|-|-|-|-|-|
|MPEG-1 video (TWV, MPEG `.wd1`)|yes|yes|yes|yes|yes|-|
|Cinepak / Indeo 5 (AVI `.wd1`)|yes|yes|yes|no|no|H.264 (mp4), MPEG-1 (mpg)|
|MP2 audio|yes|yes|yes|yes|yes|-|
|PCM audio (AVI `.wd1`)|yes|yes|yes|no|no|AAC (mp4), MP2 (mpg)|

Original MPEG-1 video inside `.mp4` / `.mov` / `.avi` plays in VLC and MPC-HC, but not
in browsers or on phones. Use `-VideoCodec h264 -AudioCodec aac` for those.

**Menu 3: video -> TWV/TWS**

|Parameter|Default|Meaning|
|-|-|-|
|`-Reencode`|off|always re-encode (video and audio), even if the streams could be copied|
|`-Width` / `-Height`|640 / 256|size when encoding, multiples of 16. Forces video re-encode|
|`-Stretch`|off|stretch instead of letterboxing. Forces video re-encode|
|`-Q`|1|MPEG-1 quantiser 1-31 (lower = better, bigger; originals mostly use 1). Forces video re-encode|
|`-Audio`|-|audio source for the `.tws` (default: the video's soundtrack, or the `.mp2` beside an `.m1v`)|
|`-NoTws`|off|don't create the `.tws`|
|TWS options||see menu 4|

Video is copied when it is MPEG-1, I-frames only, default quantiser matrix, size a
multiple of 16, one slice per macroblock row. That covers everything menu 1 copies out
and the original game files.

**Menu 2: game sound -> audio** (`.tws`, or the soundtrack of a `.wd1`)

|Parameter|Default|Meaning|
|-|-|-|
|`-AudioFormat`|raw|`raw` (original track copied: TWS -> `.mp2`, WD1 -> `.wav` / `.mp2`), `wav`, `flac`, `mp3`, `m4a`, `ogg`, `opus`, `mp2`|
|`-AudioBitrate`|per format|mp3: high-quality VBR, or e.g. `320k` for CBR. m4a 192k, ogg VBR q6, opus 160k. With mp2: re-encode at that bitrate|
|`-SampleRate` / `-Channels`|keep|resample / downmix (re-encodes)|

**Menu 4 (and menu 3's `.tws`): audio -> TWS**

MP2 audio is copied as is. Anything else, or any of these parameters given, is encoded:

|Parameter|Default|Meaning|
|-|-|-|
|`-TwsBitrate`|160k|MP2 bitrate. Stereo: 64k-384k (not 80k). Mono: 32k-192k. Originals use 128k/160k|
|`-TwsSampleRate`|44100|`32000`, `44100`, `48000` (originals: 44100)|
|`-TwsChannels`|2|`1` or `2` (originals: stereo)|

**Menu 5: video -> WD1 (Earth 2150)**

|Parameter|Default|Meaning|
|-|-|-|
|`-Wd1Format`|auto|`auto` (copy if playable, else match the `.wd1` being replaced, else mpg), `mpg` (MPEG-1 + MP2), `avi` (Cinepak + PCM). Anything but auto forces re-encode|
|`-Reencode`|off|always re-encode, even if the source could be copied|
|`-Width` / `-Height`|match / source|frame size (default: the file being replaced, else the source)|
|`-Fps`|match / source|frame rate (MPEG-1 snaps to 23.976/24/25/29.97/30/...)|
|`-Q`|2|MPEG-1 quality 1-31 (lower = better)|
|`-AudioBitrate` / `-SampleRate` / `-Channels`|match / 160k, 44100, 2|MP2 bitrate, sample rate (MPEG-1 audio: 32/44.1/48 kHz; AVI PCM can be 22050), channels|
|`-Stretch`|off|stretch instead of letterboxing|

Copied in as is: AVI with Cinepak, Indeo 3/4/5 or Microsoft Video 1 video and PCM/ADPCM/MPEG
audio, and MPEG-1 system streams with MP2 audio. These are the formats the game's own
files use.

## Safety

* Before overwriting an existing `.twv`, `.tws` or `.wd1` (for example an original game
file), the script copies it to `name.twv.bak` / `name.tws.bak` / `name.wd1.bak`. Only the first original is
kept; later runs don't overwrite the `.bak`.
* If two inputs in one batch would write to the same output (`a.wav` and `a.mp3` both
going to `a.tws`), the second one is skipped.
* A copied TWS that isn't 44.1 kHz stereo gets a warning. One that isn't 128k/160k gets a note.

## Format notes

* **TWV**: 20-byte big-endian header (`TWV\\0`, version, width, height, fps as 16.16)
followed by stripped MPEG-1 video. Frames are I-frames only. There is no sequence or
GOP header, picture headers are 1 byte, and slice headers have no `extra\_bit\_slice`.
* **TWS**: a plain MPEG-1 Layer II (MP2) stream, 44.1 kHz stereo, 128-160 kbps.
The Python version marked this format as unknown.
* **WD1**: Earth 2150 videos are standard AVI (Cinepak or Indeo 5 + PCM, e.g. `VideoUCS.wd1`
256x192 24 fps, 22 kHz) or MPEG-1 system streams (e.g. `videoED.wd1` 256x192 30 fps,
MP2 112k) under another extension.
* **Truncated TWVs**: some files (e.g. WWIII `IRQ2\_Outro.twv`, `RUS1\_Outro.twv`) are
missing the header and the start of the first frame. The script rebuilds the header
and gets the height from the slice count. Width defaults to 640 (`-Width` overrides
it). If a `.tws` sits beside the file, fps is estimated from the audio length.
Otherwise it defaults to 25 (`-Fps` overrides it).
* **Differences from the Python version**: TWVs made from MPEG-1 have no padding byte
at the end of each slice, so they match the originals exactly. Python's files are
slightly bigger but decode to identical frames.

