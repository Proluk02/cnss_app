import 'package:flutter/material.dart';

class DecompteurDashboard extends StatelessWidget {
  const DecompteurDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord Décompteur')),
      body: const Center(child: Text('Bienvenue, Décompteur 🧾')),
    );
  }
}
