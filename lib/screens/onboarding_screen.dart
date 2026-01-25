import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'chat_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _interestsController = TextEditingController();
  String _selectedSchool = 'Liceo Scientifico';
  
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;
  String? _nameError;

  final List<String> _schools = [
    'Liceo Scientifico',
    'Liceo Classico',
    'Liceo Linguistico',
    'Istituto Tecnico',
    'Istituto Professionale',
    'Altro'
  ];

  void _saveAndStart() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = "Inserisci il tuo nome";
      });
      return;
    }

    setState(() => _isLoading = true);

    // Salviamo il profilo collegandolo all'utente email corrente
    await _dbService.saveUserProfile(
      _nameController.text,
      _selectedSchool,
      _interestsController.text,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            studentName: _nameController.text,
            interests: _interestsController.text,
            schoolType: _selectedSchool,
            isPremium: false,
          ),
        ),
      );
    }
  }
  

  void _logout() async {
    await _dbService.signOut();
    // Il main.dart riporterà l'utente al Login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout, color: Colors.white))
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: AutofillGroup(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Raccontaci di te 🚀",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        decoration: InputDecoration(
                          labelText: "Come ti chiami?",
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person),
                          errorText: _nameError,
                        ),
                        onChanged: (value) {
                          if (_nameError != null) {
                            setState(() {
                              _nameError = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: _selectedSchool,
                        decoration: const InputDecoration(
                          labelText: "Che scuola fai?",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school),
                        ),
                        items: _schools.map((String school) {
                          return DropdownMenuItem(value: school, child: Text(school));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedSchool = val!),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _interestsController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _saveAndStart(),
                        decoration: const InputDecoration(
                          labelText: "Interessi? (Es. Videogiochi, Arte)",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.favorite),
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveAndStart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Salva Profilo"),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _logout,
                        child: const Text("Non sei tu? Esci", style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
