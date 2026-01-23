# Strategia Finanziaria e di Sostenibilità per OrientAI

Questo documento delinea le linee guida strategiche per garantire la sostenibilità economica del progetto OrientAI, con un focus particolare sul breve termine e sul contesto italiano.

## 1. Ottimizzazione dei Costi Tecnici (Code-Level)

Per mantenere bassi i costi operativi (OpEx) mentre l'app scala, sono necessarie le seguenti azioni immediate:

*   **Intelligenza Artificiale (Il costo maggiore)**:
    *   **Tier Gratuito**: Utilizzare rigorosamente modelli "Flash" (es. `gemini-1.5-flash`). Hanno un costo per token estremamente basso (o nullo entro certi limiti) pur mantenendo ottime capacità di ragionamento veloce.
    *   **Prompt Engineering**: Ridurre la lunghezza delle "System Instructions" per gli utenti gratuiti. Meno token in ingresso = meno costi per chiamata.
    *   **Summarization**: Utilizzare sempre il modello più economico per riassumere le chat. Non serve un modello "Pro" per sintetizzare del testo.

*   **Database (Firebase)**:
    *   **Limitazione Query**: Evitare di scaricare l'intera cronologia della chat ogni volta che l'AI deve rispondere. Implementare limiti (es. ultimi 50 messaggi) e caricamento incrementale.
    *   **Caching**: Salvare i riassunti della chat localmente o sul DB per evitare di doverli rigenerare ad ogni avvio dell'app.

## 2. Modelli di Monetizzazione (Revenue Stream)

Considerando il target studentesco (bassa disponibilità di spesa), si consiglia un approccio ibrido:

### A. Modello Freemium (Attuale)
*   **Utenti Free**: Accesso illimitato ma con modello AI standard (`Flash`) e presenza di banner pubblicitari non invasivi.
*   **Utenti Premium**: Accesso a modello AI avanzato (`Pro`), nessuna pubblicità, risposte più approfondite/psicologiche.
    *   *Prezzo consigliato*: 2.99€ - 4.99€ / mese (prezzo "caffè").

### B. Pubblicità (AdMob)
*   Integrare **Banner Ads** nella schermata di chat per gli utenti Free.
*   *Nota*: Evitare video interstiziali che interrompono il flusso della conversazione (dannosi per la retention).

### C. Affiliate Marketing (Esterno all'App)
*   Proporre link affiliati (Amazon o altro) per libri di test ammissione, corsi di preparazione o materiale di studio consigliato dall'AI.
*   *Esempio*: Se l'AI consiglia "Medicina", può suggerire "Alpha Test Medicina" con link affiliato.

## 3. Strategia di Pubblicazione e Lancio

### Store Strategy
1.  **Android First**:
    *   Costo: 25$ (una tantum).
    *   Vantaggio: Costo basso, iterazione veloce, ampia base utenti studentesca.
2.  **iOS (Apple App Store)**:
    *   Costo: 99€ / anno.
    *   Consiglio: Pubblicare su iOS solo dopo aver validato il prodotto su Android e generato i primi ricavi.

### Marketing a Costo Zero
*   **TikTok / Instagram Reels**: Creare contenuti brevi che mostrano risposte divertenti o "shocking" dell'AI su facoltà universitarie. È il canale principale per il target Gen Z.
*   **Gruppi Telegram/Discord Studenteschi**: Promozione organica nelle community di maturandi.

## 4. Aspetti Fiscali e Burocratici (Italia)

*Disclaimer: Queste sono indicazioni generali, consultare sempre un commercialista.*

### Fase 1: Validazione (Breve Termine)
*   **Prestazione Occasionale**: Fino a 5.000€ lordi annui (ricevute con ritenuta d'acconto). Non richiede apertura Partita IVA immediata se l'attività non è "organizzata e continuativa". Tuttavia, la vendita su Store potrebbe essere vista come continuativa.
*   *Consiglio*: Per i primissimi test, rilasciare l'app come "Beta Testing" gratuito o raccogliere donazioni volontarie (es. "Offrimi un caffè") che sono più flessibili, prima di attivare abbonamenti ricorrenti.

### Fase 2: Crescita (Medio Termine)
*   **Partita IVA Forfettaria**:
    *   Tassazione agevolata (5% per i primi 5 anni + contributi INPS).
    *   Costi fissi: Commercialista (~500-1000€/anno) + Contributi minimali.
    *   Da attivare solo quando si prevede un flusso costante di entrate che copra almeno i costi fissi.

## 5. Finanziamenti Esterni Alternativi

Per sostenere i costi iniziali senza intaccare il proprio portafoglio:

1.  **Donazioni / Crowdfunding Leggero**:
    *   Piattaforme: **Ko-fi** o **BuyMeACoffee**.
    *   Inserire un link nel profilo dell'app: "Sostieni lo sviluppo". Molto ben visto nelle community open/indie.

2.  **Bandi Pubblici**:
    *   **Resto al Sud** (se residenti al sud).
    *   **Smart & Start Italia** (Invitalia).
    *   **PIN** (regionali).
    *   *Pro*: Fondi perduti. *Contro*: Burocrazia complessa.

3.  **Incubatori Universitari**:
    *   Molte università hanno "Contamination Lab" o incubatori per startup studentesche che offrono spazi e talvolta piccoli fondi o crediti cloud (AWS/Google Cloud credits for Startups).
