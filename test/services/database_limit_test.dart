import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:orientai/services/database_service.dart';

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

    // Sign in the user effectively
    await auth.signInWithEmailAndPassword(email: 'test@example.com', password: 'password');
  });

  test('getMessagesStream limits to 10 messages for non-premium users', () async {
    final messagesRef = db.collection('users').doc(user.uid).collection('messages');

    // Add 15 messages
    for (int i = 0; i < 15; i++) {
      await messagesRef.add({
        'text': 'Message $i',
        'isUser': true,
        'createdAt': DateTime.now().add(Duration(minutes: i)),
      });
    }

    // Get the stream for non-premium user
    final stream = service.getMessagesStream(false);

    // Listen for the first snapshot
    final snapshot = await stream.first;

    // EXPECTATION: Should be 10.
    // ACTUAL (Bug): Should be 15 because limit() is ignored.

    // We assert 10 to CONFIRM the bug is fixed.
    expect(snapshot.docs.length, 10, reason: "limit(10) should be applied");
  });
}
