import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orientai/services/database_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockDb;
  late DatabaseService databaseService;

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
  });
}
