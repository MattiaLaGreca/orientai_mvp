import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orientai/services/database_service.dart';
import 'package:orientai/utils/custom_exceptions.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockDb;
  late DatabaseService databaseService;

  setUpAll(() {
    registerFallbackValue(SetOptions(merge: true));
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockDb = MockFirebaseFirestore();
    databaseService = DatabaseService(auth: mockAuth, db: mockDb);
  });

  group('DatabaseService Tests', () {
    test('currentUser returns user from FirebaseAuth', () {
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      expect(databaseService.currentUser, mockUser);
    });

    test('signOut calls signOut on FirebaseAuth', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await databaseService.signOut();

      verify(() => mockAuth.signOut()).called(1);
    });

    test('signUp returns user on success', () async {
      final mockCredential = MockUserCredential();
      final mockUser = MockUser();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('123');
      when(() => mockAuth.createUserWithEmailAndPassword(email: 'test@test.com', password: 'password'))
          .thenAnswer((_) async => mockCredential);

      // Mock Firestore interactions for _initUserData
      final mockCollection = MockCollectionReference();
      final mockDoc = MockDocumentReference();
      when(() => mockDb.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc('123')).thenReturn(mockDoc);
      // Use any() for arguments
      when(() => mockDoc.set(any(), any())).thenAnswer((_) async {});

      final user = await databaseService.signUp('test@test.com', 'password');
      expect(user, mockUser);
      verify(() => mockAuth.createUserWithEmailAndPassword(email: 'test@test.com', password: 'password')).called(1);
    });

    test('signUp throws OrientAIAuthException on email-already-in-use', () async {
       when(() => mockAuth.createUserWithEmailAndPassword(email: 'test@test.com', password: 'password'))
         .thenThrow(FirebaseAuthException(code: 'email-already-in-use', message: 'Exists'));

       expect(
         () async => await databaseService.signUp('test@test.com', 'password'),
         throwsA(isA<OrientAIAuthException>().having((e) => e.message, 'message', "Questa email è già registrata."))
       );
    });

    test('signIn throws OrientAIAuthException on user-not-found', () async {
       when(() => mockAuth.signInWithEmailAndPassword(email: 'test@test.com', password: 'password'))
         .thenThrow(FirebaseAuthException(code: 'user-not-found', message: 'Not found'));

       expect(
         () async => await databaseService.signIn('test@test.com', 'password'),
         throwsA(isA<OrientAIAuthException>().having((e) => e.message, 'message', "Email o password non corretti."))
       );
    });
  });
}
