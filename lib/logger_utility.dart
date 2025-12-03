import 'dart:io';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

class FileLoggerOutput extends LogOutput {
  final String logFileName;
  final int maxLogDays;
  File? _currentLogFile;
  String? _currentDateString;

  FileLoggerOutput({
    this.logFileName = 'flutter_gdrive_kiosk',
    this.maxLogDays = 7,
  });

  @override
  Future<void> init() async {
    await super.init();
    _ensureLogFile();
    _cleanOldLogs();
  }

  @override
  void output(OutputEvent event) {
    _ensureLogFile();

    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final logLines = event.lines.map((line) => '[$timestamp] $line').join('\n');

    try {
      _currentLogFile?.writeAsStringSync('$logLines\n', mode: FileMode.append);
    } catch (e) {
      print('Error writing to log file: $e');
    }
  }

  void _ensureLogFile() {
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (_currentDateString != currentDate || _currentLogFile == null) {
      _currentDateString = currentDate;
      _createNewLogFile();
    }
  }

  void _createNewLogFile() {
    try {
      final logDir = Directory('logs');
      if (!logDir.existsSync()) {
        logDir.createSync(recursive: true);
      }

      final fileName = '${logFileName}_$_currentDateString.log';
      _currentLogFile = File('${logDir.path}/$fileName');

      if (!_currentLogFile!.existsSync()) {
        _currentLogFile!.createSync();
        _currentLogFile!.writeAsStringSync(
          '=== Log started at ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())} ===\n',
        );
      }
    } catch (e) {
      print('Error creating log file: $e');
    }
  }

  void _cleanOldLogs() {
    try {
      final logDir = Directory('logs');
      if (!logDir.existsSync()) return;

      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: maxLogDays));

      logDir.listSync().whereType<File>().forEach((file) {
        final fileName = file.path.split('/').last;

        // Try to parse date from filename
        final dateMatch = RegExp(r'(\d{4}-\d{2}-\d{2})').firstMatch(fileName);
        if (dateMatch != null) {
          try {
            final fileDate =
                DateFormat('yyyy-MM-dd').parse(dateMatch.group(1)!);
            if (fileDate.isBefore(cutoffDate)) {
              file.deleteSync();
              print('Deleted old log file: $fileName');
            }
          } catch (e) {
            // Skip files that don't match expected format
          }
        }
      });
    } catch (e) {
      print('Error cleaning old logs: $e');
    }
  }

  @override
  Future<void> destroy() async {
    await super.destroy();
  }
}

class MinimalPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final time = DateFormat('HH:mm:ss').format(event.time);
    final level = _getLevelString(event.level);
    final message = event.message;

    if (event.error != null) {
      final errorMessage = '$time $level $message - ${event.error}';
      if (event.stackTrace != null) {
        return [errorMessage, event.stackTrace.toString()];
      }
      return [errorMessage];
    }

    return ['$time $level $message'];
  }

  String _getLevelString(Level level) {
    switch (level) {
      case Level.debug:
        return '[DEBUG]';
      case Level.info:
        return '[INFO] ';
      case Level.warning:
        return '[WARN] ';
      case Level.error:
        return '[ERROR]';
      default:
        return '[TRACE]';
    }
  }
}

class AppLogger {
  static late Logger _logger;
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;

    _logger = Logger(
      printer: MinimalPrinter(),
      output: MultiOutput([
        ConsoleOutput(),
        FileLoggerOutput(),
      ]),
    );

    _initialized = true;
    _logger.i('Logger initialized');
  }

  static void debug(String message) {
    if (!_initialized) init();
    _logger.d(message);
  }

  static void info(String message) {
    if (!_initialized) init();
    _logger.i(message);
  }

  static void warning(String message) {
    if (!_initialized) init();
    _logger.w(message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_initialized) init();
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
