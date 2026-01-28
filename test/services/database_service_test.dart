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

  test('clearChat handles empty collection', () async {
    await service.clearChat();
    final snapshot = await db.collection('users').doc(user.uid).collection('messages').get();
    expect(snapshot.docs.length, 0);
  });

  test('clearChat handles more than 500 messages (505)', () async {
    final messagesRef = db.collection('users').doc(user.uid).collection('messages');
    for (int i = 0; i < 505; i++) {
      await messagesRef.add({
        'text': 'Message $i',
        'isUser': true,
        'createdAt': DateTime.now(),
      });
    }

    final snapshotBefore = await messagesRef.get();
    expect(snapshotBefore.docs.length, 505);

    await service.clearChat();

    final snapshotAfter = await messagesRef.get();
    expect(snapshotAfter.docs.length, 0, reason: "All messages should be deleted");
  });

  test('clearChat handles large datasets (1200 messages)', () async {
    final messagesRef = db.collection('users').doc(user.uid).collection('messages');
    // Batch writes for faster setup (fake firestore allows this, usually)
    // Actually, to be safe and fast, let's just use Future.wait in chunks
    var futures = <Future>[];
    for (int i = 0; i < 1200; i++) {
      futures.add(messagesRef.add({
        'text': 'Message $i',
        'isUser': true,
        'createdAt': DateTime.now(),
      }));
      // throttle slightly to avoid completely locking event loop if needed, but for 1200 simple writes it should be ok
    }
    await Future.wait(futures);

    final snapshotBefore = await messagesRef.get();
    expect(snapshotBefore.docs.length, 1200);

    await service.clearChat();

    final snapshotAfter = await messagesRef.get();
    expect(snapshotAfter.docs.length, 0, reason: "All 1200 messages should be deleted");
  });

  test('getChatHistoryForAI retrieves messages and updates session start', () async {
    final messagesRef = db.collection('users').doc(user.uid).collection('messages');

    // Add some messages
    await messagesRef.add({
      'text': 'Hello AI',
      'isUser': true,
      'createdAt': DateTime.now().subtract(const Duration(minutes: 5)),
    });

    await messagesRef.add({
      'text': 'Hello User',
      'isUser': false,
      'createdAt': DateTime.now().subtract(const Duration(minutes: 4)),
    });

    // Verify initial state of lastSessionStart
    final userDocBefore = await db.collection('users').doc(user.uid).get();
    expect(userDocBefore.data()?['lastSessionStart'], isNull);

    // Call getChatHistoryForAI
    final history = await service.getChatHistoryForAI(false);

    // Verify history
    // Query is descending (Newest first): [Hello User, Hello AI]
    // Code reverses it: [Hello AI, Hello User]
    expect(history.length, 2);
    expect(history[0]['role'], 'user');
    expect(history[0]['content'], 'Hello AI');
    expect(history[1]['role'], 'ai');
    expect(history[1]['content'], 'Hello User');

    // Verify lastSessionStart is updated
    // Even though it is unawaited in the service, FakeFirebaseFirestore executes immediately.
    final userDocAfter = await db.collection('users').doc(user.uid).get();
    expect(userDocAfter.data()?['lastSessionStart'], isNotNull);
  });
}
