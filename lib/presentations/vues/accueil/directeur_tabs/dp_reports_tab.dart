// lib/presentations/vues/accueil/directeur_tabs/dp_reports_tab.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/modeles/utilisateur_modele.dart';
import 'package:cnss_app/donnees/pdf_service.dart';
import 'package:cnss_app/presentations/viewmodels/decompteur_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/prepose_viewmodel.dart';
import 'package:cnss_app/presentations/vues/accueil/prepose_tabs/prepose_search_tab.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';

class DpReportsTab extends StatelessWidget {
  const DpReportsTab({super.key});

  Future<void> _generateDailyReport(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      // On crée un ViewModel temporaire juste pour cette action
      final tempViewModel = DecompteurViewModel();
      await tempViewModel.chargerDeclarationsDuJour(picked);

      if (!context.mounted) return;

      if (tempViewModel.declarationsDuJour.isNotEmpty) {
        await tempViewModel.imprimerEtatJournalier();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Aucune déclaration validée à cette date.")));
      }
    }
  }

  Future<void> _selectEmployerForMonthlyReport(BuildContext context) async {
    final UtilisateurModele? selectedEmployer = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _SelectEmployeurScreen()),
    );

    if (selectedEmployer == null || !context.mounted) return;

    final DateTime? selectedMonth = await showMonthYearPicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );

    if (selectedMonth == null || !context.mounted) return;

    final preposeVM = PreposeViewModel();
    await preposeVM.chargerFicheDeCompte(selectedEmployer.uid);

    if (!context.mounted) return;

    final monthKey = DateFormat('yyyy-MM').format(selectedMonth);
    final monthlyReports = preposeVM.ficheDeCompte
        .where((r) => r.periode.startsWith(monthKey))
        .toList();

    if (monthlyReports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Aucune déclaration trouvée pour cet employeur à cette période.")));
      return;
    }

    await PdfService().imprimerRapportMensuel(
      employeur: selectedEmployer,
      rapports: monthlyReports,
      mois: DateFormat.yMMMM('fr_FR').format(selectedMonth),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text("Génération de Rapports", style: kTitleStyle),
          const SizedBox(height: 16),
          _ReportActionCard(
            title: "État Journalier Global",
            subtitle:
                "Générer un résumé des déclarations validées pour une date spécifique.",
            icon: Icons.today_outlined,
            onTap: () => _generateDailyReport(context),
          ),
          _ReportActionCard(
            title: "Rapport Mensuel par Employeur",
            subtitle:
                "Générer un rapport détaillé de l'activité d'un employeur sur un mois donné.",
            icon: Icons.person_search_outlined,
            onTap: () => _selectEmployerForMonthlyReport(context),
          ),
        ],
      ),
    );
  }
}

class _ReportActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ReportActionCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius)),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _SelectEmployeurScreen extends StatelessWidget {
  const _SelectEmployeurScreen();

  @override
  Widget build(BuildContext context) {
    // Fournit un PreposeViewModel frais pour cet écran de sélection
    return ChangeNotifierProvider(
      create: (_) => PreposeViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sélectionner un Employeur"),
          flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: kAppBarGradient)),
        ),
        body: const PreposeSearchTab(),
      ),
    );
  }
}
