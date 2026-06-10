class AppException implements Exception {
  final String code;
  final String message;
  final List<String>? errors;

  const AppException({
    required this.code,
    required this.message,
    this.errors,
  });

  @override
  String toString() {
    return 'AppException: $message (Code: $code)';
  }
}

class Failure {
  final String code;
  final String message;
  final List<String>? errors;

  const Failure({
    required this.code,
    required this.message,
    this.errors,
  });

  factory Failure.fromException(AppException exception) {
    return Failure(
      code: exception.code,
      message: exception.message,
      errors: exception.errors,
    );
  }

  @override
  String toString() => message;
}
