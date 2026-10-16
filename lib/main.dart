import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';

import 'services/database_service.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrientAI',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _dbService = DatabaseService();
  late final Stream<User?> _authStateStream;

  @override
  void initState() {
    super.initState();
    _authStateStream = _dbService.authStateChanges;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStateStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          return _ProfileWrapper(user: snapshot.data!);
        }

        return const LoginScreen();
      },
    );
  }
}

class _ProfileWrapper extends StatefulWidget {
  final User user;
  const _ProfileWrapper({required this.user});

  @override
  State<_ProfileWrapper> createState() => _ProfileWrapperState();
}

class _ProfileWrapperState extends State<_ProfileWrapper> {
  late final Stream<DocumentSnapshot> _profileStream;

  @override
  void initState() {
    super.initState();
    // ⚡ Bolt Optimization: Filter stream updates to only rebuild when critical
    // profile fields change, preventing full app rebuilds on every chat message.
    _profileStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .snapshots()
        .distinct((prev, curr) {
      final p = prev.data() ?? {};
      final c = curr.data() ?? {};
      return p['name'] == c['name'] &&
          p['interests'] == c['interests'] &&
          p['school'] == c['school'] &&
          p['isPremium'] == c['isPremium'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _profileStream,
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (profileSnapshot.hasData && profileSnapshot.data!.exists) {
          final data = profileSnapshot.data!.data() as Map<String, dynamic>;

          if (data.containsKey('name') &&
              data['name'] != null &&
              data['name'].toString().isNotEmpty) {
            bool isPremium = data['isPremium'] ?? false;

            return ChatScreen(
              studentName: data['name'],
              interests: data['interests'] ?? '',
              schoolType: data['school'] ?? '',
              isPremium: isPremium,
            );
          }
        }

        return const OnboardingScreen();
      },
    );
  }
}
