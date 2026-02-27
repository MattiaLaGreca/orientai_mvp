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

  test('getChatHistoryForAI limits history to 50 most recent messages', () async {
    final messagesRef = db.collection('users').doc(user.uid).collection('messages');

    // Add 60 messages: Message 0 (oldest) to Message 59 (newest)
    // To ensure correct sorting by 'createdAt' descending, we need distinct timestamps.
    // 'Message 0' is the oldest (60 minutes ago).
    // 'Message 59' is the newest (1 minute ago).
    var futures = <Future>[];
    for (int i = 0; i < 60; i++) {
      futures.add(messagesRef.add({
        'text': 'Message $i',
        'isUser': i % 2 == 0,
        'createdAt': DateTime.now().subtract(Duration(minutes: 60 - i)),
      }));
    }
    await Future.wait(futures);

    // Initial check: 60 messages exist
    final snapshot = await messagesRef.get();
    expect(snapshot.docs.length, 60);

    // Call getChatHistoryForAI
    final history = await service.getChatHistoryForAI(false);

    // EXPECTATION 1: Should be 50.
    expect(history.length, 50, reason: "Should limit chat history to 50 items");

    // EXPECTATION 2: Should be the MOST RECENT 50 messages.
    // The query orders by createdAt DESC (Newest First) and limits to 50.
    // So it fetches Message 59, 58, ..., 10.
    // Then `getChatHistoryForAI` reverses the list before returning.
    // So the returned list should be: [Message 10, Message 11, ..., Message 59]

    expect(history.first['content'], 'Message 10', reason: "First message in history should be the 50th most recent (oldest of the batch)");
    expect(history.last['content'], 'Message 59', reason: "Last message in history should be the most recent");
  });
}
