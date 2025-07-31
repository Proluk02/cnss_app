// lib/presentations/vues/dashboard/history_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/travailleur_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'declaration_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DeclarationViewModel>().chargerHistoriqueComplet();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Consumer<DeclarationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading)
            return const Center(child: CircularProgressIndicator());
          if (viewModel.erreurMessage != null)
            return Center(child: Text("Erreur: ${viewModel.erreurMessage}"));
          if (viewModel.historiqueComplet.isEmpty)
            return const Center(
              child: Text("Aucun historique de déclaration trouvé."),
            );

          final filteredHistory =
              viewModel.historiqueComplet.where((rapport) {
                return rapport.periode.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
              }).toList();

          final groupedByYear = _groupReportsByYear(filteredHistory);
          final years = groupedByYear.keys.toList();

          return RefreshIndicator(
            onRefresh: () => viewModel.chargerHistoriqueComplet(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  backgroundColor: kBackgroundColor,
                  elevation: 1,
                  title: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Rechercher par période (ex: 2024-05)...',
                      prefixIcon: const Icon(Icons.search, color: kGreyText),
                      border: InputBorder.none,
                      hintStyle: kLabelStyle,
                    ),
                  ),
                ),
                if (filteredHistory.isEmpty && _searchQuery.isNotEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text("Aucun résultat pour cette recherche."),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, yearIndex) {
                      final year = years[yearIndex];
                      final reports = groupedByYear[year]!;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 24.0,
                                bottom: 8.0,
                                left: 8.0,
                              ),
                              child: Text(year.toString(), style: kTitleStyle),
                            ),
                            ...reports
                                .map(
                                  (rapport) =>
                                      _HistoryItemCard(rapport: rapport),
                                )
                                .toList(),
                          ],
                        ),
                      );
                    }, childCount: years.length),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<int, List<RapportDeclaration>> _groupReportsByYear(
    List<RapportDeclaration> reports,
  ) {
    final Map<int, List<RapportDeclaration>> grouped = {};
    for (var report in reports) {
      final year = int.tryParse(report.periode.split('-')[0]) ?? 0;
      if (!grouped.containsKey(year)) grouped[year] = [];
      grouped[year]!.add(report);
    }
    return grouped;
  }
}

class _HistoryItemCard extends StatelessWidget {
  final RapportDeclaration rapport;
  const _HistoryItemCard({required this.rapport});

  @override
  Widget build(BuildContext context) {
    // CORRECTION : On récupère les ViewModels ici pour les passer à l'écran suivant
    final declarationVM = context.read<DeclarationViewModel>();
    final travailleurVM = context.read<TravailleurViewModel>();

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(kCardRadius),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => DeclarationDetailScreen(
                      rapport: rapport,
                      declarationVM: declarationVM, // On passe le ViewModel
                      travailleurVM: travailleurVM, // On passe le ViewModel
                    ),
              ),
            ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Période: ${rapport.periode}",
                    style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                  _StatusBadge(status: rapport.statut),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoChip(
                    icon: Icons.receipt_long_outlined,
                    label: "Cotisations",
                    value:
                        "${NumberFormat("#,##0", "fr_FR").format(rapport.totalDesCotisations)} FC",
                    color: kPrimaryColor,
                  ),
                  _InfoChip(
                    icon: Icons.people_outline,
                    label: "Employés",
                    value: rapport.nombreTravailleurs.toString(),
                    color: Colors.orange.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(kButtonRadius),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(label, style: kLabelStyle.copyWith(fontSize: 12)),
      ],
    );
  }
}
