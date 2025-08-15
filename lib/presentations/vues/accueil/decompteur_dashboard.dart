// lib/presentations/vues/accueil/decompteur_dashboard.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/auth_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/decompteur_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DecompteurDashboard extends StatelessWidget {
  const DecompteurDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DecompteurViewModel(),
      child: const _DecompteurDashboardView(),
    );
  }
}

class _DecompteurDashboardView extends StatefulWidget {
  const _DecompteurDashboardView();

  @override
  State<_DecompteurDashboardView> createState() =>
      _DecompteurDashboardViewState();
}

class _DecompteurDashboardViewState extends State<_DecompteurDashboardView> {
  Future<void> _selectDate(BuildContext context) async {
    final viewModel = context.read<DecompteurViewModel>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != viewModel.selectedDate) {
      viewModel.chargerDeclarationsDuJour(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DecompteurViewModel>();
    // CORRECTION : Utilisation de DateFormat
    final dateFormat = DateFormat.yMMMMd('fr_FR');

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("État Journalier",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: kAppBarGradient)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => context.read<AuthViewModel>().logout(),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(kDefaultPadding),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: kCardShadow,
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Date de Production",
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(kButtonRadius))),
                    ),
                    child: Text(
                      dateFormat.format(viewModel
                          .selectedDate), // Utilisation de la variable corrigée
                      style: kSubtitleStyle.copyWith(
                          color: kDarkText, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatRow(viewModel),
              ],
            ),
          ),
          Expanded(child: _buildContentList(context, viewModel)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: viewModel.declarationsDuJour.isEmpty || viewModel.isLoading
            ? null
            : () => viewModel.imprimerEtatJournalier(),
        label: const Text("Imprimer l'État Journalier"),
        icon: viewModel.isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.print_outlined),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatRow(DecompteurViewModel viewModel) {
    final totalCotisations = viewModel.declarationsDuJour.fold<double>(
        0.0, (sum, item) => sum + item.rapport.totalDesCotisations);
    final format = NumberFormat("#,##0", "fr_FR");

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: "Déclarations Validées",
            value: viewModel.declarationsDuJour.length.toString(),
            color: kSuccessColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: "Total Cotisations",
            value: "${format.format(totalCotisations)} FC",
            color: kPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildContentList(
      BuildContext context, DecompteurViewModel viewModel) {
    if (viewModel.isLoading)
      return const Center(child: CircularProgressIndicator());
    if (viewModel.errorMessage != null)
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Text(viewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kErrorColor))));
    if (viewModel.declarationsDuJour.isEmpty) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Aucune déclaration validée",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // CORRECTION : Utilisation de DateFormat
          Text(
              "Aucune déclaration n'a été validée le ${DateFormat.yMMMMd('fr_FR').format(viewModel.selectedDate)}.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: kGreyText)),
        ]),
      ));
    }

    final format = NumberFormat("#,##0", "fr_FR");
    return ListView.builder(
      padding: const EdgeInsets.all(kDefaultPadding),
      itemCount: viewModel.declarationsDuJour.length,
      itemBuilder: (context, index) {
        final item = viewModel.declarationsDuJour[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kCardRadius)),
          child: ListTile(
            leading: CircleAvatar(
                backgroundColor: kSuccessColor.withOpacity(0.1),
                child: const Icon(Icons.check, color: kSuccessColor)),
            title: Text(item.employeurNom,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                "Période: ${item.rapport.periode} | N° Aff: ${item.numAffiliation}"),
            trailing: Text(
                "${format.format(item.rapport.totalDesCotisations)} FC",
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: kPrimaryColor)),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard(
      {required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
