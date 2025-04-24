import 'package:logging/logging.dart';

/// A singleton logger for the application
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  static late final Logger _logger;

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal() {
    _setupLogging();
  }

  /// Initialize the logger
  static void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
      if (record.error != null) {
        print('Error: ${record.error}');
      }
      if (record.stackTrace != null) {
        print('Stack trace: ${record.stackTrace}');
      }
    });
    _logger = Logger('SnackrApp');
  }

  static void info(String message) {
    _logger.info(message);
  }

  static void warning(String message) {
    _logger.warning(message);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }

  static void debug(String message) {
    _logger.fine(message);
  }
}