// lib/presentations/vues/accueil/prepose_tabs/prepose_home_tab.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/prepose_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreposeHomeTab extends StatelessWidget {
  const PreposeHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PreposeViewModel>();
    final userName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Préposé';

    return RefreshIndicator(
      onRefresh: () => viewModel.chargerTousLesEmployeurs(),
      child: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text("Bonjour,", style: kSubtitleStyle.copyWith(color: kGreyText)),
          Text(userName,
              style: kTitleStyle.copyWith(fontSize: 28, color: kDarkText)),
          const SizedBox(height: 24),
          Text("Aperçu des Données", style: kTitleStyle.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _StatCard(
                title: "Employeurs Gérés",
                value: viewModel.isLoading
                    ? "..."
                    : viewModel.tousLesEmployeurs.length.toString(),
                icon: Icons.business_center_outlined,
                color: kPrimaryColor,
              ),
              _StatCard(
                title: "Fiches Générées",
                value: "0", // TODO: A implémenter
                icon: Icons.picture_as_pdf_outlined,
                color: kAccentColor,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kGreyText)),
          ],
        ),
      ),
    );
  }
}
