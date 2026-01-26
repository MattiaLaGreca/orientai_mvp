# Piano Operativo di Rilascio (v1.0)

Questo documento orchestra le attività finali per portare OrientAI v1.0 sul Google Play Store. Segue un approccio cronologico per minimizzare il rischio di errori dell'ultimo minuto.

## 📅 Fase 1: Quality Assurance (Giorni 1-2)
*Obiettivo: Assicurarsi che l'app sia stabile e priva di bug critici.*

1.  **Esecuzione Test Manuali:**
    *   Seguire scrupolosamente il **[Piano di Test UAT](PIANO_TEST_UAT.md)**.
    *   Compilare il report di test per ogni dispositivo verificato.
2.  **Verifica Pre-Launch:**
    *   Controllare che i log non espongano API Key (usare `flutter logs`).
    *   Verificare che il banner AdMob sia visibile (in modalità test se non ancora approvati).

## 🎨 Fase 2: Store Preparation (Giorno 3)
*Obiettivo: Preparare tutto il materiale "vendita" per lo store.*

1.  **Copywriting:**
    *   Completare il **[Kit Pubblicazione Store](KIT_STORE.md)** con Titolo, Descrizione Breve e Lunga.
    *   Verificare le keyword SEO (es. "orientamento universitario", "ai", "scelta università").
2.  **Assets Grafici:**
    *   Generare Icona (512x512).
    *   Generare Feature Graphic (1024x500).
    *   Catturare Screenshot (seguendo la guida nel Kit).
3.  **Legal:**
    *   Aggiornare la Privacy Policy (URL pubblico).
    *   Verificare i link nel `ProfileScreen`.

## ⚙️ Fase 3: Build & Release (Giorno 4)
*Obiettivo: Generare l'artefatto finale e caricarlo.*

1.  **Build Finale:**
    *   Seguire il **[Manuale di Rilascio](MANUALE_RILASCIO.md)** per:
        *   Incrementare la versione in `pubspec.yaml`.
        *   Generare l'App Bundle (`.aab`) firmato.
2.  **Upload Console:**
    *   Caricare l'AAB nella traccia "Produzione" (o "Test Chiuso" se si vuole un passaggio intermedio).
    *   Incollare i testi dal Kit Store.
    *   Caricare gli asset grafici.
    *   Impostare il roll-out al 100% (o graduale se preferito).

## 🚀 Fase 4: Post-Launch Monitoring (Day 5+)
*Obiettivo: Rispondere tempestivamente ai primi utenti.*

1.  **Monitoraggio Crash:** Controllare Firebase Crashlytics ogni 4 ore.
2.  **Feedback Utenti:** Rispondere a tutte le recensioni sullo store entro 24h.
3.  **Analisi Monetizzazione:** Verificare su AdMob che le impression vengano conteggiate.

---
**Nota:** Ogni fase deve essere completata prima di passare alla successiva.
