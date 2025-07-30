// lib/presentations/vues/placeholder_dashboards.dart

import 'package:flutter/material.dart';

// --- Fichiers d'attente pour les rôles autres que l'employeur ---

class ChefSESDashboard extends StatelessWidget {
  const ChefSESDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tableau de Bord - Chef SES")),
      body: const Center(
        child: Text(
          "Interface pour le Chef de Centre de Gestion",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class PreposeDashboard extends StatelessWidget {
  const PreposeDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tableau de Bord - Préposé")),
      body: const Center(
        child: Text(
          "Interface pour le Préposé SES",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class DecompteurDashboard extends StatelessWidget {
  const DecompteurDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tableau de Bord - Décompteur")),
      body: const Center(
        child: Text(
          "Interface pour le Décompteur SES",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class DirecteurDashboard extends StatelessWidget {
  const DirecteurDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tableau de Bord - Directeur")),
      body: const Center(
        child: Text(
          "Interface pour le Directeur Provincial",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
