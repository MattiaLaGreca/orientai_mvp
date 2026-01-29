# OrientAI - Masterplan di Progetto

Questo documento serve come punto di ingresso per la documentazione di OrientAI. Definisce la missione, l'architettura tecnica e rimanda ai documenti operativi specifici.

## 📊 Status Progetto
**Fase Attuale:** Pre-Launch (MVP Ready)
*   Il focus attuale è sulla finalizzazione dei requisiti manuali per il primo rilascio pubblico (V1.0).
*   Priorità: GDPR Consent, AdMob Setup, Firma Digitale, Assets Store.

---

## 🎯 Missione: Active Assistant
**OrientAI** non è solo una chat, ma un **Assistente Attivo** per l'orientamento scolastico e universitario.
L'obiettivo è fornire consigli personalizzati e proattivi ("Smart Retention"), aiutando gli studenti italiani a navigare le complessità della scelta universitaria con un tono professionale ma accessibile (e tatticamente "gamificato" dove serve).

---

## 📚 Documentazione Operativa
*   **[ROADMAP TECNICA](docs/ROADMAP_TECNICA.md)**: Il piano di sviluppo dettagliato (Stability, Release Prep, Core Features).
*   **[MANUALE DI RILASCIO](docs/MANUALE_RILASCIO.md)**: Guida tecnica per compilare, firmare e pubblicare l'app.
*   **[CHECKLIST DI RILASCIO](docs/CHECKLIST_RILASCIO.md)**: Lista di controllo per asset, aspetti legali e configurazioni finali.
*   **[STRATEGIA SOSTENIBILITÀ](docs/STRATEGIA_SOSTENIBILITA.md)**: Analisi costi/ricavi, gestione token e monetizzazione.

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
