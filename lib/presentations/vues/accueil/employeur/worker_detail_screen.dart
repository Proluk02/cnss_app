// lib/presentations/vues/dashboard/worker_detail_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/modeles/travailleur_modele.dart';
import 'package:flutter/material.dart';

class WorkerDetailScreen extends StatelessWidget {
  final TravailleurModele travailleur;
  const WorkerDetailScreen({super.key, required this.travailleur});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(travailleur.nomComplet),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kAppBarGradient),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Card(
            elevation: 2,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kCardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    icon: Icons.badge_outlined,
                    label: "Nom Complet",
                    value: travailleur.nomComplet,
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.pin_outlined,
                    label: "Matricule Interne",
                    value: travailleur.matricule,
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.shield_outlined,
                    label: "Immatriculation CNSS",
                    value:
                        travailleur.immatriculationCNSS.isEmpty
                            ? 'Non renseigné'
                            : travailleur.immatriculationCNSS,
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.work_outline,
                    label: "Type",
                    value:
                        travailleur.typeTravailleur == 1
                            ? "Travailleur"
                            : "Assimilé",
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.location_city_outlined,
                    label: "Commune d'Affectation",
                    value: travailleur.communeAffectation,
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.escalator_warning_outlined,
                    label: "Enfants Bénéficiaires",
                    value: travailleur.enfantsBeneficiaires.toString(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryColor),
      title: Text(label, style: kLabelStyle),
      subtitle: Text(
        value,
        style: kSubtitleStyle.copyWith(
          color: kDarkText,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
