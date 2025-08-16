// lib/presentations/vues/accueil/chef_ses_tabs/ses_history_tab.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/chef_ses_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SesHistoryTab extends StatefulWidget {
  const SesHistoryTab({super.key});

  @override
  State<SesHistoryTab> createState() => _SesHistoryTabState();
}

class _SesHistoryTabState extends State<SesHistoryTab> {
  String _searchQuery = '';
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChefSesViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.errorMessage != null) {
          return Center(child: Text("Erreur: ${viewModel.errorMessage}"));
        }
        if (viewModel.historiqueComplet.isEmpty) {
          return const Center(
              child: Text("Aucun historique de déclaration trouvé."));
        }

        // --- Logique de Filtrage ---
        var filteredHistory = viewModel.historiqueComplet;
        if (_selectedDate != null) {
          final selectedPeriod = DateFormat('yyyy-MM').format(_selectedDate!);
          filteredHistory = filteredHistory
              .where((rapport) => rapport.periode == selectedPeriod)
              .toList();
        }
        // Pour le filtrage par nom, il faudrait enrichir `historiqueComplet` dans le ViewModel,
        // ce qui est une optimisation future possible.

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(kDefaultPadding),
              color: Colors.white,
              child: InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Filtrer par période",
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(kButtonRadius))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Toutes les périodes'
                            : DateFormat('MMMM yyyy', 'fr_FR')
                                .format(_selectedDate!),
                        style: kSubtitleStyle.copyWith(
                            color: kDarkText, fontSize: 16),
                      ),
                      if (_selectedDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _selectedDate = null),
                          tooltip: "Effacer le filtre",
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {/* Le stream gère le refresh */},
                child: filteredHistory.isEmpty
                    ? const Center(
                        child: Text("Aucun résultat pour cette période."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        itemCount: filteredHistory.length,
                        itemBuilder: (context, index) {
                          final rapport = filteredHistory[index];
                          return _HistoryItemCard(rapport: rapport);
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final RapportDeclaration rapport;
  const _HistoryItemCard({required this.rapport});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat("#,##0", "fr_FR");
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Période: ${rapport.periode}",
                  style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold)),
              _StatusBadge(status: rapport.statut),
            ]),
            const Divider(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _InfoChip(
                  icon: Icons.receipt_long_outlined,
                  label: "Cotisations",
                  value: "${format.format(rapport.totalDesCotisations)} FC",
                  color: kPrimaryColor),
              _InfoChip(
                  icon: Icons.people_outline,
                  label: "Employés",
                  value: rapport.nombreTravailleurs.toString(),
                  color: Colors.orange.shade700),
            ]),
          ],
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
          borderRadius: BorderRadius.circular(kButtonRadius)),
      child: Text(text,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoChip(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      Text(label, style: kLabelStyle.copyWith(fontSize: 12)),
    ]);
  }
}
