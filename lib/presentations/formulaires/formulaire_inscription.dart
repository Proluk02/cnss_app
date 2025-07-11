// Formulaire d'inscription
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../donnees/firebase_service.dart';

class FormulaireInscription extends StatefulWidget {
  const FormulaireInscription({super.key});

  @override
  State<FormulaireInscription> createState() => _FormulaireInscriptionState();
}

class _FormulaireInscriptionState extends State<FormulaireInscription> {
  final nomController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  void _register() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await FirebaseService().register(
        nom: nomController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: "employeur", // rôle forcé par défaut
      );
      Navigator.pop(context); // retour à la page de connexion
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
      appBar: AppBar(title: const Text("Inscription")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomController,
              decoration: const InputDecoration(labelText: "Nom complet"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mot de passe"),
            ),
            const SizedBox(height: 16),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: isLoading ? null : _register,
              child:
                  isLoading
                      ? const CircularProgressIndicator()
                      : const Text("S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}
