// Écran mot de passe oublié
// PRESENTATION: mot_de_passe_oublie_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MotDePasseOubliePage extends StatefulWidget {
  const MotDePasseOubliePage({super.key});

  @override
  State<MotDePasseOubliePage> createState() => _MotDePasseOubliePageState();
}

class _MotDePasseOubliePageState extends State<MotDePasseOubliePage> {
  final emailController = TextEditingController();
  String? message;
  final _formKey = GlobalKey<FormState>();

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      setState(() {
        message = "Email de réinitialisation envoyé !";
      });
    } catch (e) {
      setState(() {
        message = "Erreur : ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mot de passe oublié")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Entrez votre adresse email pour recevoir un lien de réinitialisation.",
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Veuillez entrer votre email"
                            : null,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetPassword,
                child: const Text("Envoyer"),
              ),
              if (message != null) ...[
                const SizedBox(height: 20),
                Text(message!, style: const TextStyle(color: Colors.green)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
