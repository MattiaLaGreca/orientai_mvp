# Piano Finanziario e Strategia di Pubblicazione - OrientAI

Redatto da: Jules, Consulente Tecnico-Finanziario
Data: 25 Gennaio 2026

Questo documento integra la strategia di sostenibilità esistente con azioni pratiche immediate per il contesto italiano e "bootstrapped".

## 1. Analisi Fiscale Italia (Breve Termine - < 5.000€/anno)

L'obiettivo è ridurre a **zero** i costi fissi burocratici finché l'app non genera entrate costanti.

### Fase 1: Prestazione Occasionale (Lo "Scudo" Iniziale)
In Italia, è possibile generare reddito senza Partita IVA se l'attività è **non abituale** e i ricavi netti sono sotto i 5.000€ annui.

*   **Pubblicità (AdMob):** Google richiede dati fiscali. Inserire il proprio Codice Fiscale. I guadagni vanno dichiarati come "Redditi Diversi" nel 730/Modello Unico.
    *   *Attenzione:* Se i pagamenti diventano mensili e regolari, l'Agenzia delle Entrate potrebbe contestare l'abitualità. **Soluzione:** Impostare la soglia di pagamento AdMob alta (es. 200€ o 500€) per ricevere pochi bonifici sporadici all'anno, rafforzando il concetto di "occasionalità".
*   **Donazioni (Ko-fi/PayPal):** Sono tecnicamente "donazioni modiche". Se rimangono sotto soglie ragionevoli, non richiedono tassazione complessa, ma vanno tracciate.

### Fase 2: Regime Forfettario (Il passo successivo)
Appena si prevede di superare i 5.000€ o la ricorrenza diventa mensile:
*   **Codice ATECO:** 62.01.00 (Sviluppo Software).
*   **Costo Fisso:** ~4.000€/anno (INPS Gestione Commercianti) + Commercialista.
*   **Strategia:** Non aprire P.IVA finché l'app non garantisce almeno 600€/mese di ricavi certi per coprire i costi fissi.

## 2. Strategia di Pubblicazione & Store Optimization

### Google Play Store (Android) - Priorità 1
*   **Costo:** 25$ (Una tantum). Accessibile.
*   **Fee:** 15% (iscrivendosi al programma "15% service fee tier").
*   **Azione:** Pubblicare qui per primi. È il mercato più grande per gli studenti in Italia e permette iterazioni veloci.

### Apple App Store (iOS) - Priorità 2
*   **Costo:** 99$/anno. Costoso per chi inizia.
*   **Strategia:** Posticipare il rilascio iOS finché la versione Android non ha una base utenti attiva o finché non si recuperano i 99$ tramite donazioni/ads Android.
*   **Nota:** Gli studenti universitari hanno una % più alta di iPhone rispetto alla media, quindi è un mercato necessario sul medio termine.

## 3. Fonti di Finanziamento Alternative (Fuori App)

Per "sostenere il progetto" senza dipendere solo dagli utenti finali (studenti squattrinati).

### A. B2B: Università e Istituti Scolastici
Le scuole superiori hanno fondi per l'orientamento (PNRR, fondi istituto).
*   **Proposta:** Vendere una versione "White Label" o licenze bulk di OrientAI alle scuole.
*   **Valore:** La scuola offre il servizio ai maturandi come benefit.
*   **Implementazione:** Non serve codice nuovo. Basta fornire codici promozionali "Premium" che la scuola compra in blocco e distribuisce agli studenti.

### B. Affiliazioni "Intelligenti"
Non solo Amazon.
*   **Corsi di Laurea Online (Telematiche):** Molte università telematiche pagano bene per i lead (studenti interessati). Se l'AI suggerisce un percorso compatibile, un link "Scopri i corsi online" può generare revenue significativa (CPA - Cost Per Action).

### C. Crowdfunding "Goal-Based"
Invece di chiedere soldi generici, chiedi soldi per obiettivi specifici sulla pagina Ko-fi/Patreon.
*   *"A 50€ al mese pago il server."*
*   *"A 200€ totali pago la licenza Apple Developer per fare l'app iOS."*
La trasparenza aumenta la propensione alla donazione.

## 4. Ottimizzazione Costi Tecnici (Il "Codice Economico")

Le modifiche tecniche proposte mirano a ridurre le due voci di costo principali: **Letture Database** e **Token AI**.

1.  **Database (Firestore):**
    *   *Problema:* Leggere 500 messaggi ogni volta che l'AI deve rispondere costa.
    *   *Soluzione:* Limitare il recupero della "Memoria a Breve Termine" agli ultimi 20-30 messaggi. Il resto è gestito dal Sommario (che è una sola lettura).

2.  **AI (Gemini):**
    *   *Modello:* Confermare l'uso di `flash-lite` (costo irrisorio).
    *   *Prompt:* Ridurre i caratteri del System Prompt. Ogni carattere inviato si paga. Togliere aggettivi superflui.

## 5. Roadmap Operativa Suggerita

1.  **Oggi:** Implementare limiti tecnici (vedi codice).
2.  **Settimana 1:** Pubblicazione Android (Alpha/Beta).
3.  **Mese 1:** Validazione tramite canali social (TikTok/Instagram Reels sono organici e gratuiti).
4.  **Mese 3:** Valutazione metriche. Se retention > 20%, valutare porting iOS.

---
*Disclaimer: Le informazioni fiscali sono a scopo illustrativo basato sulla normativa vigente al 2026 per il settore digitale. Consultare sempre un commercialista.*
