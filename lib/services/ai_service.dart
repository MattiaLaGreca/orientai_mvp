import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:orientai/secrets.dart';

class OrientAIService {
  // ⚠️ IMPORTANTE: Assicurati che qui ci sia la tua API KEY corretta!
  static const String _apiKey = GEMINI_API_KEY;
  
  late final GenerativeModel _model;
  late final ChatSession _chat;

  // MODIFICA: Ora init accetta isPremium
  void init(String studentName, String promptDetails, bool isPremium, {GenerativeModel? modelOverride, ChatSession? chatOverride}) {
    
    // Update Models: Gemini 2.5 Flash Lite (Free) and 2.5 Pro (Premium)
    // 2.5 Flash Lite is highly cost-effective ($0.10/1M input).
    final modelName = isPremium ? 'gemini-2.5-pro' : 'gemini-2.5-flash-lite';

    print("DEBUG: Inizializzo AI con modello $modelName (Premium: $isPremium)");

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

    _model = modelOverride ?? GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system(optimizedInstruction),
    );

    _chat = chatOverride ?? _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? "Non ho capito, puoi ripetere?";
    } catch (e) {
      // 🔒 Sentinel: Log dell'errore per debug, ma non esporre i dettagli all'utente
      _logSecurely("AI sendMessage Error", e);
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
      // 🔒 Sentinel: Log dell'errore per debug, ma non esporre i dettagli all'utente
      _logSecurely("AI sendMessageWithStreaming Error", e);
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
          Sei un assistente specializzato nel riassumere sessioni di orientamento scolastico.
          Il tuo obiettivo è creare un report strutturato che permetta all'AI successiva di avere una "memoria perfetta".

          Devi analizzare la chat e produrre un output RIGOROSAMENTE in questo formato:

          --- PROFILO UTENTE ---
          - Nome: [Nome rilevato o noto]
          - Stile cognitivo: [Analitico/Emotivo/Pratico/Indeciso...]
          - Obiettivo: [Cosa vuole ottenere l'utente?]
          - Note psicologiche: [Osservazioni su ansie, punti di forza, ecc.]

          --- CONTESTO ATTUALE ---
          [Riassunto breve ma denso degli argomenti trattati. Cosa è stato risolto? Cosa è in sospeso?]

          --- MEMORIA VERBATIM (Messaggi Chiave) ---
          User: "[Cita ESATTAMENTE frasi dell'utente cruciali per il contesto (es. dubbi specifici, rifiuti netti, preferenze forti)]"
          AI: "[Cita ESATTAMENTE consigli chiave dati che non devono essere contraddetti]"
          User: "[Cita ESATTAMENTE l'ultimo o penultimo messaggio significativo dell'utente per continuità]"

          IMPORTANTE:
          1. Nella sezione MEMORIA VERBATIM, devi riportare le frasi testuali, non riassunte. Scegli le 3-4 più importanti e recenti.
          2. Tutto ciò che scrivi qui NON verrà mostrato all'utente, serve solo alla memoria interna.
          3. Sii conciso ma non perdere dettagli cruciali.
        '''),
      );
      final chatSummary = await summarizer.startChat().sendMessage(
        Content.text(chatHistory.map((entry) => "${entry['role']}: ${entry['content']}").join("\n"))
      );
      return chatSummary.text ?? "Nessun sommario disponibile.";
    } catch (e) {
      // 🔒 Sentinel: Log dell'errore per debug, ma non esporre i dettagli
      _logSecurely("AI summarizeChat Error", e);
      return "Sommario non disponibile al momento.";
    }
  }

  /// 🔒 Sentinel: Sanitizza i log per evitare di esporre la API Key
  void _logSecurely(String context, Object error) {
    String message = error.toString();
    if (message.contains(_apiKey)) {
      message = message.replaceAll(_apiKey, '***API_KEY***');
    }
    print("Secure Log - $context: $message");
  }
}