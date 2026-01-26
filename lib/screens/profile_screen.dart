import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String _appVersion = '';

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
    _loadVersion();
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

  Future<void> _launchSupport() async {
    // TODO: Sostituisci questo link con il tuo URL reale (es. https://ko-fi.com/tuo_nome_utente)
    // Questo è un modo "zero-commission" per ricevere supporto diretto dagli utenti.
    final Uri url = Uri.parse('https://ko-fi.com');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossibile aprire il link.')),
        );
      }
    }
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _appVersion = info.version);
  }

  Future<void> _launchPrivacy() async {
    final Uri url = Uri.parse('https://orientai.app/privacy');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossibile aprire il link.')),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminare l'account?"),
        content: const Text("Questa azione è irreversibile. Perderai tutti i dati e la cronologia chat."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annulla")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("ELIMINA", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _dbService.deleteAccount();
        if (mounted) {
           Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
          setState(() => _isLoading = false);
        }
      }
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
                    "Sostieni il Progetto",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "OrientAI è un progetto indipendente. Se ti è stato utile, considera una piccola donazione per coprire i costi dei server.",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _launchSupport,
                    icon: const Icon(Icons.coffee),
                    label: const Text("Offrici un Caffè"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  const Divider(height: 40, thickness: 1),

                  const Text(
                    "Gestione Account",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 16),

                  // Tasto Privacy
                  TextButton.icon(
                    onPressed: _launchPrivacy,
                    icon: const Icon(Icons.privacy_tip_outlined),
                    label: const Text("Privacy Policy"),
                    style: TextButton.styleFrom(foregroundColor: Colors.indigo),
                  ),

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

                  const SizedBox(height: 12),

                   // Tasto Elimina Account
                  TextButton.icon(
                    onPressed: _deleteAccount,
                    icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    label: const Text("Elimina Account", style: TextStyle(color: Colors.red)),
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: Text(
                      "Versione $_appVersion",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}