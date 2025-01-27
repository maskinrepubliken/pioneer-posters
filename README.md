# flutter-gdrive-kiosk

A flutter project that display all images from a google drive folder in a repeating slideshow. For a Raspberry PI running wayland in kiosk mode for a digital display mounted outside the local cinema. i.e. its for repeating movie posters

## Getting started

1. Create `assets/folder_id.txt` and add the id of the google drive folder with images in it.

2. Create a Google Service Account and add the credentials to the file `assets/credentials.json`. The account must have access to the folder.

3. Run the application! For my use case its run under the [weston](https://wiki.archlinux.org/title/Weston) compositor for wayland using [flutter-elinux](https://github.com/sony/flutter-elinux).

## Build using flutter-elinux

1. Clone and initialize the repository with `flutter pub get`.

2. [Create](https://github.com/sony/flutter-elinux/wiki/Building-flutter-apps) a release build using `flutter-elinux build elinux`.

## Use the application in kiosk mode

For my uses weston is launched on startup with the following configuration in `weston.ini`:

```ini
[shell]
panel-position=none
locking=false
background-image=""
background-color=0xFF0000FF

[autolaunch]
path=/home/pi/startup
```

This makes the application launch in fullscreen without any gui elements, the file `/home/pi/startup` looks like this:

```bash
#!/bin/bash

# Launch the application

cd ./kiosk
FLUTTER_LOG_LEVELS=TRACE ./build/elinux/arm64/release/bundle/flutter-gdrive-kiosk -b . -f
```
