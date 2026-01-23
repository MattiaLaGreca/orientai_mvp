# OrientAI - Recap del Progetto

Questo documento serve come "memoria locale" per il progetto OrientAI. Descrive la missione, l'architettura tecnica, le logiche chiave e la visione futura dell'applicazione.

## 🎯 Missione
**OrientAI** è un assistente virtuale dedicato all'orientamento scolastico e universitario per studenti italiani.
L'obiettivo è fornire consigli personalizzati basati sugli interessi, le attitudini e il percorso scolastico attuale dell'utente, aiutandolo a navigare le complessità della scelta universitaria o lavorativa.

---

## 🛠 Stack Tecnologico
*   **Frontend:** Flutter (Dart).
*   **Backend:** Firebase (Authentication, Firestore).
*   **AI:** Google Generative AI (Gemini 2.5 Flash Lite / Pro).
*   **Monetizzazione:** Google Mobile Ads (Banner implementati per utenti Free).
*   **State Management:** Approccio ibrido con `StreamBuilder` per dati realtime e `StatefulWidget` locali per UI effimera.

---

## 📂 Struttura del Codice

### Entry Point & Navigazione (`lib/main.dart`)
*   **`AuthWrapper`**: Gestisce il routing principale.
    *   Se l'utente non è loggato -> `LoginScreen`.
    *   Se l'utente è loggato ma non ha un profilo (nome mancante) -> `OnboardingScreen`.
    *   Se l'utente è loggato e ha un profilo completo -> `ChatScreen`.

### Servizi (`lib/services/`)
1.  **`OrientAIService` (`ai_service.dart`)**:
    *   Gestisce l'interazione con l'API di Gemini.
    *   Seleziona il modello in base allo status dell'utente:
        *   **Premium:** `gemini-2.5-pro` (Più capace/intelligente).
        *   **Free:** `gemini-2.5-flash-lite` (Più economico ed efficiente).
    *   **Funzioni Chiave:**
        *   `init`: Imposta il *System Instruction*.
        *   `summarizeChat`: Genera un riassunto delle conversazioni passate per mantenere la memoria a lungo termine.
        *   `sendMessageWithStreaming`: Gestisce la risposta token-by-token (Utilizzato per utenti Premium).

2.  **`DatabaseService` (`database_service.dart`)**:
    *   Wrapper per le chiamate a Firestore.
    *   Salva messaggi, profili utente e gestisce i riassunti della chat.

### Schermate (`lib/screens/`)
*   **`LoginScreen`**: Gestione Auth (Login/Register). Include validazione email e password (min 6 caratteri).
*   **`OnboardingScreen`**: Raccolta dati iniziali (Nome, Scuola, Interessi). Include validazione campo nome e capitalizzazione automatica.
*   **`ChatScreen`**: Il cuore dell'app. Gestisce la UI della chat, lo streaming delle risposte (Premium) e il rendering Markdown. Visualizza Banner Ad per utenti Free.

---

## 🧠 Logica AI & Prompting
Il comportamento dell'AI è definito in `OrientAIService`.

**System Instruction (Sintesi):**
> "Sei OrientAI, un esperto orientatore scolastico italiano... Considera che lo studente può essere più portato per lo studio o per il lavoro pratico... Cerca di capire la personalità dell'utente... Basati sulla grammatica per capire il livello di istruzione."

**Adattabilità:**
*   **Utente Premium:** "non fare risposte troppo prolisse... sii veloce e mettici la cura che ci vuole per un utente pagante".
*   **Utente Free:** "sii conciso e veloce".

**Memoria (Context Window):**
L'app utilizza un sistema di "Summarization". All'avvio della chat:
1.  Carica lo storico recente.
2.  Carica l'ultimo sommario disponibile.
3.  L'AI genera un nuovo sommario basato sugli ultimi scambi.
4.  Questo sommario viene iniettato come contesto (`system message`) all'avvio della sessione successiva, permettendo all'AI di "ricordare" chi è l'utente senza dover rileggere l'intera cronologia (risparmio token).

---

## 🚀 Finestra sul Futuro (Roadmap)

### Sfide Attuali
*   **Dati non aggiornati (Allucinazioni):** L'AI, essendo un modello pre-addestrato, può avere informazioni obsolete o errate su specifici corsi universitari.
    *   *Esempio Reale:* Difficoltà nel reperire informazioni corrette sul corso di "Biologia Molecolare triennale a Padova" (l'AI potrebbe negarne l'esistenza o fornire dettagli vecchi).

### Obiettivi Tecnici
1.  **RAG (Retrieval-Augmented Generation):**
    *   Implementare un sistema per "iniettare" conoscenze aggiornate nel prompt.
    *   Collegare l'AI a database ufficiali (es. Universitaly, siti atenei) o permettere la ricerca web in tempo reale per verificare l'esistenza e i programmi dei corsi.
2.  **Tool Use (Function Calling):**
    *   Dotare l'AI della capacità di chiamare funzioni specifiche, es: `cercaCorso(universita, nomeCorso)` per ottenere dati strutturati e reali prima di rispondere.
3.  **Miglioramento Profilazione:**
    *   Rendere il profilo utente dinamico: l'AI dovrebbe poter aggiornare gli "interessi" nel database man mano che li scopre chattando.
