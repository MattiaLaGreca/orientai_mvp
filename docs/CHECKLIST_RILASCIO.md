# Checklist di Rilascio (Google Play Store)

Questa checklist guida il processo di pubblicazione della prima versione (V1.0) di OrientAI.

## 📝 1. Aspetti Legali e Privacy
*   [ ] **Privacy Policy:** Generare e ospitare una Privacy Policy (es. su GitHub Pages o Iubenda). Deve citare l'uso di Firebase, AdMob e Gemini AI.
*   [ ] **Terms of Service:** Definire chiaramente che l'AI può commettere errori e non sostituisce una consulenza professionale vincolante.
*   [ ] **GDPR Consent Form:** Assicurarsi che l'SDK di Google Ads mostri il form di consenso GDPR (obbligatorio in Europa).

## 🎨 2. Asset Grafici (Store Listing)
*   [ ] **Icona App:** Formato 512x512 px (PNG). Assicurarsi che sia riconoscibile anche piccola.
*   [ ] **Feature Graphic:** Formato 1024x500 px. Deve catturare l'essenza "Orientamento + AI".
*   [ ] **Screenshots (Telefono):** Minimo 2 per ogni fattore di forma.
    *   *Shot 1:* Onboarding/Login (Mostra la pulizia UI).
    *   *Shot 2:* Chat Screen (Mostra una risposta intelligente).
    *   *Shot 3:* Funzionalità Premium o Active Assistant.

## ⚙️ 3. Configurazione Tecnica di Build
*   [ ] **Keystore:** Generare il file `.jks` per la firma dell'APK/AAB. **NON committare questo file su git.**
*   [ ] **`key.properties`:** Configurare il file per referenziare la keystore, ed escluderlo dal version control.
*   [x] **Version Bumping:** Aggiornare `pubspec.yaml` (es. `version: 1.0.0+1`).
*   [x] **App ID:** Verificare che `com.orientai.app` sia univoco e registrato in Firebase Console.
*   [x] **Obfuscation:** Abilitare R8/ProGuard in `android/app/build.gradle` (`minifyEnabled true` per release).

## 💰 4. Monetizzazione (AdMob)
*   [ ] **app-ads.txt:** Creare e hostare il file `app-ads.txt` sul dominio dello sviluppatore (o sito web app). È essenziale per proteggere le entrate.
*   [ ] **Ad Units Reali:** Sostituire le unità pubblicitarie di test (utilizzate in `lib/screens/chat_screen.dart`) con quelle reali create su AdMob Console.
*   [ ] **Payment Profile:** Completare il profilo pagamenti su Google Play Console e AdMob.
*   [ ] **Reduced Fee Tier (15%):**
    *   Google Play Console: Iscriversi al "15% service fee tier" (Developer Profile -> Associated Developer Accounts).
    *   App Store: Iscriversi all'App Store Small Business Program.

## 🧪 5. Final Smoke Test
*   [ ] Installare la build `release` su un dispositivo fisico reale.
*   [ ] Verificare il Login con un nuovo account.
*   [ ] Verificare che i Banner Ads appaiano.
*   [ ] Verificare che l'AI risponda correttamente (senza mostrare errori tecnici).
