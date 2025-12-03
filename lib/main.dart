import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'download_images_from_google_drive.dart';
import 'logger_utility.dart';

final slideshowDuration = 8;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.init();
  AppLogger.info('Application starting...');

  try {
    AppLogger.info('Cleaning downloads directory...');
    await cleanDownloadsDirectory();
    AppLogger.info('Downloads directory cleaned successfully');
  } catch (e, stackTrace) {
    AppLogger.error('Failed to clean downloads directory', e, stackTrace);
  }

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _index = -1;
  List<File> _fileList = List.empty(growable: true);
  List<File> _pendingFileList = List.empty(growable: true);
  bool _hasPendingUpdate = false;

  @override
  void initState() {
    super.initState();
    AppLogger.info('App state initialized');

    // Initial download
    _downloadImages();

    Timer.periodic(Duration(seconds: slideshowDuration), (timer) {
      setState(() {
        _index += 1;

        // Check if we've completed a cycle
        if (_index >= _fileList.length) {
          _index = 0;

          // Apply pending file list if available
          if (_hasPendingUpdate) {
            _fileList = _pendingFileList;
            _pendingFileList = List.empty(growable: true);
            _hasPendingUpdate = false;
            AppLogger.info(
                'Applied new image list with ${_fileList.length} images');
          }

          // Start downloading new images for next cycle
          _downloadImages();
        }

        if (_index >= 0 && _fileList.isNotEmpty) {
          AppLogger.debug(
              'Showing image ${_index + 1} of ${_fileList.length}: ${_fileList[_index].path}');
        }
      });
    });
  }

  Future<void> _downloadImages() async {
    try {
      AppLogger.info('Starting image download from Google Drive');
      final fileList = await downloadImagesFromGoogleDrive();

      setState(() {
        if (_fileList.isEmpty) {
          // First time loading - use immediately
          _fileList = fileList;
          _index = 0;
          AppLogger.info('Initial load: ${fileList.length} images');
        } else {
          // Store for next cycle
          _pendingFileList = fileList;
          _hasPendingUpdate = true;
          AppLogger.info('Downloaded ${fileList.length} images for next cycle');
        }
      });
    } catch (e, stackTrace) {
      AppLogger.error('Failed to download images', e, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Builder(builder: (context) {
                if (_index < 0 || _fileList.isEmpty) {
                  return SpinKitRotatingCircle(
                    color: Colors.white,
                    size: 50.0,
                  );
                } else {
                  return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 2000),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Image.file(
                        _fileList[_index],
                        key: ValueKey<int>(_index),
                      ));
                }
              }),
            )));
  }
}
