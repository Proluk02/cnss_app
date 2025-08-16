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
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();

    authVM
        .login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    )
        .catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst("Exception: ", "")),
            backgroundColor: kErrorColor,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Champ requis' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
            label == "Email" ? Icons.email_outlined : Icons.lock_outline,
            color: kPrimaryColor),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kInputRadius)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height *
                0.35, // Un peu plus grand pour l'effet visuel
            decoration: const BoxDecoration(
              gradient: kAppBarGradient,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50)),
            ),
          ),

          // --- CORRECTION : LOGO RÉINTÉGRÉ ICI ---
          Positioned(
            top: MediaQuery.of(context).size.height *
                0.1, // Ajuster la position verticale
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5))
                  ],
                ),
                child: Image.asset('assets/images/logo_cnss.png', height: 80),
              ),
            ),
          ),
          // --- FIN DE LA CORRECTION ---

          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height *
                    0.3, // Démarrer le contenu plus bas
                left: kDefaultPadding,
                right: kDefaultPadding,
                bottom: kDefaultPadding,
              ),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kCardRadius)),
                child: Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        const Text("CONNEXION",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: kDarkText)),
                        const SizedBox(height: 30),
                        buildField(
                            controller: _emailController, label: "Email"),
                        const SizedBox(height: 20),
                        buildField(
                            controller: _passwordController,
                            label: "Mot de passe",
                            obscure: true),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const MotDePasseOubliePage())),
                            child: const Text("Mot de passe oublié ?"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: authVM.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(kButtonRadius)),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                  gradient: kAppBarGradient,
                                  borderRadius:
                                      BorderRadius.circular(kButtonRadius)),
                              child: Center(
                                child: authVM.isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.white)))
                                    : const Text("Se connecter",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Vous n'avez pas de compte ?"),
                            TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const FormulaireInscription())),
                              child: const Text("S'inscrire"),
                            ),
                          ],
                        ),
                      ],
                    ),
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
