import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'asset_loaders.dart';
import 'dart:io' as io;

final downloadDirectoryName = 'downloaded_images';

Future<void> cleanDownloadsDirectory() async {
  final directory = io.Directory(downloadDirectoryName);
  if (!directory.existsSync()) {
    directory.createSync();
  }
  await directory.delete(recursive: true);
  directory.createSync();
}

Future<List<io.File>> downloadImagesFromGoogleDrive() async {
  final credentials = await loadServiceAccountCredentials();
  final folderId = await loadFolderId();

  final client =
      await clientViaServiceAccount(credentials, [DriveApi.driveReadonlyScope]);

  // Create a list of available file paths
  final List<io.File> downloadedFiles = List.empty(growable: true);

  try {
    // Create the downloads directory
    final directory = io.Directory(downloadDirectoryName);
    if (!directory.existsSync()) {
      directory.createSync();
    }

    // Connect to Google Drive
    final api = DriveApi(client);
    print("Connection to drive ok, downloading images");

    // List the files in the folder
    final query = "'$folderId' in parents and mimeType contains 'image/'";
    print('Running google drive query: $query');
    final files = await api.files.list(
      q: query,
      $fields: 'files(id, name)',
    );
    print('Ok!');

    // Try to download each image in the google drive folder
    if (files.files == null || files.files!.isEmpty) {
      print('No images found in the drive folder.');
    } else {
      print('Downloading files...');
      for (final onlineFile in files.files!) {
        final fileId = onlineFile.id!;
        final fileName = '${onlineFile.name!}-${onlineFile.id!}';
        final localFile = io.File('$downloadDirectoryName/$fileName');

        if (localFile.existsSync()) {
          print('Already downloaded $fileName');
          downloadedFiles.add(localFile);
        } else {
          final media = await api.files.get(
            fileId,
            downloadOptions: DownloadOptions.fullMedia,
          );

          if (media is Media) {
            final sink = localFile.openWrite();

            await media.stream.pipe(sink);
            await sink.close();

            print('Saved $fileName');
            downloadedFiles.add(localFile);
          } else {
            print('Failed to download $fileName');
          }
        }
      }
    }
  } catch (e, s) {
    print('Error downloading images: $e');
    print('Stack trace: $s');
  } finally {
    client.close();
  }

  // Return all downloaded files
  return downloadedFiles;
}
