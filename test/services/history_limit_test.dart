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

  test('getChatHistoryForAI enforces limit of 50 messages to prevent DoS/DoW and avoid memory exhaustion', () async {
    final messagesRef = db.collection('users').doc(user.uid).collection('messages');

    // Add 60 messages
    for (int i = 0; i < 60; i++) {
      await messagesRef.add({
        'text': 'Message $i',
        'isUser': true,
        'createdAt': DateTime.now().subtract(Duration(minutes: 60 - i)), // Oldest first
      });
    }

    // Get the history
    final history = await service.getChatHistoryForAI(true);

    // Verify limit is correctly enforced
    expect(history.length, 50, reason: "limit(50) should be applied to prevent unbounded history loading");

    // Verify the list contains the 50 most recent messages, ordered chronologically.
    // Due to the order, the oldest of the 50 most recent messages should be "Message 10" and newest "Message 59"
    expect(history.first['content'], 'Message 10');
    expect(history.last['content'], 'Message 59');
  });
}
