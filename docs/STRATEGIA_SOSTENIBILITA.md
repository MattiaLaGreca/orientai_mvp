# Strategia di Sostenibilità Finanziaria OrientAI

Questo documento delinea la strategia per garantire la sostenibilità economica del progetto OrientAI, con un focus specifico sul contesto italiano, sulla minimizzazione dei costi iniziali e sulla scalabilità futura.

## 1. Analisi del Contesto e Burocrazia Italiana (Breve Termine)

Avviare una startup in Italia comporta costi fissi elevati (INPS, Camera di Commercio, Commercialista) che possono soffocare un progetto nella fase "pre-revenue".

### Strategia Consigliata: "Validazione Low-Cost"

1.  **Prestazione Occasionale (Fino a 5.000€):**
    *   **Cosa è:** Permette di ricevere pagamenti senza aprire Partita IVA, purché non sia un'attività "abituale" e non si superino i 5.000€ netti annui.
    *   **Vantaggio:** Zero costi fissi. Si paga una ritenuta d'acconto del 20% sul compenso lordo (se il committente è sostituto d'imposta) o si dichiara in 730.
    *   **Applicazione:** Ideale per i primi mesi di validazione, per ricevere piccole sponsorizzazioni o donazioni tracciate.
    *   **Nota:** Google Play e App Store potrebbero richiedere informazioni fiscali. Per i privati, spesso è possibile operare come sviluppatore individuale fino a certe soglie, ma è fondamentale consultare un commercialista per la configurazione specifica sugli store.

2.  **Partita IVA Forfettaria (Start-up):**
    *   **Quando attivarla:** Solo DOPO aver validato che l'app genera entrate ricorrenti prevedibili.
    *   **Costi:** Imposta sostitutiva al 5% per 5 anni.
    *   **Il Problema INPS:** I contributi previdenziali (Gestione Commercianti) sono fissi (~4.000€/anno) indipendentemente dal fatturato.
    *   **Soluzione Studenti/Lavoratori:** Se si è già dipendenti full-time o iscritti ad altre casse, si può chiedere l'esenzione o riduzione. Se si è studenti *senza* altro lavoro, questo costo è l'ostacolo principale.

**Consiglio Operativo:** Non aprire P.IVA finché non c'è un "Product-Market Fit" chiaro. Usa la fase di sviluppo per costruire community e brand senza transazioni commerciali dirette se possibile, o limitandosi a donazioni spontanee (Ko-fi/BuyMeACoffee) che rientrano più facilmente nelle liberalità o redditi diversi.

## 2. Ottimizzazione dei Costi Tecnici (Cost Control)

L'AI Generativa è costosa. Ogni chat consuma "token".

### Strategia "Token Economy"
1.  **Modelli Ibridi:**
    *   **Free Tier:** Usa `gemini-2.5-flash-lite`. È estremamente economico (~$0.10 per 1M token input).
    *   **Premium Tier:** Usa `gemini-2.5-pro` per ragionamenti complessi.
2.  **Gestione della Memoria (Context Window):**
    *   *Problema:* Inviare 50 messaggi di storico ogni volta costa molto.
    *   *Soluzione:* Per gli utenti Free, limitiamo lo storico agli ultimi 10-15 messaggi + un "Sommario" generato periodicamente. Questo riduce i costi del 70%.
3.  **Caching e Summarization:**
    *   Usare un modello leggero (Flash Lite) per riassumere le chat vecchie invece di portarsele dietro "nude e crude".

## 3. Fonti di Sostegno Esterne (Alternative all'In-App Purchase)

Dato che gli studenti hanno bassa disponibilità economica, monetizzare *solo* loro è difficile. Bisogna monetizzare l'ecosistema *attorno* a loro.

### A. Partnership B2B (Business-to-Business)
*   **Università e Scuole:** Le università pagano molto per l'orientamento (Lead Generation). OrientAI può offrire alle università dei "badge" o "profili verificati" per presentarsi agli studenti in target.
*   **Enti di Formazione / Tutoring:** Partnership con servizi come Alpha Test, Cepu, o insegnanti privati. L'app può suggerire risorse di studio (affiliazione).

### B. Crowdfunding "Soft"
*   Integrare link a piattaforme come **Ko-fi** o **Buy Me A Coffee** nella sezione "Informazioni" o dopo una chat particolarmente utile ("Ti sono stato utile? Offrimi un caffè per mantenermi vivo"). È meno invasivo della pubblicità e crea empatia.

### C. Bandi e Grant
*   Monitorare "Smart & Start Italia" o bandi regionali per l'innovazione digitale e l'istruzione. Spesso coprono costi a fondo perduto.

## 4. Strategia di Pubblicazione

### ASO (App Store Optimization)
Prima di spendere in ads, ottimizzare la scheda store:
*   **Parole Chiave:** "Orientamento universitario", "Scelta università", "Test ingresso", "Consigli studio".
*   **Screenshot:** Mostrare domande reali e risposte utili, non solo schermate di login.

### Android First
*   Costo dev: 25$ una tantum (contro 99$/anno di Apple).
*   Pubblico italiano: Alta penetrazione Android nella fascia studentesca.

### Checklist Tecnica (Pre-Rilascio)
Prima di caricare l'app su Google Play Console, è necessario modificare i seguenti file:

1.  **Application ID:**
    *   In `android/app/build.gradle.kts`, modificare `applicationId` da `com.example.orientai_mvp` a `com.orientai.app` (o quello registrato su Google Play).
    *   **Importante:** Aggiornare il file `google-services.json` scaricandolo nuovamente dalla console Firebase dopo aver aggiunto il nuovo package name.

2.  **Firma (Signing):**
    *   Generare un keystore di rilascio (`.jks`).
    *   Configurare `signingConfigs` in `android/app/build.gradle.kts` (non usare le chiavi di debug!).

3.  **Minificazione:**
    *   Attivare `isMinifyEnabled = true` e `isShrinkResources = true` nella build release per ridurre la dimensione dell'APK.

## 5. Roadmap Finanziaria

1.  **Fase 1 (Mesi 1-3):** Pubblicazione MVP su Android. Modello Free con Ads (Banner). Nessuna P.IVA. Obiettivo: Feedback e Retention. Costi coperti da fondi personali (server costs minimi grazie a Flash Lite).
2.  **Fase 2 (Mesi 3-6):** Introduzione "Support Us" (Donazioni). Partnership pilota con 1 ente di formazione o università locale.
3.  **Fase 3 (Mese 6+):** Se MRR (Monthly Recurring Revenue) > 1000€, apertura P.IVA Forfettaria e lancio Premium Subscription formale.
