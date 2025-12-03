import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'asset_loaders.dart';
import 'dart:io' as io;
import 'logger_utility.dart';

final downloadDirectoryName = 'downloaded_images';

Future<void> cleanDownloadsDirectory() async {
  final directory = io.Directory(downloadDirectoryName);
  if (!directory.existsSync()) {
    AppLogger.info('Creating downloads directory: $downloadDirectoryName');
    directory.createSync();
  }
  AppLogger.info('Deleting all files in downloads directory');
  await directory.delete(recursive: true);
  directory.createSync();
  AppLogger.info('Downloads directory cleaned and recreated');
}

Future<List<io.File>> downloadImagesFromGoogleDrive() async {
  AppLogger.info('Starting Google Drive download process');

  final credentials = await loadServiceAccountCredentials();
  final folderId = await loadFolderId();
  AppLogger.info('Loaded credentials and folder ID: $folderId');

  final client =
      await clientViaServiceAccount(credentials, [DriveApi.driveReadonlyScope]);

  // Create a list of available file paths
  final List<io.File> downloadedFiles = List.empty(growable: true);

  try {
    // Create the downloads directory
    final directory = io.Directory(downloadDirectoryName);
    if (!directory.existsSync()) {
      AppLogger.info('Creating downloads directory: $downloadDirectoryName');
      directory.createSync();
    }

    // Connect to Google Drive
    final api = DriveApi(client);
    AppLogger.info('Connected to Google Drive API successfully');

    // List the files in the folder
    final query = "'$folderId' in parents and mimeType contains 'image/'";
    AppLogger.info('Running Google Drive query: $query');
    final files = await api.files.list(
      q: query,
      $fields: 'files(id, name)',
    );
    AppLogger.info('Query completed successfully');

    // Try to download each image in the google drive folder
    if (files.files == null || files.files!.isEmpty) {
      AppLogger.warning('No images found in the Google Drive folder');
    } else {
      AppLogger.info('Found ${files.files!.length} images to download');
      for (final onlineFile in files.files!) {
        final fileId = onlineFile.id!;
        final fileName = '${onlineFile.name!}-${onlineFile.id!}';
        final localFile = io.File('$downloadDirectoryName/$fileName');

        if (localFile.existsSync()) {
          AppLogger.debug('File already exists locally: $fileName');
          downloadedFiles.add(localFile);
        } else {
          AppLogger.debug('Downloading file: $fileName');
          final media = await api.files.get(
            fileId,
            downloadOptions: DownloadOptions.fullMedia,
          );

          if (media is Media) {
            final sink = localFile.openWrite();

            await media.stream.pipe(sink);
            await sink.close();

            AppLogger.info('Successfully downloaded: $fileName');
            downloadedFiles.add(localFile);
          } else {
            AppLogger.error(
                'Failed to download file: $fileName - Media response was not of type Media');
          }
        }
      }
    }
  } catch (e, stackTrace) {
    AppLogger.error(
        'Error downloading images from Google Drive', e, stackTrace);
  } finally {
    client.close();
    AppLogger.debug('Google Drive client connection closed');
  }

  // Return all downloaded files
  AppLogger.info('Returning ${downloadedFiles.length} downloaded files');
  return downloadedFiles;
}
