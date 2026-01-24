import 'package:orientai/secrets.dart';

class SecureLogger {
  static void log(String context, Object error) {
    String message = error.toString();
    // Sanitizza la API Key se presente
    // Nota: GEMINI_API_KEY viene da secrets.dart
    const apiKey = GEMINI_API_KEY;

    if (message.contains(apiKey)) {
      message = message.replaceAll(apiKey, '***API_KEY***');
    }

    // Header standardizzato per i log
    print("[SecureLogger] $context: $message");
  }
}
