// lib/presentations/vues/dashboard/declaration_detail_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/modeles/declaration_modele.dart';
import 'package:cnss_app/donnees/modeles/travailleur_modele.dart';
import 'package:cnss_app/donnees/pdf_service.dart';
import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/travailleur_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeclarationDetailScreen extends StatefulWidget {
  final RapportDeclaration rapport;
  final DeclarationViewModel declarationVM;
  final TravailleurViewModel travailleurVM;

  const DeclarationDetailScreen({
    super.key,
    required this.rapport,
    required this.declarationVM,
    required this.travailleurVM,
  });

  @override
  State<DeclarationDetailScreen> createState() =>
      _DeclarationDetailScreenState();
}

class _DeclarationDetailScreenState extends State<DeclarationDetailScreen> {
  bool _isPrinting = false;
  List<DeclarationTravailleurModele>? _lignesArchivees;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _chargerLignesArchivees();
  }

  Future<void> _chargerLignesArchivees() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final data = await FirebaseService().getFeuilleDePaieArchivee(
        uid,
        widget.rapport.periode,
      );
      if (mounted) {
        setState(() {
          _lignesArchivees =
              data.map((d) => DeclarationTravailleurModele.fromMap(d)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _loadingError = "Impossible de charger le détail de la paie.",
        );
      }
    }
  }

  Future<void> _handlePrint() async {
    setState(() => _isPrinting = true);

    if (_lignesArchivees != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      await PdfService().imprimerDeclaration(
        rapport: widget.rapport,
        nomEmployeur: currentUser?.displayName ?? "Employeur",
        numAffiliation: "N/A", // TODO: A récupérer du profil
        lignesDeclarees: _lignesArchivees!,
        tousLesTravailleurs: widget.travailleurVM.travailleurs,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_loadingError ?? "Détails de paie non disponibles."),
        ),
      );
    }

    if (mounted) {
      setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text('Détails - ${widget.rapport.periode}'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kAppBarGradient),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          _loadingError != null
              ? Center(child: Text(_loadingError!))
              : _lignesArchivees == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusCard(widget.rapport.statut),
                    const SizedBox(height: 24),
                    _SummaryCard(
                      title: "Résumé des Cotisations",
                      icon: Icons.receipt_long_outlined,
                      children: [
                        _buildDetailRow(
                          "Montant Brut Total :",
                          widget.rapport.montantTotalBrut,
                        ),
                        const Divider(height: 20),
                        _buildDetailRow(
                          "Branche Pensions (10%) :",
                          widget.rapport.cotisationPension,
                          isSubtle: true,
                        ),
                        _buildDetailRow(
                          "Branche Risques Pro. (1.5%) :",
                          widget.rapport.cotisationRisquePro,
                          isSubtle: true,
                        ),
                        _buildDetailRow(
                          "Branche Famille (6.5%) :",
                          widget.rapport.cotisationFamille,
                          isSubtle: true,
                        ),
                        const Divider(thickness: 1.5, height: 20),
                        _buildDetailRow(
                          "TOTAL DES COTISATIONS :",
                          widget.rapport.totalDesCotisations,
                          isTotal: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SummaryCard(
                      title: "Détails sur les Employés",
                      icon: Icons.people_outline,
                      children: [
                        _buildDetailRow(
                          "Nombre de Travailleurs :",
                          widget.rapport.nombreTravailleurs.toDouble(),
                          isNumeric: false,
                        ),
                        _buildDetailRow(
                          "Nombre d'Assimilés :",
                          widget.rapport.nombreAssimiles.toDouble(),
                          isNumeric: false,
                        ),
                        _buildDetailRow(
                          "Montant Revenus Assimilés :",
                          widget.rapport.montantRev,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (widget.rapport.statut == StatutDeclaration.REJETEE)
                      _RejectionCard("Le montant total brut semble incorrect."),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            (_isPrinting || _lignesArchivees == null) ? null : _handlePrint,
        label:
            _isPrinting ? const Text("Génération...") : const Text("Imprimer"),
        icon:
            _isPrinting
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Icon(Icons.print_outlined),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// Les widgets enfants sont inclus ici pour la complétude.

class _SummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.children,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: kPrimaryColor),
                const SizedBox(width: 8),
                Text(title, style: kTitleStyle.copyWith(fontSize: 18)),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

Widget _buildDetailRow(
  String label,
  double value, {
  bool isSubtle = false,
  bool isTotal = false,
  bool isNumeric = true,
}) {
  final format = NumberFormat("#,##0", "fr_FR");
  final String formattedValue =
      isNumeric ? "${format.format(value)} FC" : value.toInt().toString();
  final valueStyle = TextStyle(
    fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
    fontSize: isTotal ? 18 : 16,
    color: isTotal ? kPrimaryColor : kDarkText,
  );
  final labelStyle = TextStyle(
    color: isSubtle ? kGreyText : Colors.black54,
    fontSize: 15,
  );
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(formattedValue, style: valueStyle),
      ],
    ),
  );
}

class _StatusCard extends StatelessWidget {
  final StatutDeclaration status;
  const _StatusCard(this.status);
  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;
    IconData icon;
    Color color;
    switch (status) {
      case StatutDeclaration.EN_ATTENTE:
        title = "En attente de traitement";
        subtitle =
            "Votre déclaration est en cours de vérification par la CNSS.";
        icon = Icons.hourglass_top_rounded;
        color = kWarningColor;
        break;
      case StatutDeclaration.VALIDEE:
        title = "Déclaration Validée";
        subtitle = "Cette déclaration a été traitée et validée avec succès.";
        icon = Icons.check_circle;
        color = kSuccessColor;
        break;
      case StatutDeclaration.REJETEE:
        title = "Déclaration Rejetée";
        subtitle = "Un problème a été détecté. Voir le motif ci-dessous.";
        icon = Icons.cancel;
        color = kErrorColor;
        break;
      default:
        title = "Statut Inconnu";
        subtitle = "Le statut de cette déclaration n'a pas pu être déterminé.";
        icon = Icons.help_outline;
        color = Colors.grey;
        break;
    }
    return Card(
      elevation: 4,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
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

class _RejectionCard extends StatelessWidget {
  final String reason;
  const _RejectionCard(this.reason);
  @override
  Widget build(BuildContext context) {
    return Card(
      color: kErrorColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
        side: BorderSide(color: kErrorColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: kErrorColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Motif du Rejet",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kErrorColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(reason, style: const TextStyle(height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Assurez-vous que le modèle Travailleur a bien une factory `empty()`
extension EmptyTravailleur on TravailleurModele {
  static TravailleurModele empty() => TravailleurModele(
    id: '',
    matricule: '',
    immatriculationCNSS: '',
    nom: 'Introuvable',
    postNoms: '',
    prenoms: '',
    typeTravailleur: 1,
    communeAffectation: '',
    enfantsBeneficiaires: 0,
    lastModified: DateTime.now(),
  );
}
