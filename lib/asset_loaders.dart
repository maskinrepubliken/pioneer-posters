import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';

Future<ServiceAccountCredentials> loadServiceAccountCredentials() async {
  final String jsonString =
      await rootBundle.loadString('assets/credentials.json');
  final Map<String, dynamic> jsonCredentials = json.decode(jsonString);
  final credentials = ServiceAccountCredentials.fromJson(jsonCredentials);

  return credentials;
}

Future<String> loadFolderId() async {
  final String jsonString = await rootBundle.loadString('assets/folder_id.txt');
  return jsonString;
}
