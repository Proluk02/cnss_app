// Écran de connexion
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../donnees/firebase_service.dart';
import '../../formulaires/formulaire_inscription.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  void _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await FirebaseService().login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
            ),
            const SizedBox(height: 16),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              child:
                  isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Se connecter'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FormulaireInscription(),
                  ),
                );
              },
              child: const Text("Créer un compte"),
            ),
          ],
        ),
      ),
    );
  }
}
