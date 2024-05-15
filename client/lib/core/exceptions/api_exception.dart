class ApiException extends Error {
  final String message;
  int? statusCode;

  ApiException({required this.message, this.statusCode});
}
