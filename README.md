# Pioneer Posters

A slideshow kiosk for a Raspberry Pi: it shows every image in a Google Drive folder as a repeating
slideshow. Built for a display mounted outside the local cinema, where it shows movie posters.

## Part of the pioneer series

This is a pioneer project from Maskinrepubliken. Pioneer projects are small programs that run on a Raspberry Pi, each built for one specific place and purpose. They are open source, so you can read, change and run the code yourself. The code is kept small and plainly structured, which makes it easy to adapt, with or without AI tools. Treat it as a starting point for your own setup, not a finished product.

## What it does

A Flutter app, built for Linux with [flutter-elinux](https://github.com/sony/flutter-elinux), that
downloads the images in a Google Drive folder with a service account and loops through them full screen.
Change the posters by changing the files in the folder; nothing on the Pi needs to be touched.

- `lib/main.dart` the slideshow
- `lib/download_images_from_google_drive.dart` fetches the images from Drive
- `lib/asset_loaders.dart`, `lib/logger_utility.dart` configuration and logging

## Hardware

A Raspberry Pi (64-bit OS) running the [Weston](https://wiki.archlinux.org/title/Weston) Wayland
compositor in kiosk mode, connected to a display.

## Getting started

1. Create `assets/folder_id.txt` with the id of the Google Drive folder that holds the images.
2. Create a Google service account with access to the folder and save its key as `assets/credentials.json`.
   Both files are bundled into the build as assets: keep them out of git.
3. Install dependencies with `flutter pub get` and
   [create a release build](https://github.com/sony/flutter-elinux/wiki/Building-flutter-apps) with
   `flutter-elinux build elinux`.

## Kiosk mode

Weston is started at boot with this `weston.ini`, so the app runs full screen without any other UI:

```ini
[shell]
panel-position=none
locking=false
background-image=""
background-color=0xFF0000FF

[autolaunch]
path=/home/pi/startup
```

`/home/pi/startup`:

```bash
#!/bin/bash
cd ./kiosk
FLUTTER_LOG_LEVELS=TRACE ./build/elinux/arm64/release/bundle/flutter-gdrive-kiosk -b . -f
```

## License

MIT, see [LICENSE](LICENSE). Copyright (c) 2025–2026 Viktor Lyresten / Maskinrepubliken.
