// lib/presentations/vues/accueil/prepose_tabs/fiche_compte_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/modeles/utilisateur_modele.dart';
import 'package:cnss_app/donnees/pdf_service.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/prepose_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FicheCompteScreen extends StatefulWidget {
  final UtilisateurModele employeur;
  const FicheCompteScreen({super.key, required this.employeur});

  @override
  State<FicheCompteScreen> createState() => _FicheCompteScreenState();
}

class _FicheCompteScreenState extends State<FicheCompteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<PreposeViewModel>()
          .chargerFicheDeCompte(widget.employeur.uid);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PreposeViewModel>().clearFicheDeCompte();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PreposeViewModel>();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Fiche de Compte Cotisant"),
        flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: kAppBarGradient)),
      ),
      body: Column(
        children: [
          _buildEmployerHeader(widget.employeur),
          _buildTableHeader(),
          Expanded(child: _buildBody(viewModel)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: viewModel.isLoadingFiche || viewModel.ficheDeCompte.isEmpty
            ? null
            : () {
                PdfService().imprimerFicheDeCompte(
                    employeur: widget.employeur,
                    rapports: viewModel.ficheDeCompte);
              },
        label: const Text("Imprimer la Fiche"),
        icon: const Icon(Icons.print_outlined),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmployerHeader(UtilisateurModele employeur) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(employeur.nom ?? 'N/A', style: kTitleStyle),
          const SizedBox(height: 4),
          Text(
              "N° Affiliation: ${employeur.numAffiliation?.isNotEmpty ?? false ? employeur.numAffiliation! : 'Non défini'}",
              style: kLabelStyle),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      // CORRECTION : La couleur est maintenant DANS la décoration
      decoration: BoxDecoration(
          color: Colors.white, // La couleur est ici
          border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          _buildHeaderCell("Période"),
          _buildHeaderCell("Libellé", flex: 2),
          _buildHeaderCell("Débit", alignment: TextAlign.right),
          _buildHeaderCell("Solde", alignment: TextAlign.right),
        ],
      ),
    );
  }

  Widget _buildBody(PreposeViewModel viewModel) {
    if (viewModel.isLoadingFiche)
      return const Center(child: CircularProgressIndicator());
    if (viewModel.ficheErrorMessage != null)
      return Center(child: Text(viewModel.ficheErrorMessage!));
    if (viewModel.ficheDeCompte.isEmpty)
      return const Center(
          child: Text("Aucune déclaration pour cet employeur."));

    double runningBalance = 0.0;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: 8.0, vertical: 8.0), // Padding ajusté
      itemCount: viewModel.ficheDeCompte.length,
      itemBuilder: (context, index) {
        final rapport = viewModel.ficheDeCompte[index];
        final debit = rapport.montantTotalAPayer;
        const credit = 0.0;
        runningBalance += debit - credit;
        return _buildDataRow(rapport, debit, credit, runningBalance);
      },
    );
  }

  Widget _buildHeaderCell(String text,
      {int flex = 1, TextAlign alignment = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: kLabelStyle.copyWith(
              fontWeight: FontWeight.bold, color: kDarkText),
          textAlign: alignment),
    );
  }

  Widget _buildDataRow(
      RapportDeclaration rapport, double debit, double credit, double solde) {
    final format = NumberFormat("#,##0", "fr_FR");
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(rapport.periode)),
          Expanded(
              flex: 2,
              child: Text(
                  'Cotisation (${rapport.statut.toString().split(".").last})',
                  overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: 1,
              child: Text("${format.format(debit)} FC",
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: kErrorColor))),
          Expanded(
              flex: 1,
              child: Text("${format.format(solde)} FC",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
