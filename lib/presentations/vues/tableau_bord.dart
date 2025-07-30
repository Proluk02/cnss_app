// lib/presentations/vues/tableau_bord.dart

import 'package:cnss_app/presentations/vues/accueil/chef_ses_dashboard.dart';
import 'package:cnss_app/presentations/vues/accueil/decompteur_dashboard.dart';
import 'package:cnss_app/presentations/vues/accueil/directeur_dashboard.dart';
import 'package:cnss_app/presentations/vues/accueil/employeur/employeur_dashboard.dart';
import 'package:cnss_app/presentations/vues/accueil/prepose_dashboard.dart';
import 'package:flutter/material.dart';

class TableauBord extends StatelessWidget {
  // Le constructeur accepte le `role` qui est passé par le SessionWrapper
  final String role;
  const TableauBord({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    // Ce widget agit comme un aiguilleur pour afficher le bon tableau de bord
    // en fonction du rôle de l'utilisateur connecté.
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

      default:
        // Un cas par défaut si le rôle n'est pas géré (sécurité)
        return Scaffold(
          appBar: AppBar(title: const Text("Erreur de Rôle")),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Rôle utilisateur non reconnu : $role. Veuillez contacter l'administrateur.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
    }
  }
}
