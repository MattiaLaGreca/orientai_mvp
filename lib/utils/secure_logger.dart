// ignore: constant_identifier_names
import 'package:orientai/secrets.dart' as secrets;

class SecureLogger {
  static void log(String context, Object error) {
    String message = error.toString();
    // Sanitizza la API Key se presente
    // Nota: GEMINI_API_KEY viene da secrets.dart
    // ignore: constant_identifier_names
    const apiKey = secrets.geminiApiKey;

    if (message.contains(apiKey)) {
      message = message.replaceAll(apiKey, '***API_KEY***');
    }

    // Header standardizzato per i log
    print("[SecureLogger] $context: $message");
  }
}
