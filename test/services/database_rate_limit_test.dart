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

  test('sendMessage throws exception if user sends messages too quickly', () async {
    // 1. Send first message
    await service.sendMessage('First message', true);

    // 2. Try to send second message immediately
    try {
      await service.sendMessage('Second message', true);
      fail("Should have thrown OrientAIDataException");
    } on OrientAIDataException catch (e) {
      expect(e.message, contains("Stai inviando messaggi troppo velocemente"));
    }
  });

  test('sendMessage allows messages after delay', () async {
    // 1. Send first message
    await service.sendMessage('First message', true);

    // 2. Wait for 600ms (limit is 500ms)
    await Future.delayed(const Duration(milliseconds: 600));

    // 3. Send second message
    await service.sendMessage('Second message', true);

    // Assert both messages are in DB
    final snapshot = await db.collection('users').doc(user.uid).collection('messages').get();
    expect(snapshot.docs.length, 2);
  });

  test('sendMessage does NOT limit AI messages', () async {
    // 1. Send AI message
    await service.sendMessage('AI message 1', false);

    // 2. Send AI message immediately
    await service.sendMessage('AI message 2', false);

    // Assert both messages are in DB
    final snapshot = await db.collection('users').doc(user.uid).collection('messages').get();
    expect(snapshot.docs.length, 2);
  });
}
