// lib/presentations/vues/accueil/chef_ses_tabs/ses_home_tab.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/chef_ses_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ses_employers_list_screen.dart';
import 'ses_search_declaration_screen.dart';

class SesHomeTab extends StatelessWidget {
  const SesHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChefSesViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.declarations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.errorMessage != null) {
          return Center(child: Text("Erreur: ${viewModel.errorMessage}"));
        }

        final userName =
            FirebaseAuth.instance.currentUser?.displayName ?? 'Chef de Centre';
        final pendingCount = viewModel.nombreEnAttente;
        final validatedTodayCount = viewModel.nombreValideesAujourdhui;

        return RefreshIndicator(
          onRefresh: () async {
            /* Le stream gère le refresh */
          },
          child: ListView(
            padding: const EdgeInsets.all(kDefaultPadding),
            children: [
              Text(
                "Bonjour,",
                style: kSubtitleStyle.copyWith(color: kGreyText),
              ),
              Text(
                userName,
                style: kTitleStyle.copyWith(fontSize: 28, color: kDarkText),
              ),
              const SizedBox(height: 24),

              Text(
                "Activité du Jour",
                style: kTitleStyle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _StatCard(
                    title: "Déclarations en Attente",
                    value: pendingCount.toString(),
                    icon: Icons.hourglass_top_rounded,
                    color: kWarningColor,
                  ),
                  _StatCard(
                    title: "Validées Aujourd'hui",
                    value: validatedTodayCount.toString(),
                    icon: Icons.check_circle_outline,
                    color: kSuccessColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                "Répartition Générale des Déclarations",
                style: kTitleStyle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _StatusPieChart(
                  statusCounts: viewModel.repartitionStatuts,
                ),
              ),
              const SizedBox(height: 24),

              Text("Accès Rapides", style: kTitleStyle.copyWith(fontSize: 18)),
              const SizedBox(height: 16),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.people_alt_outlined,
                    color: kPrimaryColor,
                  ),
                  title: const Text("Consulter la liste des Employeurs"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SesEmployersListScreen(),
                        ),
                      ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.search_outlined,
                    color: kPrimaryColor,
                  ),
                  title: const Text("Rechercher une Déclaration"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SesSearchDeclarationScreen(),
                        ),
                      ),
                ),
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

class _StatusPieChart extends StatelessWidget {
  final Map<StatutDeclaration, double> statusCounts;
  const _StatusPieChart({required this.statusCounts});

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sections = [];
    final statusMap = {
      StatutDeclaration.EN_ATTENTE: {
        'color': kWarningColor,
        'title': 'En Attente',
      },
      StatutDeclaration.VALIDEE: {'color': kSuccessColor, 'title': 'Validées'},
      StatutDeclaration.REJETEE: {'color': kErrorColor, 'title': 'Rejetées'},
      StatutDeclaration.INCONNU: {'color': kGreyText, 'title': 'Inconnues'},
    };

    statusCounts.forEach((statut, count) {
      if (count > 0 && statusMap.containsKey(statut)) {
        sections.add(
          PieChartSectionData(
            color: statusMap[statut]!['color'] as Color,
            value: count,
            title: '${count.toInt()}',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    });

    if (sections.isEmpty) {
      return const Center(child: Text("Aucune déclaration à afficher."));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: PieChart(
                PieChartData(sections: sections, centerSpaceRadius: 20),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    statusCounts.keys.map((statut) {
                      if (statusCounts[statut]! > 0 &&
                          statusMap.containsKey(statut)) {
                        return _Indicator(
                          color: statusMap[statut]!['color'] as Color,
                          text: statusMap[statut]!['title'] as String,
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  const _Indicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 16, height: 16, color: color),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
