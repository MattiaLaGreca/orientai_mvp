import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:orientai/secrets.dart';

class OrientAIService {
  // ⚠️ IMPORTANTE: Assicurati che qui ci sia la tua API KEY corretta!
  static const String _apiKey = GEMINI_API_KEY;
  
  late final GenerativeModel _model;
  late final ChatSession _chat;

  // MODIFICA: Ora init accetta isPremium
  void init(String studentName, String promptDetails, bool isPremium) {
    
    // Aggiornamento ai modelli Gemini 3.0 Preview
    final modelName = isPremium ? 'gemini-3.0-pro-preview' : 'gemini-3.0-flash-preview';

    print("DEBUG: Inizializzo AI con modello $modelName (Premium: $isPremium)");

    _model = GenerativeModel(
      model: modelName, 
      apiKey: _apiKey,
      systemInstruction: Content.system('''
        Sei OrientAI, un esperto orientatore scolastico italiano.
        Non ti occuperai di altro se non di aiutare studenti a scegliere il loro percorso futuro.
        Considera che lo studente può essere più portato per lo studio o per il lavoro pratico, aiutalo a scoprirlo.
        Stai parlando con $studentName che ha interessi: $promptDetails.
        
        ${isPremium ? "L'utente ha un account premium, non fare risposte troppo prolisse e lente, sii veloce e mettici la cura che ci vuole per un utente pagante" : "L'utente ha un account gratuito, quindi sii conciso e veloce nelle risposte."}
        Usa anche elenchi puntati e formattazione markdown.
        
        Cerca di capire la personalità dell'utente dalle sue risposte e adatta i tuoi consigli.
        Metti in pratica strumenti psicologici per comprendere e guidare meglio l'utente.
        Cambia il tono tra il giocoso e il serio in base a come si comporta l'utente. Puoi fare uso di emoji oppure no.
        Basati sulla grammatica e sugli errori dell'utente per capire il suo livello di istruzione per migliorare i consigli.
        Fornisci sempre consigli pratici e concreti, non essere mai vago.

        Se disponibile ti fornirò un sommario della chat precedente. Questo sommario seguirà una struttura specifica:
        1. PROFILO UTENTE (tratti psicologici rilevati)
        2. CONTESTO ATTUALE (di cosa si parlava)
        3. MEMORIA VERBATIM (messaggi esatti citati)

        Usa queste informazioni per riprendere la conversazione in modo naturale, dimostrando di ricordare esattamente cosa è stato detto (specialmente usando la sezione Verbatim).

        Se il sommario è disponibile, rispondi con un messaggio di bentornato personalizzato.
        Altrimenti, inizia con una domanda aperta per conoscere meglio l'utente basandoti sul profilo fornito.
      '''),
    );

    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? "Non ho capito, puoi ripetere?";
    } catch (e) {
      return "Errore AI: $e";
    }
  }

  Future<String> sendMessageWithStreaming(String message, void Function(String) onPartialResponse) async {
    String fullResponse = '';
    try {
      await for (final chunk in _chat.sendMessageStream(Content.text(message))) {
        if (chunk.text != null) {
          fullResponse += chunk.text!;
          onPartialResponse(fullResponse);
        }
      }
      return fullResponse;
    } catch (e) {
      return "Errore AI: $e";
    }
  }

  Future<String> summarizeChat(bool isPremium, List<Map<String, dynamic>>chatHistory) async {
    if (chatHistory.isEmpty) return "Nessuno storico disponibile, la chat è appnea iniziata.";
    try {
      // Usiamo Gemini 3.0 Flash anche per il riassunto premium per velocità ed efficienza,
      // oppure Pro se si vuole massima qualità nell'analisi psicologica.
      final summarizer = GenerativeModel(
        model: isPremium ? 'gemini-3.0-pro-preview' : 'gemini-3.0-flash-preview',
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
      return "Errore nel sommario: $e";
    }
  }
}