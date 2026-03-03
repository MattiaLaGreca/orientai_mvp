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

  test('getChatHistoryForAI limits to 50 messages to prevent DoS', () async {
    final messagesRef = db.collection('users').doc(user.uid).collection('messages');

    // Add 100 messages
    for (int i = 0; i < 100; i++) {
      await messagesRef.add({
        'text': 'Message $i',
        'isUser': true,
        'createdAt': DateTime.now().subtract(Duration(minutes: i)),
      });
    }

    // Get the chat history
    final history = await service.getChatHistoryForAI(true); // isPremium true or false doesn't matter for this limit

    // EXPECTATION: Should be limited to 50
    expect(history.length, 50, reason: "limit(50) should be applied to prevent unbounded history loading");
  });
}
