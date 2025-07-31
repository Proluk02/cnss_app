// lib/presentations/vues/dashboard/help_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // En-tête de la page avec une image et un titre
          const SliverAppBar(
            backgroundColor: kBackgroundColor,
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Aide & Support",
                style: TextStyle(color: kDarkText, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              background: Icon(
                Icons.support_agent_outlined,
                size: 100,
                color: kPrimaryColor,
              ),
            ),
          ),

          // Liste des questions
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  kDefaultPadding,
                  kDefaultPadding,
                  kDefaultPadding,
                  8,
                ),
                child: Text("Foire Aux Questions", style: kTitleStyle),
              ),
              const _HelpItem(
                question: "Comment ajouter un nouvel employé ?",
                answer:
                    "Allez dans l'onglet 'Employés' et cliquez sur le bouton '+' en haut à droite. Remplissez tous les champs du formulaire et cliquez sur 'Enregistrer'.",
                icon: Icons.person_add_alt_1,
              ),
              const _HelpItem(
                question: "Comment faire une déclaration ?",
                answer:
                    "Allez dans l'onglet 'Déclarer'. La période en cours s'affichera. Pour chaque employé, entrez le salaire brut et/ou les heures travaillées. Vos modifications sont sauvegardées automatiquement.",
                icon: Icons.note_add_outlined,
              ),
              const _HelpItem(
                question: "Comment finaliser une déclaration ?",
                answer:
                    "Une fois toutes les informations remplies dans l'onglet 'Déclarer', cliquez sur le bouton 'Finaliser' en haut de l'écran. Confirmez votre choix pour soumettre la déclaration à la CNSS.",
                icon: Icons.playlist_add_check_circle_outlined,
              ),
              const _HelpItem(
                question: "Que signifie le statut 'En attente' ?",
                answer:
                    "Ce statut indique que votre déclaration a été soumise avec succès et est en cours de traitement par la CNSS. Vous serez notifié lorsque son statut changera (Validée ou Rejetée).",
                icon: Icons.hourglass_top_rounded,
              ),
              const _HelpItem(
                question: "Où voir mes anciennes déclarations ?",
                answer:
                    "Toutes vos déclarations finalisées sont disponibles dans l'onglet 'Historique'. Vous pouvez y consulter les détails et imprimer le récépissé de chaque période.",
                icon: Icons.history_outlined,
              ),
              const _HelpItem(
                question: "Que faire si ma déclaration est 'Rejetée' ?",
                answer:
                    "Une déclaration rejetée sera accompagnée d'un motif de rejet visible dans ses détails. Contactez votre centre de gestion pour plus d'informations sur les démarches à suivre.",
                icon: Icons.cancel_outlined,
              ),
              const SizedBox(height: 40), // Espace avant le footer
            ]),
          ),

          // Footer avec vos informations
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                children: [
                  const Text(
                    "Developed by",
                    style: TextStyle(color: kGreyText, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Prosper Lukeka",
                    style: kSubtitleStyle.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "prolukeka@gmail.com",
                    style: TextStyle(color: kGreyText, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String question;
  final String answer;
  final IconData icon;

  const _HelpItem({
    required this.question,
    required this.answer,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius),
        ),
        child: ExpansionTile(
          leading: Icon(icon, color: kPrimaryColor),
          title: Text(question, style: kSubtitleStyle.copyWith(fontSize: 16)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(
              answer,
              style: kLabelStyle.copyWith(height: 1.5, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
