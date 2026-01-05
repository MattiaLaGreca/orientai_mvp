import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _interestsController;
  late String _selectedSchool;
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;

  final List<String> _schools = [
    'Liceo Scientifico',
    'Liceo Classico',
    'Liceo Linguistico',
    'Istituto Tecnico',
    'Istituto Professionale',
    'Altro'
  ];

  @override
  void initState() {
    super.initState();
    // Inizializza i controller con i dati esistenti
    _nameController = TextEditingController(text: widget.userData['name'] ?? '');
    _interestsController = TextEditingController(text: widget.userData['interests'] ?? '');
    _selectedSchool = widget.userData['school'] ?? _schools.first;
    
    // Assicuriamoci che la scuola salvata sia nella lista, altrimenti default
    if (!_schools.contains(_selectedSchool)) {
      _selectedSchool = _schools.first;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _dbService.saveUserProfile(
        _nameController.text.trim(),
        _selectedSchool,
        _interestsController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profilo aggiornato con successo!')),
        );
        Navigator.pop(context); // Torna alla chat
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _clearChatHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancellare Chat?"),
        content: const Text("Tutti i messaggi verranno eliminati definitivamente. L'AI dimenticherà quello di cui avete parlato finora."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annulla")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text("Cancella", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await _dbService.clearChat();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cronologia chat cancellata.')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    await _dbService.signOut();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Il tuo Profilo"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Modifica Dati",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 20),
                  
                  // Nome
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nome",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) => v!.isEmpty ? "Inserisci il nome" : null,
                  ),
                  const SizedBox(height: 16),

                  // Scuola
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSchool,
                    decoration: const InputDecoration(
                      labelText: "Scuola Attuale",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: _schools.map((String school) {
                      return DropdownMenuItem(value: school, child: Text(school));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedSchool = val!),
                  ),
                  const SizedBox(height: 16),

                  // Interessi
                  TextFormField(
                    controller: _interestsController,
                    decoration: const InputDecoration(
                      labelText: "Interessi e Passioni",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.favorite),
                    ),
                    maxLines: 2,
                    validator: (v) => v!.isEmpty ? "Inserisci i tuoi interessi" : null,
                  ),
                  const SizedBox(height: 24),

                  // Tasto Salva
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Salva Modifiche"),
                  ),

                  const Divider(height: 40, thickness: 1),

                  const Text(
                    "Gestione Account",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 16),

                  // Tasto Cancella Chat
                  OutlinedButton.icon(
                    onPressed: _clearChatHistory,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text("Cancella Cronologia Chat", style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  
                  const SizedBox(height: 12),

                  // Tasto Logout
                  TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Esci dall'account"),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}