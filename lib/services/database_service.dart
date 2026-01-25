import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/custom_exceptions.dart';
import '../utils/secure_logger.dart';

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
    } on FirebaseAuthException catch (e) {
      SecureLogger.log("SignUp Firebase Error", e);
      String msg = "Impossibile completare la registrazione.";
      if (e.code == 'email-already-in-use') msg = "Questa email è già registrata.";
      else if (e.code == 'weak-password') msg = "La password è troppo debole.";
      else if (e.code == 'invalid-email') msg = "L'email non è valida.";
      throw OrientAIAuthException(msg, code: e.code);
    } catch (e) {
      SecureLogger.log("SignUp Generic Error", e);
      throw OrientAIAuthException("Si è verificato un errore durante la registrazione. Riprova più tardi.");
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      SecureLogger.log("SignIn Firebase Error", e);
      String msg = "Impossibile accedere.";
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = "Email o password non corretti.";
      } else if (e.code == 'user-disabled') {
        msg = "L'account è stato disabilitato.";
      }
      throw OrientAIAuthException(msg, code: e.code);
    } catch (e) {
      SecureLogger.log("SignIn Generic Error", e);
      throw OrientAIAuthException("Si è verificato un errore di accesso. Riprova più tardi.");
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      SecureLogger.log("SignOut Error", e);
      // Non lanciamo eccezione qui, l'utente vuole solo uscire
    }
  }

  // --- 2. GESTIONE PROFILO E PREMIUM ---

  // Inizializza i dati base per un nuovo utente
  Future<void> _initUserData(String uid) async {
    try {
      await _db.collection('users').doc(uid).set({
        'isPremium': false, // Di default è Free
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      SecureLogger.log("InitUserData Error", e);
      throw OrientAIDataException("Errore nella creazione del profilo utente.");
    }
  }

  // Salva o Aggiorna il Profilo Studente
  Future<void> saveUserProfile(String name, String school, String interests) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db.collection('users').doc(user.uid).set({
        'name': name,
        'school': school,
        'interests': interests,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      SecureLogger.log("SaveUserProfile Error", e);
      throw OrientAIDataException("Impossibile salvare il profilo.");
    }
  }

  // Recupera il Profilo completo (incluso isPremium)
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      SecureLogger.log("GetUserProfile Error", e);
      throw OrientAIDataException("Errore nel recupero del profilo.");
    }
  }

  // Metodo per fare l'upgrade a Premium (da chiamare dopo il pagamento riuscito)
  Future<void> setPremiumStatus(bool isPremium) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db.collection('users').doc(user.uid).update({
        'isPremium': isPremium,
      });
    } catch (e) {
      SecureLogger.log("SetPremiumStatus Error", e);
      throw OrientAIDataException("Errore nell'aggiornamento dello status Premium.");
    }
  }

  // --- 3. GESTIONE CHAT ---

  // Recupera il timestamp dell'ultima volta che l'app è stata aperta/aggiornata
  Future<DateTime?> getLastSessionStart() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      final ts = doc.data()?['lastSessionStart'] as Timestamp?;
      return ts?.toDate();
    } catch (e) {
      SecureLogger.log("GetLastSessionStart Error", e);
      return null;
    }
  }

  // Aggiorna il timestamp dell'ultima sessione ad ADESSO
  Future<void> updateSessionStart() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _db.collection('users').doc(user.uid).set({
        'lastSessionStart': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      SecureLogger.log("UpdateSessionStart Error", e);
      // Non bloccante
    }
  }

  Future<void> sendMessage(String text, bool isUser) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('messages')
          .add({
        'text': text,
        'isUser': isUser,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      SecureLogger.log("SendMessage Error", e);
      throw OrientAIDataException("Impossibile inviare il messaggio.");
    }
  }

  Stream<QuerySnapshot> getMessagesStream(bool isPremium) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    try {
      Query query = _db
          .collection('users')
          .doc(user.uid)
          .collection('messages')
          .orderBy('createdAt', descending: true);

      if (!isPremium) {
        query.limit(10);
      }
      return query.snapshots();
    } catch (e) {
      SecureLogger.log("GetMessagesStream Error", e);
      return const Stream.empty();
    }
  }

  Future<List<Map<String, dynamic>>> getChatHistoryForAI(bool isPremium) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      DateTime? since = await getLastSessionStart();

      Query query = _db
          .collection('users')
          .doc(user.uid)
          .collection('messages')
          .orderBy('createdAt', descending: true);

      if (since != null) {
        query = query.where('createdAt', isGreaterThan: Timestamp.fromDate(since));
      }

      final snapshot = await query.get();

      await updateSessionStart();

      return snapshot.docs.reversed.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'role': (data['isUser'] ?? false) ? 'user' : 'ai',
          'content': data['text'] ?? '',
        };
      }).toList();
    } catch (e) {
      SecureLogger.log("GetChatHistoryForAI Error", e);
      // Invece di crashare, restituiamo una lista vuota così l'AI parte senza contesto ma funziona
      return [];
    }
  }
  
  Future<String> getSummary() async {
    final user = _auth.currentUser;
    if (user == null) throw OrientAIAuthException("Utente non autenticato");

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      return (doc.data()?['chatSummary'] as String?) ?? "";
    } catch (e) {
      SecureLogger.log("GetSummary Error", e);
      return "";
    }
  }

  Future<void> saveSummary(String summary) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db.collection('users').doc(user.uid).set({
        'chatSummary': summary,
      }, SetOptions(merge: true));
    } catch (e) {
      SecureLogger.log("SaveSummary Error", e);
      // Non bloccante
    }
  }

  Future<void> clearChat() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final collection = _db.collection('users').doc(user.uid).collection('messages');

    // Elimina a blocchi di 500 per rispettare i limiti di Firestore e ottimizzare la memoria
    while (true) {
      final snapshot = await collection.limit(500).get();
      if (snapshot.docs.isEmpty) break;

      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
