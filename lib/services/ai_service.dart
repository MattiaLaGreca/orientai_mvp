import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:orientai/secrets.dart';
import '../utils/secure_logger.dart';
import '../utils/ai_wrappers.dart';

class OrientAIService {
  // ⚠️ IMPORTANTE: Assicurati che qui ci sia la tua API KEY corretta!
  static const String _apiKey = GEMINI_API_KEY;
  
  late final GenerativeModelWrapper _model;
  late final ChatSessionWrapper _chat;

  // MODIFICA: Ora init accetta isPremium
  void init(String studentName, String promptDetails, bool isPremium, {GenerativeModelWrapper? modelOverride, ChatSessionWrapper? chatOverride}) {
    
    // Update Models: Gemini 2.5 Flash Lite (Free) and 2.5 Pro (Premium)
    // 2.5 Flash Lite is highly cost-effective ($0.10/1M input).
    final modelName = isPremium ? 'gemini-2.5-pro' : 'gemini-2.5-flash-lite';

    SecureLogger.log("Init", "Inizializzo AI con modello $modelName (Premium: $isPremium)");

    // Istruzione Ottimizzata (Sintattica & Psicologica) - UNICA PER TUTTI
    // Condensiamo i concetti per risparmiare token senza perdere qualità (AI-Native density).
    final String optimizedInstruction = '''
RUOLO: OrientAI, orientatore scolastico esperto (IT).
UTENTE: $studentName. DATA: $promptDetails.
OBIETTIVO: Guidare scelta percorso (Teorico vs Pratico).
METODO: Profilazione Psicologica + Consigli Pratici.
TONO: Adattivo (Serio<->Giocoso). Empatico ma concreto.

ISTRUZIONI OPERATIVE:
1. Analizza personalità/ansie nascoste.
2. Usa info da Sommario (se presente) per continuità totale.
3. Se Sommario presente: Bentornato personalizzato. Altrimenti: Domanda aperta.

Se disponibile ti fornirò un sommario della chat precedente (Profilo, Contesto, Verbatim).
Usa queste informazioni per riprendere la conversazione in modo naturale, dimostrando di ricordare cosa è stato detto.
''';

    if (modelOverride != null) {
      _model = modelOverride;
    } else {
      final realModel = GenerativeModel(
        model: modelName,
        apiKey: _apiKey,
        systemInstruction: Content.system(optimizedInstruction),
      );
      _model = RealGenerativeModel(realModel);
    }

    _chat = chatOverride ?? _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? "Non ho capito, puoi ripetere?";
    } catch (e) {
      SecureLogger.log("AI sendMessage Error", e);
      return "Si è verificato un errore momentaneo. Per favore riprova.";
    }
  }

  Future<String> sendMessageWithStreaming(String message, void Function(String) onPartialResponse) async {
    final buffer = StringBuffer();
    try {
      await for (final chunk in _chat.sendMessageStream(Content.text(message))) {
        if (chunk.text != null) {
          buffer.write(chunk.text!);
          onPartialResponse(buffer.toString());
        }
      }
      return buffer.toString();
    } catch (e) {
      SecureLogger.log("AI sendMessageWithStreaming Error", e);
      return "Si è verificato un errore momentaneo durante la generazione della risposta.";
    }
  }

  Future<String> summarizeChat(bool isPremium, List<Map<String, dynamic>>chatHistory) async {
    if (chatHistory.isEmpty) return "Nessuno storico disponibile, la chat è appnea iniziata.";
    try {
      // Usiamo SEMPRE Flash Lite per il riassunto per massimo risparmio
      final summarizer = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: _apiKey,
        systemInstruction: Content.system('''
          RUOLO: Summarizer OrientAI. OBIETTIVO: Comprimere contesto per memoria futura.
          OUTPUT RICHIESTO:

          --- PROFILO UTENTE ---
          Nome: [Valore]
          Cognitivo: [Analitico/Emotivo/Pratico...]
          Obiettivo: [Valore]
          Psico: [Ansie/Punti Forza]

          --- CONTESTO ---
          [Riassunto denso stato attuale e temi trattati]

          --- MEMORIA VERBATIM ---
          User: "[Frase cruciale testuale]"
          AI: "[Consiglio chiave dato]"
          User: "[Ultimo messaggio significativo]"

          VINCOLI: Massima densità informativa. VERBATIM deve citare testualmente 3-4 scambi chiave.
        '''),
      );
      final chatSummary = await summarizer.startChat().sendMessage(
        Content.text(chatHistory.map((entry) => "${entry['role']}: ${entry['content']}").join("\n"))
      );
      return chatSummary.text ?? "Nessun sommario disponibile.";
    } catch (e) {
      SecureLogger.log("AI summarizeChat Error", e);
      return "Sommario non disponibile al momento.";
    }
  }
}
