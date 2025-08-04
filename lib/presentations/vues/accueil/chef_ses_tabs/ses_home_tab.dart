// TODO Implement this library.// lib/presentations/vues/accueil/chef_ses_tabs/ses_home_tab.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/chef_ses_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SesHomeTab extends StatelessWidget {
  const SesHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChefSesViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final pendingCount = viewModel.declarations.length;
        // TODO: Ajouter des compteurs pour les déclarations validées/rejetées du jour

        return ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            Text("Aperçu du Centre", style: kTitleStyle),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _StatCard(
                  title: "Déclarations en Attente",
                  value: pendingCount.toString(),
                  icon: Icons.hourglass_top,
                  color: kWarningColor,
                ),
                _StatCard(
                  title: "Validées Aujourd'hui",
                  value: "0",
                  icon: Icons.check_circle,
                  color: kSuccessColor,
                ),
              ],
            ),
          ],
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kGreyText),
            ),
          ],
        ),
      ),
    );
  }
}
