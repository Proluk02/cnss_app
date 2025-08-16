// lib/presentations/vues/accueil/complete_profile_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/auth_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _sigleController = TextEditingController();
  final _affiliationController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  final _centreGestionController =
      TextEditingController(text: 'Kamina'); // Valeur par défaut

  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nomController.text = currentUser?.displayName ?? '';
  }

  @override
  void dispose() {
    _nomController.dispose();
    _sigleController.dispose();
    _affiliationController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _centreGestionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authVM = context.read<AuthViewModel>();
      try {
        await authVM.updateUserProfile(
          nom: _nomController.text.trim(),
          sigle: _sigleController.text.trim(),
          numAffiliation: _affiliationController.text.trim(),
          telephone: _telephoneController.text.trim(),
          adresse: _adresseController.text.trim(),
          centreGestion: _centreGestionController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Profil complété avec succès !"),
              backgroundColor: kSuccessColor));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Erreur : $e"), backgroundColor: kErrorColor));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Finaliser votre Inscription"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kCardRadius)),
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Complétez le profil de votre entreprise",
                        style: kTitleStyle),
                    const SizedBox(height: 8),
                    const Text(
                        "Ces informations sont obligatoires et apparaîtront sur vos documents officiels.",
                        textAlign: TextAlign.center,
                        style: kLabelStyle),
                    const SizedBox(height: 24),
                    TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                            labelText: 'Dénomination / Raison Sociale'),
                        validator: (v) => v!.isEmpty ? 'Requis' : null),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _sigleController,
                        decoration: const InputDecoration(
                            labelText: 'Abréviation ou Sigle')),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _affiliationController,
                        decoration: const InputDecoration(
                            labelText: 'Numéro d\'Affiliation CNSS'),
                        validator: (v) => v!.isEmpty ? 'Requis' : null),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _telephoneController,
                        decoration: const InputDecoration(
                            labelText: 'Numéro de téléphone'),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Requis' : null),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _adresseController,
                        decoration: const InputDecoration(
                            labelText: 'Adresse physique'),
                        validator: (v) => v!.isEmpty ? 'Requis' : null),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _centreGestionController,
                        decoration: const InputDecoration(
                            labelText: 'Centre de Gestion'),
                        enabled: false), // Non modifiable par l'utilisateur
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authVM.isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: authVM.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text("Terminer et Continuer"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
