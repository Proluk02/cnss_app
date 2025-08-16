// lib/presentations/vues/dashboard/settings_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:cnss_app/presentations/viewmodels/auth_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _sigleController = TextEditingController();
  final _affiliationController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  final _centreGestionController = TextEditingController();

  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Pré-remplir les champs avec les données de l'utilisateur
    _nomController.text = currentUser?.displayName ?? '';
    final data =
        await FirebaseService().getDonneesUtilisateur(currentUser!.uid);
    if (mounted && data != null) {
      setState(() {
        _sigleController.text = data['sigle'] ?? '';
        _affiliationController.text = data['numAffiliation'] ?? '';
        _telephoneController.text = data['telephone'] ?? '';
        _adresseController.text = data['adresse'] ?? '';
        _centreGestionController.text = data['centreGestion'] ?? 'Kamina';
        _isLoadingData = false;
      });
    } else if (mounted) {
      setState(() => _isLoadingData = false);
    }
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
              content: Text("Profil mis à jour !"),
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

  Future<void> _changePassword() async {
    try {
      await FirebaseService().changePassword(currentUser!.email!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Un email de réinitialisation a été envoyé."),
            backgroundColor: kSuccessColor));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Erreur : $e"), backgroundColor: kErrorColor));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Profil & Paramètres"),
        flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: kAppBarGradient)),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(kDefaultPadding),
              children: [
                _buildSection(
                  title: "Informations sur l'Entreprise",
                  icon: Icons.business_center_outlined,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
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
                            enabled: false),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: authVM.isLoading ? null : _saveProfile,
                            icon: authVM.isLoading
                                ? const SizedBox.shrink()
                                : const Icon(Icons.save_outlined),
                            label: authVM.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Text("Enregistrer les modifications"),
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: "Sécurité",
                  icon: Icons.security_outlined,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(kCardRadius)),
                    child: ListTile(
                      leading: const Icon(Icons.lock_reset_outlined),
                      title: const Text("Changer le mot de passe"),
                      subtitle:
                          const Text("Un lien vous sera envoyé par email."),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _changePassword,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSection(
      {required String title, required IconData icon, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: kPrimaryColor),
            const SizedBox(width: 8),
            Text(title, style: kTitleStyle),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
