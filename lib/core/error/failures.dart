import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({required String message, int? code})
      : super(message: message, code: code);
}

/// Database-related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({required String message, int? code})
      : super(message: message, code: code);
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({required String message, int? code})
      : super(message: message, code: code);
}

/// General cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({required String message, int? code})
      : super(message: message, code: code);
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure({required String message, int? code})
      : super(message: message, code: code);
}

/// Parse error failures
class ParseFailure extends Failure {
  const ParseFailure({required String message, int? code})
      : super(message: message, code: code);
}