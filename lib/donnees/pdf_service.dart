// lib/donnees/pdf_service.dart

import 'dart:typed_data';

import 'package:cnss_app/donnees/modeles/declaration_modele.dart';
import 'package:cnss_app/donnees/modeles/travailleur_modele.dart';
import 'package:cnss_app/donnees/modeles/utilisateur_modele.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/decompteur_viewmodel.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  // --- LOGIQUE POUR LA DÉCLARATION DE L'EMPLOYEUR ---

  Future<void> imprimerDeclaration({
    required RapportDeclaration rapport,
    required String nomEmployeur,
    required String numAffiliation,
    required List<DeclarationTravailleurModele> lignesDeclarees,
    required List<TravailleurModele> tousLesTravailleurs,
  }) async {
    final doc = pw.Document();
    final logoImage = pw.MemoryImage(
        (await rootBundle.load('assets/images/logo_cnss.png'))
            .buffer
            .asUint8List());
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();
    final theme = pw.ThemeData.withFont(base: font, bold: boldFont);

    doc.addPage(pw.Page(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      build: (context) => _buildPage1(
          context, logoImage, rapport, nomEmployeur, numAffiliation),
    ));

    doc.addPage(pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      header: (context) => _buildHeader(
          logoImage, "MODÈLE FEUILLE DE PAIE - Période: ${rapport.periode}"),
      build: (context) =>
          [_buildPaieTable(lignesDeclarees, tousLesTravailleurs)],
    ));

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  pw.Widget _buildPage1(pw.Context context, pw.MemoryImage logo,
      RapportDeclaration rapport, String nomEmployeur, String numAffiliation) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildHeader(logo, "DÉCLARATION DE VERSEMENT DES COTISATIONS"),
          pw.SizedBox(height: 20),
          _buildSectionTitle("I. IDENTITÉ DE L'EMPLOYEUR"),
          _buildEmployeurInfo(nomEmployeur, numAffiliation),
          pw.SizedBox(height: 20),
          _buildSectionTitle(
              "II. ÉLÉMENTS DES COTISATIONS (Période: ${rapport.periode})"),
          _buildCotisationsTable(rapport),
          pw.Spacer(),
          _buildFooter(),
        ]);
  }

  pw.Widget _buildHeader(pw.MemoryImage logo, String title) {
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text("CAISSE NATIONALE DE SÉCURITÉ SOCIALE",
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
            pw.Text("Direction Provinciale de Kamina"),
            pw.SizedBox(height: 12),
            pw.Text(title,
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                    decoration: pw.TextDecoration.underline)),
          ]),
          pw.SizedBox(height: 60, width: 60, child: pw.Image(logo)),
        ]);
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      child:
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget _buildEmployeurInfo(String nom, String affiliation) {
    return pw.Container(
        decoration:
            pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
        child: pw.Column(children: [
          _buildTableRow("Dénomination ou raison sociale", nom),
          _buildTableRow("N° d'affiliation à la CNSS", affiliation),
        ]));
  }

  pw.Widget _buildCotisationsTable(RapportDeclaration rapport) {
    final format = NumberFormat("#,##0", "fr_FR");
    return pw.Container(
        decoration:
            pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
        child: pw.Column(children: [
          _buildTableRow("Montant total brut des sommes payées",
              "${format.format(rapport.montantTotalBrut)} FC"),
          _buildTableRow(
              "Nombre de Travailleurs", rapport.nombreTravailleurs.toString()),
          _buildTableRow(
              "Nombre d'Assimilés", rapport.nombreAssimiles.toString()),
          _buildTableRow("Branche Pensions (10%)",
              "${format.format(rapport.cotisationPension)} FC"),
          _buildTableRow("Branche Risques Pro. (1..5%)",
              "${format.format(rapport.cotisationRisquePro)} FC"),
          _buildTableRow("Branche Famille (6.5%)",
              "${format.format(rapport.cotisationFamille)} FC"),
          _buildTableRow("TOTAL DES COTISATIONS",
              "${format.format(rapport.totalDesCotisations)} FC",
              isHeader: true),
        ]));
  }

  pw.Widget _buildPaieTable(List<DeclarationTravailleurModele> lignes,
      List<TravailleurModele> travailleurs) {
    final format = NumberFormat("#,##0", "fr_FR");
    final headers = ['N°', 'Nom Complet de l\'Employé', 'Salaire Brut'];

    final data = lignes.asMap().entries.map((entry) {
      final index = entry.key;
      final ligne = entry.value;
      final travailleur = travailleurs.firstWhere(
          (t) => t.id == ligne.travailleurId,
          orElse: () => TravailleurModele.empty());
      return [
        (index + 1).toString(),
        travailleur.nomComplet,
        "${format.format(ligne.salaireBrut)} FC"
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey400),
      headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignments: {0: pw.Alignment.center, 2: pw.Alignment.centerRight},
    );
  }

  pw.Widget _buildTableRow(String label, String value,
      {bool isHeader = false}) {
    return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: pw.BoxDecoration(
          color: isHeader ? PdfColors.grey200 : PdfColors.white,
          border: const pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
        ),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label,
                  style: pw.TextStyle(
                      fontWeight: isHeader
                          ? pw.FontWeight.bold
                          : pw.FontWeight.normal)),
              pw.Text(value,
                  style: pw.TextStyle(
                      fontWeight: isHeader
                          ? pw.FontWeight.bold
                          : pw.FontWeight.normal)),
            ]));
  }

  pw.Widget _buildFooter() {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
        pw.Text("Fait à _______________, le _______________"),
        pw.SizedBox(height: 40),
        pw.Container(width: 200, child: pw.Divider()),
        pw.Text("Nom, Signature et Sceau de l'Employeur"),
      ])
    ]);
  }

  // --- LOGIQUE POUR L'ÉTAT JOURNALIER DU DÉCOMPTEUR ---

  Future<void> imprimerEtatJournalier({
    required DateTime date,
    required List<RapportJournalier> rapportsJournaliers,
  }) async {
    final doc = pw.Document();
    final logoImage = pw.MemoryImage(
        (await rootBundle.load('assets/images/logo_cnss.png'))
            .buffer
            .asUint8List());
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();
    final theme = pw.ThemeData.withFont(base: font, bold: boldFont);

    doc.addPage(pw.Page(
      theme: theme,
      pageFormat: PdfPageFormat.a4.landscape,
      build: (context) => _buildEtatJournalierPage(
          context, logoImage, date, rapportsJournaliers),
    ));

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  pw.Widget _buildEtatJournalierPage(pw.Context context, pw.MemoryImage logo,
      DateTime date, List<RapportJournalier> rapports) {
    final format = NumberFormat("#,##0", "fr_FR");
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _buildEtatHeader(logo, date),
          pw.SizedBox(height: 20),
          _buildEtatTable(rapports, format),
          pw.Spacer(),
          _buildEtatSignatures(),
        ]);
  }

  pw.Widget _buildEtatHeader(pw.MemoryImage logo, DateTime date) {
    return pw
        .Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text("RÉPUBLIQUE DÉMOCRATIQUE DU CONGO",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
        pw.Text("Caisse Nationale de Sécurité Sociale",
            style: const pw.TextStyle(fontSize: 8)),
        pw.Text("Direction Provinciale de Kamina",
            style: const pw.TextStyle(fontSize: 8)),
      ]),
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
        pw.Text("ETAT JOURNALIER DE PRODUCTION",
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 16,
                decoration: pw.TextDecoration.underline)),
        pw.SizedBox(height: 8),
        pw.Text("JOURNEE DU ${DateFormat('dd/MM/yyyy', 'fr_FR').format(date)}"),
      ]),
      pw.SizedBox(height: 50, width: 50, child: pw.Image(logo)),
    ]);
  }

  pw.Widget _buildEtatTable(
      List<RapportJournalier> rapports, NumberFormat format) {
    const tableHeaders = [
      'DÉNOMINATION\n(1)',
      'N° AFFILIATION\n(2)',
      'NB TRAV.\n(3)',
      'NB ENF.\n(4)',
      'PÉRIODE\n(5)',
      'EX. EN COURS\n(6)',
      'ARRIÉRÉES\n(7)',
      'TAX. OFFICE\n(8)',
      'MAJ. RETARD\n(9)'
    ];

    final data = rapports.map((item) {
      final r = item.rapport;
      return [
        item.employeurNom,
        item.numAffiliation,
        r.nombreTravailleurs.toString(),
        r.nombreEnfants.toString(),
        r.periode,
        format.format(r.totalDesCotisations),
        format.format(r.arrierees),
        format.format(r.taxationOffice),
        format.format(r.majorationRetard)
      ];
    }).toList();

    final totalTrav = rapports.fold<int>(
        0, (sum, item) => sum + item.rapport.nombreTravailleurs);
    final totalEnf =
        rapports.fold<int>(0, (sum, item) => sum + item.rapport.nombreEnfants);
    final totalCours = rapports.fold<double>(
        0.0, (sum, item) => sum + item.rapport.totalDesCotisations);
    final totalArr =
        rapports.fold<double>(0.0, (sum, item) => sum + item.rapport.arrierees);
    final totalTax = rapports.fold<double>(
        0.0, (sum, item) => sum + item.rapport.taxationOffice);
    final totalMaj = rapports.fold<double>(
        0.0, (sum, item) => sum + item.rapport.majorationRetard);

    data.add([
      'TOTAL (10)',
      '',
      totalTrav.toString(),
      totalEnf.toString(),
      '',
      format.format(totalCours),
      format.format(totalArr),
      format.format(totalTax),
      format.format(totalMaj)
    ]);

    return pw.Table.fromTextArray(
      headers: tableHeaders,
      data: data,
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7),
      cellStyle: const pw.TextStyle(fontSize: 7),
      headerCellDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.centerRight,
        7: pw.Alignment.centerRight,
        8: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildEtatSignatures() {
    return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 40),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _signatureBlock("LE PREPOSE", "Jean-Claude NGOY MWENZE"),
              _signatureBlock(
                  "LE CHEF DE SERVICE SES", "Christine KAIND MUTEB"),
              _signatureBlock(
                  "LE SOUS-DIRECTEUR TECHNIQUE", "Alex KIBAMBA NGOY MUYA"),
              _signatureBlock(
                  "LE DIRECTEUR PROVINCIAL", "Augustin MPOYI TSHIKALA"),
            ]));
  }

  pw.Widget _signatureBlock(String title, String name) {
    return pw.Column(children: [
      pw.Text(title,
          style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline,
              fontSize: 10)),
      pw.SizedBox(height: 50),
      pw.Text(name, style: const pw.TextStyle(fontSize: 10)),
    ]);
  }

  // --- LOGIQUE POUR LA FICHE DE COMPTE DU PRÉPOSÉ ---

  Future<void> imprimerFicheDeCompte({
    required UtilisateurModele employeur,
    required List<RapportDeclaration> rapports,
  }) async {
    final doc = pw.Document();
    final logoImage = pw.MemoryImage(
        (await rootBundle.load('assets/images/logo_cnss.png'))
            .buffer
            .asUint8List());
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();
    final theme = pw.ThemeData.withFont(base: font, bold: boldFont);

    doc.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4.landscape,
        orientation: pw.PageOrientation.natural,
        header: (context) => _buildFicheHeader(logoImage, employeur),
        footer: (context) => _buildFicheFooter(context),
        build: (context) => [_buildFicheTable(rapports)],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  pw.Widget _buildFicheHeader(
      pw.MemoryImage logo, UtilisateurModele employeur) {
    return pw.Column(children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text("CAISSE NATIONALE DE SÉCURITÉ SOCIALE",
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Text("DIRECTION PROVINCIALE KAT III",
              style: const pw.TextStyle(fontSize: 9)),
          pw.Text("BUREAU CNSS/KAMINA", style: const pw.TextStyle(fontSize: 9)),
        ]),
        pw.SizedBox(height: 50, width: 50, child: pw.Image(logo)),
      ]),
      pw.SizedBox(height: 10),
      pw.Center(
          child: pw.Text("FICHE DE COMPTE COTISANT",
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                  decoration: pw.TextDecoration.underline))),
      pw.SizedBox(height: 10),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text("N° D'AFFILIATION: ${employeur.numAffiliation ?? 'N/A'}"),
          pw.Text("RAISON SOCIALE: ${employeur.nom ?? 'N/A'}"),
        ]),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text("ADRESSE POSTALE: "),
          pw.Text("ADRESSE GÉOGRAPHIQUE: "),
        ])
      ]),
      pw.Divider(color: PdfColors.black, thickness: 1.5),
      pw.SizedBox(height: 5),
    ]);
  }

  pw.Widget _buildFicheFooter(pw.Context context) {
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
              'Généré le ${DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(DateTime.now())} par CnssApp'),
          pw.Text('Page ${context.pageNumber} sur ${context.pagesCount}'),
        ]);
  }

  pw.Widget _buildFicheTable(List<RapportDeclaration> rapports) {
    final format = NumberFormat("#,##0.00", "fr_FR");
    double runningDebit = 0.0;
    double runningCredit = 0.0;
    double runningBalance = 0.0;

    const headers = [
      'Date Op.',
      'Libellé',
      'Pièces\nJustif.',
      'DÉBIT\nCot. Ex. cours',
      'DÉBIT\nCot. Antérieur',
      'DÉBIT\nMaj. retard',
      'CUMUL DÉBIT',
      'CRÉDIT\nCot. Ex. cours',
      'CRÉDIT\nCot. Antérieur',
      'CRÉDIT\nMaj. retard',
      'CUMUL CRÉDIT',
      'SOLDE'
    ];

    final data = rapports.map((r) {
      final debitCours = r.totalDesCotisations;
      final debitAnterieur = r.arrierees;
      final debitMajoration = r.majorationRetard;
      runningDebit += debitCours + debitAnterieur + debitMajoration;

      const creditCours = 0.0;
      const creditAnterieur = 0.0;
      const creditMajoration = 0.0;
      runningCredit += creditCours + creditAnterieur + creditMajoration;

      runningBalance = runningDebit - runningCredit;

      return [
        DateFormat('dd/MM/yy').format(DateTime.now()),
        'DÉCLARATION PÉRIODE ${r.periode}',
        'N/A',
        format.format(debitCours),
        format.format(debitAnterieur),
        format.format(debitMajoration),
        format.format(runningDebit),
        format.format(creditCours),
        format.format(creditAnterieur),
        format.format(creditMajoration),
        format.format(runningCredit),
        format.format(runningBalance)
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6),
      headerAlignment: pw.Alignment.center,
      cellStyle: const pw.TextStyle(fontSize: 7),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        for (int i = 3; i <= 11; i++) i: pw.Alignment.centerRight,
      },
    );
  }

  Future<void> imprimerRapportGlobal({
    required DateTime date,
    required List<RapportJournalier> rapportsJournaliers,
  }) async {
    final doc = pw.Document();
    final logoImage = pw.MemoryImage(
        (await rootBundle.load('assets/images/logo_cnss.png'))
            .buffer
            .asUint8List());
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();
    final theme = pw.ThemeData.withFont(base: font, bold: boldFont);

    doc.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => _buildEtatJournalierPage(
            context, logoImage, date, rapportsJournaliers),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  Future<void> imprimerRapportMensuel({
    required UtilisateurModele employeur,
    required List<RapportDeclaration> rapports,
    required String mois,
  }) async {
    final doc = pw.Document();
    final logoImage = pw.MemoryImage(
        (await rootBundle.load('assets/images/logo_cnss.png'))
            .buffer
            .asUint8List());
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();
    final theme = pw.ThemeData.withFont(base: font, bold: boldFont);

    // On réutilise la logique de la Fiche de Compte, mais avec un titre différent
    doc.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4.landscape,
        header: (context) => _buildHeader(logoImage, "RAPPORT MENSUEL - $mois"),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildEmployeurInfo(
              employeur.nom ?? 'N/A', employeur.numAffiliation ?? 'N/A'),
          pw.SizedBox(height: 20),
          _buildFicheTable(
              rapports), // On réutilise le tableau de la fiche de compte
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }
}
