import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'download_images_from_google_drive.dart';

final slideshowDuration = 8;
final refreshDuration = slideshowDuration * 4;

void main() async {
  //await cleanDownloadsDirectory();
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

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: refreshDuration), (timer) async {
      final fileList = await downloadImagesFromGoogleDrive();
      setState(() {
        _fileList = fileList;
        _index = 0;
      });
    });

    Timer.periodic(Duration(seconds: slideshowDuration), (timer) {
      setState(() {
        _index += 1;
        if (_index >= _fileList.length) {
          _index = 0;
        }
      });
    });
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
