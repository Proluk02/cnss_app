import 'package:flutter/material.dart';

class DirecteurDashboard extends StatelessWidget {
  const DirecteurDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord Directeur')),
      body: const Center(child: Text('Bienvenue, Directeur 🧑‍💼')),
    );
  }
}
