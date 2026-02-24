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

  group('DatabaseService Input Validation', () {
    test('sendMessage sanitizes input (removes control characters)', () async {
      // 1. Send message with invisible control characters (0x00-0x1F excluding \n, \t)
      // Example: "Hello\x00World" should become "HelloWorld"
      const maliciousInput = "Hello\x00World\x1F";
      const expectedCleaned = "HelloWorld";

      await service.sendMessage(maliciousInput, true);

      // Verify what was stored
      final snapshot = await db.collection('users').doc(user.uid).collection('messages').get();
      expect(snapshot.docs.length, 1);
      final storedText = snapshot.docs.first.data()['text'] as String;

      expect(storedText, expectedCleaned, reason: "Control characters should be removed");
    });

    test('sendMessage rejects messages > 2000 chars', () async {
      // Create a string of 2001 'a's
      final longMessage = 'a' * 2001;

      try {
        await service.sendMessage(longMessage, true);
        fail("Should have thrown OrientAIDataException for message > 2000 chars");
      } on OrientAIDataException catch (e) {
        expect(e.message, contains("troppo lungo"), reason: "Error message should mention length");
      }
    });

    test('sendMessage rejects empty messages (after trim)', () async {
      const emptyMessage = "   "; // whitespace only

      try {
        await service.sendMessage(emptyMessage, true);
        fail("Should have thrown OrientAIDataException for empty message");
      } on OrientAIDataException catch (e) {
        // We expect some error message about empty input
        expect(e.message, isNotEmpty);
      } catch (e) {
        // If it throws generic exception, catch it?
      }

      // Also verify nothing was stored
      final snapshot = await db.collection('users').doc(user.uid).collection('messages').get();
      expect(snapshot.docs.isEmpty, true, reason: "Empty message should not be stored");
    });
  });
}
