# Piano di Test UAT (User Acceptance Testing)

Questo documento definisce gli scenari di test manuale da eseguire prima di ogni rilascio (V1.0 Smoke Test).

**Dispositivo Test:** Android Fisico (Raccomandato)
**Versione App:** Release Candidate (build `release`)

---

## 🧪 Scenario 1: Onboarding (Fresh Install)
*Obiettivo: Verificare che un nuovo utente possa registrarsi e iniziare senza intoppi.*

| # | Azione | Risultato Atteso | Status |
|---|---|---|---|
| 1 | Installare ed aprire l'app per la prima volta. | Schermata di Login visibile. | [ ] |
| 2 | Cliccare su "Non hai un account? Registrati". | Passaggio alla form di registrazione. | [ ] |
| 3 | Inserire email/password validi e registrarsi. | Reindirizzamento all'Onboarding. | [ ] |
| 4 | Compilare nome, scuola e interessi. | Campi con validazione (no vuoti). | [ ] |
| 5 | Confermare. | Accesso alla **Chat Screen**. Messaggio di benvenuto dell'AI. | [ ] |

## 🧪 Scenario 2: Chat Experience & AI
*Obiettivo: Verificare la qualità della risposta e la stabilità tecnica.*

| # | Azione | Risultato Atteso | Status |
|---|---|---|---|
| 1 | Inviare "Voglio studiare medicina a Milano". | Risposta in streaming (testo che appare progressivamente). | [ ] |
| 2 | Verificare il contenuto. | Risposta pertinente, formattata (Markdown), tono professionale. | [ ] |
| 3 | Inviare un messaggio molto lungo (>500 caratteri). | L'app non crasha, risposta coerente. | [ ] |
| 4 | Disattivare Internet (Modalità Aereo) e inviare messaggio. | Messaggio di errore gentile ("Controlla la connessione"). No crash. | [ ] |

## 🧪 Scenario 3: Persistenza & Memoria
*Obiettivo: Verificare che la chat non venga persa.*

| # | Azione | Risultato Atteso | Status |
|---|---|---|---|
| 1 | Chiudere completamente l'app (kill dal task manager). | App chiusa. | [ ] |
| 2 | Riaprire l'app (Login automatico o manuale). | Chat precedente caricata correttamente. | [ ] |
| 3 | Scorrere verso l'alto. | Messaggi vecchi visibili. | [ ] |

## 🧪 Scenario 4: Profilo & Link Esterni
*Obiettivo: Verificare le impostazioni e i requisiti legali.*

| # | Azione | Risultato Atteso | Status |
|---|---|---|---|
| 1 | Andare nella schermata Profilo (icona in alto a destra). | Dati utente corretti visualizzati. | [ ] |
| 2 | Cliccare su "Privacy Policy". | Apertura browser esterno sulla pagina corretta. | [ ] |
| 3 | Cliccare su "Supporta il progetto". | Apertura link donazione (se configurato). | [ ] |
| 4 | Logout. | Ritorno alla schermata di Login. | [ ] |

## 🧪 Scenario 5: Monetizzazione (Utenti Free)
*Obiettivo: Verificare che gli annunci appaiano ma non rompano la UI.*

| # | Azione | Risultato Atteso | Status |
|---|---|---|---|
| 1 | Entrare in chat come utente NON premium. | Banner Ad visibile in basso (o in alto). | [ ] |
| 2 | Interagire con la tastiera (apri/chiudi). | Il banner non copre l'input text o il bottone invio. | [ ] |

---
**Note del Tester:**
*(Spazio per annotare bug o comportamenti strani)*
