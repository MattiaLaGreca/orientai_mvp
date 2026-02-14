# OrientAI 🎓

**L'Assistente IA per l'Orientamento Universitario.**

OrientAI è un'applicazione mobile sviluppata in Flutter che aiuta gli studenti a scegliere il proprio percorso universitario tramite un'intelligenza artificiale conversazionale avanzata.

## ✨ Funzionalità Principali

*   **Chat Intelligente:** Interagisci con un assistente virtuale specializzato in orientamento, alimentato da **Google Gemini 2.5** (Flash-Lite per utenti Free, Pro per utenti Premium).
*   **Memoria Contestuale:** L'IA ricorda i dettagli della conversazione per offrire consigli coerenti e personalizzati.
*   **Gestione Profilo:** Salva interessi, background scolastico e obiettivi per raffinare i suggerimenti.
*   **Modello Sostenibile:** Accesso gratuito supportato da pubblicità (AdMob) o esperienza Premium senza interruzioni.
*   **Sicurezza:** Gestione robusta degli errori, logging sanitizzato (PII protection), sanitizzazione input e validazione URL (anti-XSS).

## 🛠️ Tech Stack

*   **Frontend:** Flutter (Dart 3.x)
*   **Backend:** Firebase (Authentication, Cloud Firestore)
*   **AI Engine:** Google Generative AI SDK (`google_generative_ai`)
*   **Monetization:** Google Mobile Ads (AdMob)
*   **Architecture:** Service-Repository pattern con Dependency Injection (DI) manuale per garantire la testabilità unitaria.

## 🚀 Per Iniziare

### 1. Prerequisiti
*   Flutter SDK (v3.38.7 o superiore)
*   Dart SDK
*   Un progetto Firebase attivo.

### 2. Configurazione Segreti
Il progetto utilizza un file ignorato da Git per proteggere le chiavi API sensibili.
Creare il file `lib/secrets.dart` e inserire la propria chiave Gemini:

```dart
// lib/secrets.dart
const String GEMINI_API_KEY = "LA_TUA_CHIAVE_GEMINI_QUI";
```

> **Nota:** Per eseguire i test in CI/CD, viene generato un file dummy automaticamente.

### 3. Esecuzione
Scaricare le dipendenze e avviare l'app:

```bash
flutter pub get
flutter run
```

### 4. Testing
Il progetto mantiene un'alta copertura di test unitari sui servizi core.

```bash
flutter test
```

## 📦 Rilascio

Il progetto è configurato per la generazione di build Android ottimizzate (R8/ProGuard) e firmate.
Per generare l'AAB per il Play Store, seguire le istruzioni dettagliate in:

*   [📦 Manuale di Rilascio](docs/MANUALE_RILASCIO.md)

## 📂 Documentazione Utile

Tutta la documentazione di progetto si trova nella cartella `docs/`:

*   [🚦 Status Report](docs/STATUS_REPORT.md): Stato corrente del progetto.
*   [🗺️ Roadmap Tecnica](docs/ROADMAP_TECNICA.md): Pianificazione delle feature e del debito tecnico.
*   [📦 Manuale di Rilascio](docs/MANUALE_RILASCIO.md): Guida alla generazione della build di produzione (Keystore, Obfuscation, Play Store).
*   [💰 Strategia di Sostenibilità](docs/STRATEGIA_SOSTENIBILITA.md): Piano finanziario e fiscale.

---
*OrientAI - Guida il tuo futuro.*
