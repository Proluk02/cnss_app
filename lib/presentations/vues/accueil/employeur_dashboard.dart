import 'package:flutter/material.dart';

class EmployeurDashboard extends StatelessWidget {
  const EmployeurDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord Employeur')),
      body: const Center(child: Text('Bienvenue, Employeur 👷')),
    );
  }
}
