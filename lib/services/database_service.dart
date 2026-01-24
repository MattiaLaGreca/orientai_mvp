import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  DatabaseService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Ottieni l'utente corrente
  User? get currentUser => _auth.currentUser;

  // Stream per ascoltare i cambiamenti di stato Auth
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- 1. AUTENTICAZIONE ---

  Future<User?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Quando creiamo un utente, impostiamo il default a FREE
      if (credential.user != null) {
        await _initUserData(credential.user!.uid);
      }
      return credential.user;
    } catch (e) {
      print("Errore Registrazione: $e");
      rethrow;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Errore Login: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- 2. GESTIONE PROFILO E PREMIUM ---

  // Inizializza i dati base per un nuovo utente
  Future<void> _initUserData(String uid) async {
    await _db.collection('users').doc(uid).set({
      'isPremium': false, // Di default è Free
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Salva o Aggiorna il Profilo Studente
  Future<void> saveUserProfile(String name, String school, String interests) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).set({
      'name': name,
      'school': school,
      'interests': interests,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // Usa merge per non sovrascrivere isPremium
  }

  // Recupera il Profilo completo (incluso isPremium)
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data();
  }

  // Metodo per fare l'upgrade a Premium (da chiamare dopo il pagamento riuscito)
  Future<void> setPremiumStatus(bool isPremium) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).update({
      'isPremium': isPremium,
    });
  }

  // --- 3. GESTIONE CHAT ---

  // Recupera il timestamp dell'ultima volta che l'app è stata aperta/aggiornata
  Future<DateTime?> getLastSessionStart() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    final ts = doc.data()?['lastSessionStart'] as Timestamp?;
    return ts?.toDate();
  }

  // Aggiorna il timestamp dell'ultima sessione ad ADESSO
  Future<void> updateSessionStart() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).set({
      'lastSessionStart': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> sendMessage(String text, bool isUser) async {
    final user = _auth.currentUser;
    if (user == null) return;
    // if (freeCounter == freeLimit) {
    //  throw Exception("Limite di messaggi gratuiti raggiunto.");
    // }
    // freeCounter++;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('messages')
        .add({
      'text': text,
      'isUser': isUser,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessagesStream(bool isPremium) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    Query query = _db
        .collection('users')
        .doc(user.uid)
        .collection('messages')
        .orderBy('createdAt', descending: true);

    if (!isPremium) {
      query.limit(10);
    }
    return query.snapshots();
  }

  Future<List<Map<String, dynamic>>> getChatHistoryForAI(bool isPremium) async {
    final user = _auth.currentUser;
    DateTime? since = await getLastSessionStart();

    if (user == null) return [];

    Query query = _db
        .collection('users')
        .doc(user.uid)
        .collection('messages')
        .orderBy('createdAt', descending: true); // Dal più recente

    if (since != null) {
      // Logica "Delta": Prendi tutto ciò che è stato scritto dopo l'ultima apertura
      query = query.where('createdAt', isGreaterThan: Timestamp.fromDate(since));
    }

    // NOTE: Rimosso il limite hard (e.g. .limit(50)) su richiesta esplicita.
    // Si recuperano TUTTI i messaggi dall'ultima sessione (identificati da 'since').
    // Questo garantisce che il summarizer veda tutto il contesto nuovo, ma espone a rischi di costi elevati
    // se l'utente genera centinaia di messaggi in una sola sessione.

    final snapshot = await query.get();
    
    await updateSessionStart(); // Aggiorna l'ultima sessione adesso
    
    // Li invertiamo per averli cronologici (Vecchio -> Nuovo) per l'AI
    return snapshot.docs.reversed.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'role': (data['isUser'] ?? false) ? 'user' : 'ai',
        'content': data['text'] ?? '',
      };
    }).toList();
  }
  
  Future<String> getSummary() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato");

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      return doc.data()?['chatSummary'] as String;
    } catch (e) {
      print("Errore nel recupero del sommario");
      return "";
    }
  }

  Future<void> saveSummary(String summary) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).set({
      'chatSummary': summary,
    }, SetOptions(merge: true));
  }

  Future<void> clearChat() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final batch = _db.batch();
    final snapshots = await _db.collection('users').doc(user.uid).collection('messages').get();
    
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}