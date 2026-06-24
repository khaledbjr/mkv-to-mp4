MKV -> MP4 Converter
====================

HOW TO USE
----------
1. Drag one or more .mkv files onto the icon called
   "Convert MKV to MP4" (the .bat file).
2. A black window opens and does the work.
3. Your .mp4 files appear in the SAME folder as the originals.
   (The original .mkv files are left untouched.)

That's it. You can select several MKV files at once and drop them
all together.

FIRST RUN
---------
The very first time you use it, it downloads a helper program
(ffmpeg, about 90 MB) into a "tools" folder next to this file.
That happens once and can take a minute or two - after that it's
instant and works offline. It never downloads again.

So the first run needs an internet connection.

HOW IT WORKS / SPEED
--------------------
Most MKV files just need "repackaging" into an MP4 container, which
takes only a few seconds and loses ZERO quality. The app does that
automatically. If a file uses an unusual video format that MP4 can't
hold directly, it falls back to a full conversion, which is slower
but still works.

Subtitles embedded in the MKV are not carried over (this keeps things
simple and avoids errors). The video and audio always are.

SHARING WITH A FRIEND
---------------------
Send your friend these files:
  - Convert MKV to MP4.bat
  - convert.ps1
  - README.txt
They can put them in any folder. On first use it sets up ffmpeg by
itself. (You can also copy the whole "tools" folder so they skip the
download.)

TROUBLESHOOTING
---------------
- "Windows protected your PC" / SmartScreen: click "More info" ->
  "Run anyway". This is normal for unsigned scripts.
- Nothing happens when double-clicking: don't double-click - DRAG
  mkv files onto the icon instead.
- A file failed: it may be corrupt or have a rare codec. The window
  shows which file and why.
