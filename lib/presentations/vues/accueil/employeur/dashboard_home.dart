// lib/presentations/vues/dashboard/dashboard_home.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/travailleur_viewmodel.dart';
import 'package:cnss_app/presentations/vues/accueil/employeur/declaration_detail_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardHome extends StatelessWidget {
  final Function(int) onNavigate;
  const DashboardHome({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeclarationViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.periodeActuelle == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.erreurMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Text(
                "Erreur: ${viewModel.erreurMessage}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: kErrorColor),
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            _WelcomeHeader(
              name: FirebaseAuth.instance.currentUser?.displayName,
              email: FirebaseAuth.instance.currentUser?.email,
            ),
            const SizedBox(height: 24),
            _StatusInfoCard(
              status: viewModel.statut,
              periode: viewModel.periodeAffichee,
            ),
            const SizedBox(height: 24),
            _DraftSummaryCard(
              viewModel: viewModel,
              onNavigate: () => onNavigate(2),
            ),
            const SizedBox(height: 24),
            Text(
              "Historique des Cotisations",
              style: kTitleStyle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child:
                  viewModel.declarationsRecentes.isEmpty
                      ? const Center(
                        child: Text("Le graphique apparaîtra ici."),
                      )
                      : _ChartCard(reports: viewModel.declarationsRecentes),
            ),
            const SizedBox(height: 24),
            Text(
              "Dernières Déclarations Finalisées",
              style: kTitleStyle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (viewModel.declarationsRecentes.isEmpty)
              const Center(
                child: Text("Aucune déclaration finalisée pour le moment."),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.declarationsRecentes.length,
                itemBuilder: (context, index) {
                  final rapport = viewModel.declarationsRecentes[index];
                  return _HistoryListItem(rapport: rapport);
                },
              ),
          ],
        );
      },
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String? name;
  final String? email;
  const _WelcomeHeader({this.name, this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name ?? 'Employeur',
          style: kTitleStyle.copyWith(fontSize: 28, color: kDarkText),
        ),
        const SizedBox(height: 4),
        Text(
          email ?? 'Bienvenue sur votre espace',
          style: kSubtitleStyle.copyWith(color: kGreyText, fontSize: 16),
        ),
      ],
    );
  }
}

class _StatusInfoCard extends StatelessWidget {
  final StatutEmployeur status;
  final String periode;
  const _StatusInfoCard({required this.status, required this.periode});

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;
    IconData icon;
    Color color;
    switch (status) {
      case StatutEmployeur.EN_ORDRE:
        title = "Prêt à déclarer";
        subtitle = "Finalisez la déclaration pour : $periode.";
        icon = Icons.playlist_add_check_circle_outlined;
        color = kPrimaryColor;
        break;
      case StatutEmployeur.EN_RETARD:
        title = "Déclaration en retard";
        subtitle = "Veuillez finaliser la déclaration pour : $periode.";
        icon = Icons.warning_amber_rounded;
        color = kWarningColor;
        break;
      case StatutEmployeur.A_JOUR:
        title = "Vous êtes à jour";
        subtitle = "Prochaine période à déclarer : $periode.";
        icon = Icons.task_alt;
        color = kSuccessColor;
        break;
      default:
        title = "Chargement...";
        subtitle = "Vérification de votre statut...";
        icon = Icons.hourglass_empty;
        color = Colors.grey;
        break;
    }
    return Card(
      elevation: 6,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      shadowColor: color.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftSummaryCard extends StatelessWidget {
  final DeclarationViewModel viewModel;
  final VoidCallback onNavigate;
  const _DraftSummaryCard({required this.viewModel, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final lignesDeclarees =
        viewModel.lignesBrouillon.where((l) => l.salaireBrut > 0).toList();
    final totalBrut = lignesDeclarees.fold(
      0.0,
      (sum, item) => sum + item.salaireBrut,
    );
    final totalCotisations =
        (totalBrut * 0.10) + (totalBrut * 0.015) + (totalBrut * 0.065);
    final declaredCount = lignesDeclarees.length;
    final totalCount = viewModel.tousLesTravailleurs.length;
    final progress = totalCount > 0 ? declaredCount / totalCount : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Brouillon pour : ${viewModel.periodeAffichee}",
              style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Brut',
                    value:
                        '${NumberFormat("#,##0", "fr_FR").format(totalBrut)} FC',
                    color: kSuccessColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Cotisations Estimées',
                    value:
                        '${NumberFormat("#,##0", "fr_FR").format(totalCotisations)} FC',
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Progression", style: kLabelStyle),
                Text(
                  "$declaredCount / $totalCount Employés",
                  style: kLabelStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: kPrimaryColor.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kButtonRadius),
                  ),
                ),
                child: const Text("Compléter la déclaration"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<RapportDeclaration> reports;
  const _ChartCard({required this.reports});

  @override
  Widget build(BuildContext context) {
    final reversedReports = reports.reversed.toList();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor:
                    (FlSpot spot) => kPrimaryColor.withOpacity(0.8),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${NumberFormat("#,##0", "fr_FR").format(spot.y)} FC\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: reversedReports[spot.spotIndex].periode,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (int i = 0; i < reversedReports.length; i++)
                    FlSpot(
                      i.toDouble(),
                      reversedReports[i].totalDesCotisations,
                    ),
                ],
                isCurved: true,
                color: kLineChartColor,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      kLineChartColor.withOpacity(0.3),
                      kLineChartColor.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryListItem extends StatelessWidget {
  final RapportDeclaration rapport;
  const _HistoryListItem({required this.rapport});

  @override
  Widget build(BuildContext context) {
    // CORRECTION : On récupère les ViewModels ici, dans le contexte où ils sont disponibles.
    final declarationVM = context.read<DeclarationViewModel>();
    final travailleurVM = context.read<TravailleurViewModel>();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: _getIconForStatus(rapport.statut),
        title: Text(
          "Période: ${rapport.periode}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Total cotisé: ${NumberFormat("#,##0", "fr_FR").format(rapport.totalDesCotisations)} FC",
        ),
        trailing: _StatusBadge(status: rapport.statut),
        onTap: () {
          // CORRECTION : L'appel est maintenant valide car on passe les ViewModels requis.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => DeclarationDetailScreen(
                    rapport: rapport,
                    declarationVM: declarationVM,
                    travailleurVM: travailleurVM,
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _getIconForStatus(StatutDeclaration status) {
    switch (status) {
      case StatutDeclaration.EN_ATTENTE:
        return Icon(Icons.hourglass_top_rounded, color: Colors.orange.shade700);
      case StatutDeclaration.VALIDEE:
        return const Icon(Icons.check_circle, color: kSuccessColor);
      case StatutDeclaration.REJETEE:
        return const Icon(Icons.cancel, color: kErrorColor);
      default:
        return const Icon(Icons.help_outline, color: kGreyText);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final StatutDeclaration status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    switch (status) {
      case StatutDeclaration.EN_ATTENTE:
        text = 'En attente';
        color = kWarningColor;
        break;
      case StatutDeclaration.VALIDEE:
        text = 'Validée';
        color = kSuccessColor;
        break;
      case StatutDeclaration.REJETEE:
        text = 'Rejetée';
        color = kErrorColor;
        break;
      default:
        text = 'Inconnu';
        color = kGreyText;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
