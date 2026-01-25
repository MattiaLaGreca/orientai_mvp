# Manuale di Rilascio Tecnico (Android)

Questo documento guida lo sviluppatore attraverso i passaggi tecnici necessari per generare una build di produzione (Release) di OrientAI e pubblicarla sul Google Play Store.

## 1. Prerequisiti

Assicurarsi di avere:
*   **Flutter SDK** aggiornato e funzionante (`flutter doctor`).
*   **Java Development Kit (JDK)** installato (compatibile con la versione Gradle del progetto).
*   Accesso alla **Google Play Console** come sviluppatore.

## 2. Gestione Keystore (Firma Digitale)

Per pubblicare sul Play Store, l'app deve essere firmata digitalmente.

### 2.1 Generazione Keystore
Se non esiste ancora un file `.jks` per la release, generarlo con il comando (da terminale, nella root del progetto):

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -alias upload
```

> **ATTENZIONE:** Conservare questo file in un luogo sicuro. Se perso, non sarà possibile aggiornare l'app. **NON committarlo su Git.**

### 2.2 Configurazione `key.properties`
Creare il file `android/key.properties` (se non esiste) e inserire le credenziali:

```properties
storePassword=<password_scelta>
keyPassword=<password_scelta>
keyAlias=upload
storeFile=upload-keystore.jks
```

> **NOTA:** Verificare che `android/key.properties` sia elencato in `.gitignore`.

## 3. Versionamento (Versioning)

Prima di ogni build di rilascio, aggiornare il file `pubspec.yaml`.

```yaml
version: 1.0.0+1
```

*   **1.0.0** è il `versionName` (quello che vede l'utente).
*   **+1** è il `versionCode` (deve essere incrementato di +1 ad ogni upload sullo store, es. `+2`, `+3`...).

## 4. Generazione App Bundle (AAB)

Google Play richiede il formato `.aab` (Android App Bundle), non `.apk`.

Eseguire il comando:

```bash
flutter build appbundle --release --obfuscate --split-debug-info=./build/app/outputs/symbols
```

*   `--release`: Compila in modalità release (ottimizzata).
*   `--obfuscate`: Rende il codice difficile da decodificare (reverse engineering).
*   `--split-debug-info`: Separa i simboli di debug per rendere l'AAB più leggero e permettere di de-offuscare gli stack trace sulla Play Console.

### Output
Il file generato si troverà in:
`build/app/outputs/bundle/release/app-release.aab`

## 5. Test della Build Release

Prima di caricare, testare l'AAB o generare un APK release locale per verifica:

```bash
flutter build apk --release
flutter install
```

Verificare:
1.  Login funzionante.
2.  Annunci AdMob visibili (se configurati).
3.  Nessun crash all'avvio (segno di problemi con R8/ProGuard).

## 6. Caricamento su Google Play Console

1.  Accedere a [play.google.com/console](https://play.google.com/console).
2.  Selezionare l'app **OrientAI**.
3.  Andare su **Produzione** (o "Test interno" per beta).
4.  Cliccare su **Crea nuova release**.
5.  Caricare il file `app-release.aab`.
6.  Aggiungere le note di rilascio ("Cosa c'è di nuovo").
7.  Inviare per la revisione.
