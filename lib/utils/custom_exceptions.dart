class OrientAIException implements Exception {
  final String message;
  final String? code;

  OrientAIException(this.message, {this.code});

  @override
  String toString() => message;
}

class OrientAIAuthException extends OrientAIException {
  OrientAIAuthException(String message, {String? code}) : super(message, code: code);
}

class OrientAIDataException extends OrientAIException {
  OrientAIDataException(String message, {String? code}) : super(message, code: code);
}
