// lib/donnees/pdf_service.dart
import 'package:cnss_app/donnees/modeles/declaration_modele.dart';
import 'package:cnss_app/donnees/modeles/travailleur_modele.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<void> imprimerDeclaration({
    required RapportDeclaration rapport,
    required String nomEmployeur,
    required String numAffiliation,
    required List<DeclarationTravailleurModele> lignesDeclarees,
    required List<TravailleurModele> tousLesTravailleurs,
  }) async {
    final doc = pw.Document();
    final logoImage = pw.MemoryImage(
      (await rootBundle.load(
        'assets/images/logo_cnss.png',
      )).buffer.asUint8List(),
    );
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();
    final theme = pw.ThemeData.withFont(base: font, bold: boldFont);

    doc.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        build:
            (context) => _buildPage1(
              context,
              logoImage,
              rapport,
              nomEmployeur,
              numAffiliation,
            ),
      ),
    );

    doc.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        header:
            (context) => _buildHeader(
              logoImage,
              "MODÈLE FEUILLE DE PAIE - Période: ${rapport.periode}",
            ),
        build:
            (context) => [
              _buildPaieTable(lignesDeclarees, tousLesTravailleurs),
            ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  pw.Widget _buildPage1(
    pw.Context context,
    pw.MemoryImage logo,
    RapportDeclaration rapport,
    String nomEmployeur,
    String numAffiliation,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildHeader(logo, "DÉCLARATION DE VERSEMENT DES COTISATIONS"),
        pw.SizedBox(height: 20),
        _buildSectionTitle("I. IDENTITÉ DE L'EMPLOYEUR"),
        _buildEmployeurInfo(nomEmployeur, numAffiliation),
        pw.SizedBox(height: 20),
        _buildSectionTitle(
          "II. ÉLÉMENTS DES COTISATIONS (Période: ${rapport.periode})",
        ),
        _buildCotisationsTable(rapport),
        pw.Spacer(),
        _buildFooter(),
      ],
    );
  }

  pw.Widget _buildHeader(pw.MemoryImage logo, String title) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "CAISSE NATIONALE DE SÉCURITÉ SOCIALE",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.Text("Direction Provinciale de Kamina"),
            pw.SizedBox(height: 12),
            pw.Text(
              title,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 16,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 60, width: 60, child: pw.Image(logo)),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _buildEmployeurInfo(String nom, String affiliation) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        children: [
          _buildTableRow("Dénomination ou raison sociale", nom),
          _buildTableRow("N° d'affiliation à la CNSS", affiliation),
        ],
      ),
    );
  }

  pw.Widget _buildCotisationsTable(RapportDeclaration rapport) {
    final format = NumberFormat("#,##0", "fr_FR");
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        children: [
          _buildTableRow(
            "Montant total brut des sommes payées",
            "${format.format(rapport.montantTotalBrut)} FC",
          ),
          _buildTableRow(
            "Nombre de Travailleurs",
            rapport.nombreTravailleurs.toString(),
          ),
          _buildTableRow(
            "Nombre d'Assimilés",
            rapport.nombreAssimiles.toString(),
          ),
          _buildTableRow(
            "Branche Pensions (10%)",
            "${format.format(rapport.cotisationPension)} FC",
          ),
          _buildTableRow(
            "Branche Risques Pro. (1.5%)",
            "${format.format(rapport.cotisationRisquePro)} FC",
          ),
          _buildTableRow(
            "Branche Famille (6.5%)",
            "${format.format(rapport.cotisationFamille)} FC",
          ),
          _buildTableRow(
            "TOTAL DES COTISATIONS",
            "${format.format(rapport.totalDesCotisations)} FC",
            isHeader: true,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPaieTable(
    List<DeclarationTravailleurModele> lignes,
    List<TravailleurModele> travailleurs,
  ) {
    final format = NumberFormat("#,##0", "fr_FR");
    final headers = ['N°', 'Nom Complet de l\'Employé', 'Salaire Brut'];

    final data =
        lignes.asMap().entries.map((entry) {
          final index = entry.key;
          final ligne = entry.value;
          final travailleur = travailleurs.firstWhere(
            (t) => t.id == ligne.travailleurId,
            orElse: () => TravailleurModele.empty(),
          );
          return [
            (index + 1).toString(),
            travailleur.nomComplet,
            "${format.format(ligne.salaireBrut)} FC",
          ];
        }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey400),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignments: {0: pw.Alignment.center, 2: pw.Alignment.centerRight},
    );
  }

  pw.Widget _buildTableRow(
    String label,
    String value, {
    bool isHeader = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: pw.BoxDecoration(
        color: isHeader ? PdfColors.grey200 : PdfColors.white,
        border: const pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text("Fait à _______________, le _______________"),
            pw.SizedBox(height: 40),
            pw.Container(width: 200, child: pw.Divider()),
            pw.Text("Nom, Signature et Sceau de l'Employeur"),
          ],
        ),
      ],
    );
  }
}
