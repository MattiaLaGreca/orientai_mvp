# Roadmap Tecnica di OrientAI

Questo documento definisce il percorso tecnico per portare OrientAI al rilascio (V1.0) e oltre. Le priorità sono basate sulla strategia "Android First" e sul focus "Active Assistant".

## 🟢 Fase 1: Stabilità e Debito Tecnico (Pre-Launch)
*Obiettivo: Garantire che l'app non crashi e sia sicura prima di arrivare nelle mani degli utenti.*

### 1.1 Testing Infrastructure
*   [x] **Unit Tests:** Estendere la copertura test per `OrientAIService` (mockando le risposte di Gemini) e `DatabaseService`.
*   [x] **Security Tests:** Test specifici per Prompt Injection.
*   [ ] **Widget Tests:** (Deferred to V1.1) Testare il rendering della `ChatScreen` e la gestione degli errori.
*   [ ] **Integration Tests:** (Deferred to V1.1) Testare il flusso completo Login -> Chat.

### 1.2 Gestione Errori e Sicurezza
*   [x] **API Key Isolation:** Segregazione delle chiavi API in `lib/secrets.dart` (non committato).
*   [x] **Input Sanitization:** Validazione e pulizia input utente (`Validators`) per prevenire injection e formattazione errata.
*   [x] **User-Facing Error Messages:** Implementata gestione errori (`OrientAIException`) con messaggi user-friendly.
*   [x] **Privacy Logs:** Implementato `SecureLogger` per sanitizzare i log in produzione.

---

## 🔵 Fase 1.5: Release Engineering (Launch Prep)
*Obiettivo: Preparare l'infrastruttura di rilascio, la conformità legale e gli asset per lo store.*

### 1.5.1 Build Configuration
*   [x] **Keystore Management:** Generare la chiave di upload/release (`.jks`) e configurare `key.properties`.
*   [x] **Version Bumping:** Gestire il versionamento semantico in `pubspec.yaml` (es. `1.0.0+1`).
*   [x] **Obfuscation:** Verificare configurazione ProGuard/R8 per la build release.

### 1.5.2 Legal & Compliance
*   [x] **Privacy Policy:** Generare e ospitare la policy (link in app e sullo store).
*   [ ] **GDPR Consent:** Verifica implementazione UMP SDK per AdMob.

### 1.5.3 Store Assets
*   [ ] **Listing Graphics:** Creare icona, feature graphic e screenshot.
*   [ ] **Store Description:** Scrivere testi SEO-oriented per Google Play.

---

## 🟡 Fase 2: Core Experience & Active Assistant (V1.0 Launch Scope)
*Obiettivo: Differenziare OrientAI dai competitor generici tramite funzionalità proattive.*

### 2.1 Context Enrichment (Multimodalità)
*   **Feature:** Permettere agli utenti di caricare immagini (es. screenshot di piani di studio) o PDF (es. bandi di concorso).
*   **Implementazione:**
    *   UI: Aggiungere bottone "Allega" nella `ChatScreen`.
    *   Logic: Aggiornare `OrientAIService` per accettare `File` e inviarli a Gemini 2.5 Pro (o Flash Lite se supportato).
    *   Storage: Gestire l'upload temporaneo su Firebase Storage o invio diretto in base64 (se le dimensioni lo permettono).

### 2.2 Active Assistant (Smart Retention)
L'AI non deve solo rispondere, ma *guidare*.
*   **Feature:** Notifiche generate dall'AI ("Ehi, com'è andato il test di oggi?").
*   **Implementazione:**
    *   Analisi periodica (Cloud Functions o background service) delle chat recenti per identificare date importanti (es. "Ho il test il 15 ottobre").
    *   Scheduling notifiche locali.

---

## 🔴 Fase 3: Data Integrity & Freshness (Post-Launch / V1.1)
*Obiettivo: Risolvere il problema delle "Allucinazioni" sui corsi specifici.*

### 3.1 RAG (Retrieval-Augmented Generation) Lite
*   **Problema:** Dati obsoleti su corsi specifici (es. Biologia Molecolare a Padova).
*   **Soluzione:**
    *   Creare un indice vettoriale (o ricerca semplice) su documenti ufficiali.
    *   Permettere all'utente di fornire il link al sito dell'ateneo: l'AI lo legge (tramite `view_text_website` capability lato backend o scraping) e risponde basandosi su quello.

---

## ⚪ Funzionalità Differite (V2.0+)
*   **Voice Mode:** Interazione vocale completa (Posticipata per complessità e costi).
*   **Community:** Forum o chat di gruppo (Posticipata per moderazione e privacy).
