// presentations/vues/dashboard/dashboard_home.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Utiliser Consumer pour écouter les changements du DeclarationViewModel
    return Consumer<DeclarationViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.erreurMessage != null) {
          return Center(child: Text("Erreur: ${viewModel.erreurMessage}"));
        }

        // Calcul des totaux à partir des lignes de brouillon actuelles
        final rapport = viewModel.peutDeclarer ? viewModel.lignesBrouillon : [];
        final totalBrut = rapport.fold(
          0.0,
          (sum, item) => sum + item.salaireBrut,
        );
        final totalCotisations =
            (totalBrut * 0.10) + (totalBrut * 0.015) + (totalBrut * 0.065);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Déclaration pour: ${viewModel.periodeAffichee}",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _StatCard(
                    title: 'Total Brut Déclaré',
                    value: '${totalBrut.toStringAsFixed(0)} FC',
                    icon: Icons.monetization_on_outlined,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 16),
                  _StatCard(
                    title: 'Total des Cotisations',
                    value: '${totalCotisations.toStringAsFixed(0)} FC',
                    icon: Icons.receipt_long_outlined,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatCard(
                    title: 'Employés Déclarés',
                    value: '${rapport.length}',
                    icon: Icons.people_outline,
                    color: Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
