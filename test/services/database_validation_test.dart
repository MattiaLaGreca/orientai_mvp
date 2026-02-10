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

    // Sign in the user effectively
    await auth.signInWithEmailAndPassword(email: 'test@example.com', password: 'password');
  });

  test('sendMessage throws OrientAIDataException when message > 2000 chars and isUser is true', () async {
    final longMessage = 'a' * 2001;

    expect(
      () => service.sendMessage(longMessage, true),
      throwsA(isA<OrientAIDataException>()),
    );
  });

  test('sendMessage sanitizes input using Validators.cleanMessage', () async {
    const dirtyMessage = 'Hello\x00World'; // Contains null char

    await service.sendMessage(dirtyMessage, true);

    final snapshot = await db.collection('users').doc(user.uid).collection('messages').get();
    expect(snapshot.docs.length, 1);
    expect(snapshot.docs.first['text'], 'HelloWorld'); // Null char removed
  });

  test('sendMessage allows long messages if isUser is false (AI response)', () async {
    final longMessage = 'a' * 2500;

    await service.sendMessage(longMessage, false);

    final snapshot = await db.collection('users').doc(user.uid).collection('messages').get();
    expect(snapshot.docs.length, 1);
    expect(snapshot.docs.first['text'], longMessage);
  });
}
