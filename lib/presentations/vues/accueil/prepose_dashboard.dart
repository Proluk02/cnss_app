import 'package:flutter/material.dart';

class PreposeDashboard extends StatelessWidget {
  const PreposeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord Préposé')),
      body: const Center(child: Text('Bienvenue, Préposé 📝')),
    );
  }
}
