# MKV → MP4 Converter

A dead-simple, drag-and-drop MKV-to-MP4 converter for Windows. No install, no
settings, no command line. Drag files onto an icon — MP4s appear next to them.

Powered by [ffmpeg](https://ffmpeg.org/), which the app downloads automatically
on first run.

## How to use

1. Download this repo (green **Code** button → **Download ZIP**) and unzip it
   anywhere.
2. Drag one or more `.mkv` files onto **`Convert MKV to MP4.bat`**.
3. The `.mp4` files appear in the **same folder** as the originals. The original
   `.mkv` files are left untouched.

You can drop a whole batch of files at once.

## How it works

- **Fast and lossless by default.** Most MKV files just need repackaging into an
  MP4 container: the video track is copied bit-for-bit and only the audio is
  converted to AAC. This takes seconds and loses zero video quality.
- **Automatic fallback.** If a file uses a video format MP4 can't store directly,
  the app re-encodes it to H.264 instead — slower, but it still works.
- **Never overwrites.** If `movie.mp4` already exists, it writes `movie (1).mp4`.
- Embedded subtitles are intentionally dropped to keep conversions reliable;
  video and audio always carry over.

## First run

The first time you use it, the app downloads a portable copy of ffmpeg (~30 MB)
into a `tools/` folder next to the scripts. This happens once and requires an
internet connection. After that it works offline and instantly.

> **Windows SmartScreen** may show *"Windows protected your PC"* the first time.
> Click **More info → Run anyway**. This is normal for unsigned scripts.

## Files

| File | Purpose |
|------|---------|
| `Convert MKV to MP4.bat` | The icon you drag files onto |
| `convert.ps1` | The conversion engine (PowerShell) |
| `README.md` | This file |

## License

[MIT](LICENSE) — free to use, copy, and share.
