// lib/presentations/vues/accueil/directeur_tabs/dp_home_tab.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/directeur_viewmodel.dart';
import 'package:cnss_app/presentations/vues/accueil/employeur/declaration_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DpHomeTab extends StatelessWidget {
  const DpHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DirecteurViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.errorMessage != null) {
          return Center(child: Text(viewModel.errorMessage!));
        }

        final format = NumberFormat("#,##0", "fr_FR");
        final userName = FirebaseAuth.instance.currentUser?.displayName ??
            'Directeur Provincial';

        return RefreshIndicator(
          onRefresh: () => viewModel.rafraichirDonnees(),
          child: ListView(
            padding: const EdgeInsets.all(kDefaultPadding),
            children: [
              Text("Bonjour,",
                  style: kSubtitleStyle.copyWith(color: kGreyText)),
              Text(userName,
                  style: kTitleStyle.copyWith(fontSize: 28, color: kDarkText)),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kCardRadius)),
                color: kPrimaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text("Total des Cotisations Validées (Mois en cours)",
                          style:
                              kSubtitleStyle.copyWith(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text(
                        "${format.format(viewModel.totalCotisationsMoisEnCours)} FC",
                        style: kTitleStyle.copyWith(
                            color: Colors.white, fontSize: 32),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _StatCard(
                      title: "Employeurs Actifs",
                      value: viewModel.nombreEmployeurs.toString(),
                      icon: Icons.business_center,
                      color: kSecondaryColor),
                  _StatCard(
                      title: "Déclarations en Retard",
                      value: viewModel.declarationsEnRetard.toString(),
                      icon: Icons.warning_amber_rounded,
                      color: kErrorColor),
                ],
              ),
              const SizedBox(height: 24),
              Text("Cotisations Mensuelles Validées",
                  style: kTitleStyle.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: viewModel.cotisationsParMois.isEmpty
                    ? const Center(child: Text("Le graphique apparaîtra ici."))
                    : _MonthlyContributionsChart(
                        monthlyData: viewModel.cotisationsParMois),
              ),
              const SizedBox(height: 24),
              Text("Dernières Déclarations Validées",
                  style: kTitleStyle.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              if (viewModel.declarationsRecentes.isEmpty)
                const Center(
                    child: Text("Aucune déclaration validée récemment."))
              else
                Column(
                  children: viewModel.declarationsRecentes
                      .map((rapport) => _RecentActivityTile(rapport: rapport))
                      .toList(),
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

class _MonthlyContributionsChart extends StatelessWidget {
  final Map<String, double> monthlyData;
  const _MonthlyContributionsChart({required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.compact(locale: "fr_FR");
    final sortedKeys = monthlyData.keys.toList()..sort();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => kPrimaryColor.withOpacity(0.8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${NumberFormat("#,##0", "fr_FR").format(rod.toY)} FC',
                    const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                          format.format(value),
                          style: const TextStyle(fontSize: 10)))),
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                          sortedKeys[value.toInt()].substring(5),
                          style: const TextStyle(fontSize: 10)))),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(sortedKeys.length, (index) {
              final key = sortedKeys[index];
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                      toY: monthlyData[key]!,
                      color: kPrimaryColor,
                      width: 16,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)))
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _RecentActivityTile extends StatelessWidget {
  final RapportDeclaration rapport;
  const _RecentActivityTile({required this.rapport});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
            backgroundColor: kSuccessColor,
            child: Icon(Icons.check, color: Colors.white)),
        title: Text("Période ${rapport.periode}"),
        subtitle: const Text("Employeur: [Nom à récupérer]"),
        trailing: Text(
            "${NumberFormat("#,##0", "fr_FR").format(rapport.totalDesCotisations)} FC"),
      ),
    );
  }
}
