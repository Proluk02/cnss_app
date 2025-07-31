// lib/presentations/vues/dashboard/help_screen.dart

import 'package:flutter/material.dart';
import 'package:cnss_app/core/constantes.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: const [
          Text(
            "Foire Aux Questions",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _HelpItem(
            question: "Comment ajouter un nouvel employé ?",
            answer:
                "Allez dans l'onglet 'Employés' et cliquez sur le bouton flottant '+' en bas à droite. Remplissez tous les champs du formulaire et cliquez sur 'Enregistrer'. L'employé sera ajouté à votre liste et synchronisé avec le serveur.",
            icon: Icons.person_add_alt_1,
          ),
          _HelpItem(
            question: "Comment faire une déclaration ?",
            answer:
                "Allez dans l'onglet 'Déclarer'. La période en cours s'affichera. Pour chaque employé de la liste, entrez le salaire brut et/ou les heures travaillées. Vos modifications sont sauvegardées automatiquement en tant que brouillon.",
            icon: Icons.note_add_outlined,
          ),
          _HelpItem(
            question: "Comment finaliser une déclaration ?",
            answer:
                "Une fois que vous avez rempli toutes les informations pour la période dans l'onglet 'Déclarer', cliquez sur le bouton 'Finaliser' en haut de l'écran. Confirmez votre choix pour soumettre la déclaration à la CNSS.",
            icon: Icons.playlist_add_check_circle_outlined,
          ),
          _HelpItem(
            question: "Que signifie le statut 'En attente' ?",
            answer:
                "Ce statut indique que votre déclaration a été soumise avec succès à la CNSS. Elle est maintenant en cours de traitement par nos agents. Vous recevrez une notification lorsque son statut changera (Validée ou Rejetée).",
            icon: Icons.hourglass_top_rounded,
          ),
          _HelpItem(
            question: "Où puis-je voir mes anciennes déclarations ?",
            answer:
                "Toutes vos déclarations finalisées sont disponibles dans l'onglet 'Historique'. Vous pouvez y consulter les détails de chaque période.",
            icon: Icons.history_outlined,
          ),
          _HelpItem(
            question: "Que faire si ma déclaration est 'Rejetée' ?",
            answer:
                "Une déclaration rejetée sera accompagnée d'un motif de rejet visible dans ses détails. Vous devrez la corriger et la soumettre à nouveau. Contactez votre centre de gestion pour plus d'informations.",
            icon: Icons.cancel_outlined,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(color: Colors.black54, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
