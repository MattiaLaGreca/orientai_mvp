import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OrientAIService {
  // ⚠️ IMPORTANTE: Assicurati che qui ci sia la tua API KEY corretta!
  static String get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env');
    }
    return key;
  }
  
  late final GenerativeModel _model;
  late final ChatSession _chat;

  // MODIFICA: Ora init accetta isPremium
  void init(String studentName, String promptDetails, bool isPremium) {
    
    final modelName = isPremium ? 'gemini-2.5-flash' : 'gemini-2.5-flash-lite';

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

        Se disponibile ti fornirò un sommario della chat precedente per aiutarti a ricordare il contesto.
        Se disponibile rispondi quindi con un messaggio di bentornato personalizzato per riprendere la conversazione.
        Altrimenti, se non disponibile, inizia con una domanda aperta per conoscere meglio l'utente basandoti sul profilo fornito.
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
      final summarizer = GenerativeModel(
        model: isPremium ? 'gemini-2.5-pro' : 'gemini-2.5-flash-lite',
        apiKey: _apiKey,
        systemInstruction: Content.system('''
          Riceverai alcuni messaggi di una chat tra uno studente e OrientAi, un bot specializzato in orientamento scolastico italiano.
          Dovrai riassumere il topic della chat, fare un profilo con tratti psicologici, propensioni, pattern dell'utente e altro di rilevante.
          Fornisci la risposta il più breve possibile, solo informazioni rilevanti così da risparimiare token, con un focus soprattutto sugli ultimi messaggi per mantenere meglio il contesto.
          Se presente, riceverai anche il sommario precedente assieme ai messaggi della chat, usalo per migliorare il tuo contesto.

          Tutto ciò che scrivi qui NON verrà mostrato all'utente, quindi non includere saluti o messaggi di bentornato.
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