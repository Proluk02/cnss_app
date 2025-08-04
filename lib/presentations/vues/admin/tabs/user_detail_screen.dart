// lib/presentations/vues/admin/tabs/user_detail_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/modeles/utilisateur_modele.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserDetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot userDoc;
  const UserDetailScreen({super.key, required this.userDoc});

  @override
  Widget build(BuildContext context) {
    final user = UtilisateurModele.fromMap(
      userDoc.data() as Map<String, dynamic>,
    );

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(user.nom),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kAppBarGradient),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: kPrimaryColor.withOpacity(0.1),
              child: Text(
                user.nom.isNotEmpty == true ? user.nom[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 40, color: kPrimaryColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(user.nom, style: kTitleStyle.copyWith(fontSize: 24)),
          ),
          Center(
            child: Text(
              user.email,
              style: kSubtitleStyle.copyWith(color: kGreyText),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kCardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    icon: Icons.shield_outlined,
                    label: "Rôle",
                    value: user.role,
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.confirmation_number_outlined,
                    label: "Numéro d'Affiliation",
                    value:
                        user.numAffiliation?.isEmpty ?? true
                            ? 'Non renseigné'
                            : user.numAffiliation!,
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.fingerprint,
                    label: "UID (Identifiant unique)",
                    value: user.uid,
                    isCopiable: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isCopiable = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryColor.withOpacity(0.8)),
      title: Text(label, style: kLabelStyle),
      subtitle: Text(
        value,
        style: kSubtitleStyle.copyWith(color: kDarkText, fontSize: 16),
      ),
      trailing:
          isCopiable
              ? IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("UID copié dans le presse-papiers"),
                    ),
                  );
                },
              )
              : null,
    );
  }
}
