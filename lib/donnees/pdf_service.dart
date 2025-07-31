// lib/donnees/pdf_service.dart

import 'dart:typed_data';
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
    // On passe les informations de l'employeur et la liste des travailleurs déclarés
    required String nomEmployeur,
    required String numAffiliation,
    required List<DeclarationTravailleurModele> lignesDeclarees,
    required List<TravailleurModele> tousLesTravailleurs,
  }) async {
    final doc = pw.Document();

    // Charger le logo CNSS depuis les assets
    final logoImage = pw.MemoryImage(
      (await rootBundle.load(
        'assets/images/logo_cnss.png',
      )).buffer.asUint8List(),
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(logoImage),
              pw.SizedBox(height: 20),
              _buildSectionTitle("I. IDENTITÉ DE L'EMPLOYEUR"),
              _buildEmployeurInfo(nomEmployeur, numAffiliation),
              pw.SizedBox(height: 20),

              _buildSectionTitle(
                "II. ÉLÉMENTS DES COTISATIONS SOCIALES DUES (Période: ${rapport.periode})",
              ),
              _buildCotisationsTable(rapport),
              pw.SizedBox(height: 20),

              _buildSectionTitle("III. FEUILLE DE PAIE"),
              _buildPaieTable(lignesDeclarees, tousLesTravailleurs),

              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  pw.Widget _buildHeader(pw.MemoryImage logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "CAISSE NATIONALE DE SÉCURITÉ SOCIALE",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text("Direction Provinciale de Kamina"),
          ],
        ),
        pw.SizedBox(height: 50, width: 50, child: pw.Image(logo)),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _buildEmployeurInfo(String nom, String affiliation) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        _buildTableRow("Dénomination ou raison sociale :", nom),
        _buildTableRow("N° d'affiliation à la CNSS :", affiliation),
      ],
    );
  }

  pw.Widget _buildCotisationsTable(RapportDeclaration rapport) {
    final format = NumberFormat("#,##0", "fr_FR");
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: const {1: pw.FlexColumnWidth(0.4)},
      children: [
        _buildTableRow(
          "Montant total brut des sommes payées :",
          "${format.format(rapport.montantTotalBrut)} FC",
        ),
        _buildTableRow(
          "Nombre de Travailleurs :",
          rapport.nombreTravailleurs.toString(),
        ),
        _buildTableRow(
          "Nombre d'Assimilés :",
          rapport.nombreAssimiles.toString(),
        ),
        _buildTableRow(
          "Branche Pensions (10%) :",
          "${format.format(rapport.cotisationPension)} FC",
        ),
        _buildTableRow(
          "Branche Risques Pro. (1.5%) :",
          "${format.format(rapport.cotisationRisquePro)} FC",
        ),
        _buildTableRow(
          "Branche Famille (6.5%) :",
          "${format.format(rapport.cotisationFamille)} FC",
        ),
        _buildTableRow(
          "TOTAL DES COTISATIONS :",
          "${format.format(rapport.totalDesCotisations)} FC",
          isHeader: true,
        ),
      ],
    );
  }

  pw.Widget _buildPaieTable(
    List<DeclarationTravailleurModele> lignes,
    List<TravailleurModele> travailleurs,
  ) {
    final format = NumberFormat("#,##0", "fr_FR");
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: const {0: pw.FlexColumnWidth(2)},
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                "Nom Complet",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                "Salaire Brut",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        ...lignes.map((ligne) {
          final travailleur = travailleurs.firstWhere(
            (t) => t.id == ligne.travailleurId,
          );
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(travailleur.nomComplet),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text("${format.format(ligne.salaireBrut)} FC"),
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.TableRow _buildTableRow(
    String label,
    String value, {
    bool isHeader = false,
  }) {
    final style =
        isHeader
            ? pw.TextStyle(fontWeight: pw.FontWeight.bold)
            : const pw.TextStyle();
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(label, style: style),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(value, style: style),
        ),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text("Fait à ____________, le ____________"),
            pw.SizedBox(height: 20),
            pw.Text("Signature de l'Employeur"),
          ],
        ),
      ],
    );
  }
}
