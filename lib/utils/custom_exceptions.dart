class OrientAIException implements Exception {
  final String message;
  final String? code;

  OrientAIException(this.message, {this.code});

  @override
  String toString() => message;
}

class OrientAIAuthException extends OrientAIException {
  OrientAIAuthException(super.message, {super.code});
}

class OrientAIDataException extends OrientAIException {
  OrientAIDataException(super.message, {super.code});
}
