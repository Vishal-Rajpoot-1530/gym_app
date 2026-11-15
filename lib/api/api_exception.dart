class ApiException implements Exception {
  static const serviceUnavailableMessage =
      'The service is temporarily unavailable. Please check your internet '
      'connection and try again. If the issue persists, contact your service '
      'provider.';

  final String message;
  final int? statusCode;
  final bool networkError;

  const ApiException(
    this.message, {
    this.statusCode,
    this.networkError = false,
  });

  @override
  String toString() => message;
}
