// Tableau de bord
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'accueil/employeur_dashboard.dart';
import 'accueil/chef_ses_dashboard.dart';
import 'accueil/prepose_dashboard.dart';
import 'accueil/decompteur_dashboard.dart';
import 'accueil/directeur_dashboard.dart';
import 'admin/gestion_utilisateurs.dart';

class TableauBord extends StatelessWidget {
  const TableauBord({super.key});

  Future<String?> _getUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc =
        await FirebaseFirestore.instance
            .collection('utilisateurs')
            .doc(uid)
            .get();
    return doc.data()?['role'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data;

        switch (role) {
          case 'employeur':
            return const EmployeurDashboard();
          case 'chefSES':
            return const ChefSESDashboard();
          case 'préposé':
            return const PreposeDashboard();
          case 'décompteur':
            return const DecompteurDashboard();
          case 'directeur':
            return const DirecteurDashboard();
          case 'administrateur':
            return const GestionUtilisateurs();
          default:
            return Scaffold(
              appBar: AppBar(title: const Text("Rôle inconnu")),
              body: const Center(
                child: Text("Aucun tableau de bord trouvé pour ce rôle."),
              ),
            );
        }
      },
    );
  }
}
