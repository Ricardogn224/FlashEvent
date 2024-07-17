import 'dart:developer' as developer;

class ApiException extends Error {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode}) {
    developer.log(
      'ApiException: $message (status code: $statusCode)',
      error: this,
    );
  }

  @override
  String toString() {
    return 'ApiException: $message (status code: $statusCode)';
  }
}
