import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../utils/custom_exceptions.dart';
import '../utils/validators.dart';

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

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 🔒 Sentinel Security Check: Input Validation
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Inserisci email e password.";
      });
      return;
    }

    // 🔒 Sentinel Security Check: Stricter Regex for Input Validation
    if (!Validators.emailRegex.hasMatch(email)) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Inserisci un'email valida.";
      });
      return;
    }

    if (!_isLogin && password.length < 6) {
      setState(() {
        _isLoading = false;
        _errorMessage = "La password deve avere almeno 6 caratteri.";
      });
      return;
    }

    try {
      if (_isLogin) {
        await _dbService.signIn(
          email,
          password,
        );
      } else {
        await _dbService.signUp(
          email,
          password,
        );
      }
      // Se va tutto bene, il main.dart rileverà il cambio di stato e cambierà schermata
    } on OrientAIAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Errore imprevisto. Riprova più tardi.";
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
          child: AutofillGroup(
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
                maxLength: 100, // 🔒 Sentinel: Prevent DoS
                decoration: const InputDecoration(
                  labelText: "Email",
                  counterText: "", // Enforce limit but hide visual counter
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                maxLength: 64, // 🔒 Sentinel: Prevent DoS
                decoration: InputDecoration(
                  labelText: "Password",
                  counterText: "",
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
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(),
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
        ), // AutofillGroup
      ),
      ),
    );
  }
}