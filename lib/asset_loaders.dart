import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'logger_utility.dart';

Future<ServiceAccountCredentials> loadServiceAccountCredentials() async {
  try {
    AppLogger.info('Loading service account credentials');
    final String jsonString =
        await rootBundle.loadString('assets/credentials.json');
    final Map<String, dynamic> jsonCredentials = json.decode(jsonString);
    final credentials = ServiceAccountCredentials.fromJson(jsonCredentials);
    AppLogger.info('Service account credentials loaded successfully');
    return credentials;
  } catch (e, stackTrace) {
    AppLogger.error(
        'Failed to load service account credentials', e, stackTrace);
    rethrow;
  }
}

Future<String> loadFolderId() async {
  try {
    AppLogger.info('Loading Google Drive folder ID');
    final String jsonString =
        await rootBundle.loadString('assets/folder_id.txt');
    final folderId = jsonString.trim();
    AppLogger.info('Folder ID loaded: ${folderId.substring(0, 10)}...');
    return folderId;
  } catch (e, stackTrace) {
    AppLogger.error('Failed to load folder ID', e, stackTrace);
    rethrow;
  }
}
