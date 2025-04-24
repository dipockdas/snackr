/// Exception thrown when a server request fails
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});
}

/// Exception thrown when a database operation fails
class DatabaseException implements Exception {
  final String message;

  DatabaseException({required this.message});
}

/// Exception thrown when a cache operation fails
class CacheException implements Exception {
  final String message;

  CacheException({required this.message});
}

/// Exception thrown when network is unavailable
class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});
}

/// Exception thrown when authentication fails
class AuthException implements Exception {
  final String message;

  AuthException({required this.message});
}

/// Exception thrown when parsing data fails
class ParseException implements Exception {
  final String message;

  ParseException({required this.message});
}