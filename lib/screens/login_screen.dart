import 'package:flutter/material.dart';
import '../services/database_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  
  bool _isLogin = true; // True = Login, False = Registrazione
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await _dbService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await _dbService.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
      // Se va tutto bene, il main.dart rileverà il cambio di stato e cambierà schermata
    } catch (e) {
      setState(() {
        // Messaggio di errore semplificato per l'utente
        _errorMessage = e.toString().contains('email-already-in-use') 
            ? "Email già registrata." 
            : e.toString().contains('wrong-password')
                ? "Password sbagliata."
                : "Errore: controlla i dati e riprova.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.school, size: 80, color: Colors.indigo),
              const SizedBox(height: 16),
              Text(
                _isLogin ? "Bentornato!" : "Crea Account",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 32),
              
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(8)),
                  child: Text(_errorMessage!, style: TextStyle(color: Colors.red[900])),
                ),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    tooltip: _obscurePassword ? "Mostra password" : "Nascondi password",
                  ),
                ),
                obscureText: _obscurePassword,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isLogin ? "Accedi" : "Registrati", style: const TextStyle(fontSize: 16)),
              ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin 
                  ? "Non hai un account? Registrati" 
                  : "Hai già un account? Accedi"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}