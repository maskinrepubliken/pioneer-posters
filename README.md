# flutter-gdrive-kiosk

A flutter project that display all images from a google drive folder in a repeating slideshow. For a Raspberry PI running wayland in kiosk mode for a digital display mounted outside the local cinema. i.e. its for repeating movie posters

## Getting started

1. Create `assets/folder_id.txt` and add the id of the google drive folder with images in it.

2. Create a Google Service Account and add the credentials to the file `assets/credentials.json`. The account must have access to the folder.

3. Run the application! For my use case its run under the [weston](https://wiki.archlinux.org/title/Weston) compositor for wayland using [flutter-elinux](https://github.com/sony/flutter-elinux).
