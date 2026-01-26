# OrientAI - Masterplan di Progetto

Questo documento serve come punto di ingresso per la documentazione di OrientAI. Definisce la missione, l'architettura tecnica e rimanda ai documenti operativi specifici.

## 📊 Status Progetto
**Fase Attuale:** Pre-Release (Release Engineering)
*   Il focus attuale è sulla preparazione del primo rilascio pubblico (V1.0) per Android.
*   Priorità: Configurazione Build, Firma Digitale, Conformità Legale, Assets Store.

---

## 🎯 Missione: Active Assistant
**OrientAI** non è solo una chat, ma un **Assistente Attivo** per l'orientamento scolastico e universitario.
L'obiettivo è fornire consigli personalizzati e proattivi ("Smart Retention"), aiutando gli studenti italiani a navigare le complessità della scelta universitaria con un tono professionale ma accessibile (e tatticamente "gamificato" dove serve).

---

## 📚 Documentazione Operativa

### 🚀 Release Management (V1.0)
*   **[PIANO OPERATIVO RILASCIO](docs/PIANO_OPERATIVO_RILASCIO.md)**: ⭐️ **Start Here**. Il workflow cronologico per il lancio.
*   **[PIANO TEST UAT](docs/PIANO_TEST_UAT.md)**: Sceneggiatura per il test manuale (Smoke Test).
*   **[KIT STORE](docs/KIT_STORE.md)**: Testi e checklist per la scheda Google Play.
*   **[MANUALE DI RILASCIO](docs/MANUALE_RILASCIO.md)**: Guida tecnica per compilare e firmare l'APK/AAB.

### 📐 Strategia & Sviluppo
*   **[ROADMAP TECNICA](docs/ROADMAP_TECNICA.md)**: Visione a lungo termine e fasi di sviluppo.
*   **[STRATEGIA SOSTENIBILITÀ](docs/STRATEGIA_SOSTENIBILITA.md)**: Analisi costi/ricavi e monetizzazione.
*   **[CHECKLIST DI RILASCIO](docs/CHECKLIST_RILASCIO.md)**: (Legacy) Lista di controllo puntuale.

---

## 🛠 Stack Tecnologico
*   **Frontend:** Flutter (Dart).
*   **Backend:** Firebase (Authentication, Firestore, Storage).
*   **AI:** Google Generative AI (Gemini 2.5 Flash Lite / Pro).
*   **Monetizzazione:** Google Mobile Ads (Banner).

---

## 📂 Struttura del Codice Principale

### Entry Point (`lib/main.dart`)
*   **`AuthWrapper`**: Routing dinamico (Login -> Onboarding -> Chat).

### Servizi (`lib/services/`)
1.  **`OrientAIService`**: Gestione AI (Flash Lite per Free, Pro per Premium). Gestisce context window e summarization.
2.  **`DatabaseService`**: Wrapper Firestore per messaggi e profili.

### Schermate (`lib/screens/`)
*   **`ChatScreen`**: UI principale con supporto streaming e Markdown.
*   **`OnboardingScreen`**: Profilazione iniziale (interessi, scuola).
*   **`LoginScreen`**: Autenticazione ibrida (Login/Register).

---

## 🧠 Logica Chiave

### Summarization & Memoria
Per ottimizzare i token, l'app riassume periodicamente la chat.
*   *Vedi codice in:* `OrientAIService.summarizeChat`.

### Profilazione Dinamica
L'app distingue tra utenti Free e Premium non solo per il modello AI usato, ma per la "profondità" della risposta e la presenza di pubblicità.
