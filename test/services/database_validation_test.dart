import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:orientai/services/database_service.dart';
import 'package:orientai/utils/custom_exceptions.dart';

void main() {
  late FakeFirebaseFirestore db;
  late MockFirebaseAuth auth;
  late DatabaseService service;
  late MockUser user;

  setUp(() async {
    db = FakeFirebaseFirestore();
    user = MockUser(uid: 'test_user_uid', email: 'test@example.com');
    auth = MockFirebaseAuth(mockUser: user);
    service = DatabaseService(db: db, auth: auth);

    // Sign in the user
    await auth.signInWithEmailAndPassword(email: 'test@example.com', password: 'password');
  });

  test('sendMessage throws OrientAIDataException if message is too long (> 2000 chars)', () async {
    // Generate a string of 2001 characters
    final longMessage = 'a' * 2001;

    try {
      await service.sendMessage(longMessage, true);
      fail("Should have thrown OrientAIDataException");
    } on OrientAIDataException catch (e) {
      expect(e.message, contains("Messaggio troppo lungo"));
    }
  });

  test('sendMessage sanitizes control characters from input', () async {
    // Input with control characters (e.g., \x00)
    // Note: \n, \t, \r are allowed by Validators.cleanMessage.
    // We use \x00 which should be removed.
    const dirtyMessage = 'Hello\x00World';
    const cleanMessage = 'HelloWorld';

    await service.sendMessage(dirtyMessage, true);

    final snapshot = await db.collection('users').doc(user.uid).collection('messages').get();
    expect(snapshot.docs.length, 1);
    final data = snapshot.docs.first.data();
    expect(data['text'], cleanMessage);
  });

  test('sendMessage throws OrientAIDataException if message is empty after sanitization', () async {
      // Input with only control characters
      const dirtyMessage = '\x00\x01\x02';

      try {
        await service.sendMessage(dirtyMessage, true);
        fail("Should have thrown OrientAIDataException for empty message");
      } on OrientAIDataException catch (e) {
        // We accept "Messaggio vuoto" or similar
        expect(e.message?.toLowerCase(), contains("messaggio"));
      }
    });
}
