// lib/presentations/vues/authentification/connexion.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/formulaires/formulaire_inscription.dart';
import 'package:cnss_app/presentations/viewmodels/auth_viewmodel.dart';
import 'package:cnss_app/presentations/vues/authentification/mot_de_passe_oublie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    // Si le formulaire n'est pas valide, on ne fait rien.
    if (!_formKey.currentState!.validate()) return;

    // On récupère le ViewModel via context.read() car on est dans une fonction.
    final authVM = context.read<AuthViewModel>();

    // On lance l'opération de connexion.
    authVM
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        )
        .catchError((error) {
          // Si le ViewModel renvoie une erreur (ex: mot de passe incorrect), on l'affiche.
          // On vérifie si le widget est toujours "monté" avant d'afficher le SnackBar.
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        });
    // PLUS DE setState, PLUS DE GESTION DE isLoading, PLUS DE NAVIGATION MANUELLE.
    // Tout est géré par le ViewModel et le SessionWrapper.
  }

  // Le reste de votre UI (build, buildField) peut rester quasiment identique.
  // La seule différence est qu'on lira `isLoading` depuis le ViewModel.

  Widget buildField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator:
          (value) =>
              value == null || value.trim().isEmpty ? 'Champ requis' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          label == "Email" ? Icons.email : Icons.lock,
          color: kPrimaryColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kInputRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // On observe le ViewModel pour savoir si une opération est en cours.
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: const BoxDecoration(
              gradient: kAppBarGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          // ... (Le reste de votre UI pour le logo et le bouton retour reste identique)
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.25,
              left: kDefaultPadding,
              right: kDefaultPadding,
              bottom: kDefaultPadding,
            ),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kCardRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "CONNEXION",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kDarkText,
                        ),
                      ),
                      const SizedBox(height: 30),
                      buildField(controller: _emailController, label: "Email"),
                      const SizedBox(height: 20),
                      buildField(
                        controller: _passwordController,
                        label: "Mot de passe",
                        obscure: true,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MotDePasseOubliePage(),
                                ),
                              ),
                          child: const Text("Mot de passe oublié ?"),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              authVM.isLoading
                                  ? null
                                  : _login, // Le bouton est désactivé si isLoading est true
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                kButtonRadius,
                              ),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: kAppBarGradient,
                              borderRadius: BorderRadius.circular(
                                kButtonRadius,
                              ),
                            ),
                            child: Center(
                              child:
                                  authVM.isLoading
                                      ? const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white,
                                        ),
                                      )
                                      : const Text(
                                        "Se connecter",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FormulaireInscription(),
                              ),
                            ),
                        child: const Text("Créer un compte"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
