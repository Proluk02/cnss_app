import 'package:flutter/material.dart';

class ChefSESDashboard extends StatelessWidget {
  const ChefSESDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord Chef SES')),
      body: const Center(child: Text('Bienvenue, Chef de Section SES 📊')),
    );
  }
}
