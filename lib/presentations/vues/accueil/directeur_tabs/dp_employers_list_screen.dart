// lib/presentations/vues/accueil/directeur_tabs/dp_employers_list_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/modeles/utilisateur_modele.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DpEmployersListScreen extends StatefulWidget {
  const DpEmployersListScreen({super.key});
  @override
  State<DpEmployersListScreen> createState() => _DpEmployersListScreenState();
}

class _DpEmployersListScreenState extends State<DpEmployersListScreen> {
  String _searchQuery = '';

  void _showEmployerDetails(BuildContext context, UtilisateurModele user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(kCardRadius))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.nom ?? 'Détails de l\'employeur', style: kTitleStyle),
            const SizedBox(height: 8),
            Text(user.email ?? 'Email non disponible', style: kLabelStyle),
            const Divider(height: 24),
            _buildDetailRow(context,
                icon: Icons.shield_outlined,
                label: "Rôle",
                value: user.role ?? 'N/A'),
            _buildDetailRow(context,
                icon: Icons.confirmation_number_outlined,
                label: "Numéro d'Affiliation",
                value: user.numAffiliation?.isNotEmpty ?? false
                    ? user.numAffiliation!
                    : 'Non renseigné'),
            _buildDetailRow(context,
                icon: Icons.fingerprint,
                label: "UID",
                value: user.uid,
                isCopiable: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      bool isCopiable = false}) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryColor.withOpacity(0.8)),
      title: Text(label, style: kLabelStyle),
      subtitle: Text(value,
          style: kSubtitleStyle.copyWith(
              color: kDarkText, fontSize: 16, fontWeight: FontWeight.w600)),
      trailing: isCopiable
          ? IconButton(
              icon: const Icon(Icons.copy_outlined, size: 20),
              tooltip: "Copier",
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Copié dans le presse-papiers")));
              },
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                hintText: "Rechercher par nom ou N° affiliation...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(kButtonRadius))),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('utilisateurs')
                  .where('role', isEqualTo: 'employeur')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return const Center(child: Text("Aucun employeur trouvé."));

                var employeurs = snapshot.data!.docs
                    .map((doc) => UtilisateurModele.fromFirestore(doc))
                    .toList();
                if (_searchQuery.isNotEmpty) {
                  employeurs = employeurs.where((user) {
                    final query = _searchQuery.toLowerCase();
                    final nom = user.nom?.toLowerCase() ?? '';
                    final affiliation =
                        user.numAffiliation?.toLowerCase() ?? '';
                    return nom.contains(query) || affiliation.contains(query);
                  }).toList();
                }
                if (employeurs.isEmpty)
                  return const Center(
                      child: Text(
                          "Aucun employeur ne correspond à votre recherche."));

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  itemCount: employeurs.length,
                  itemBuilder: (context, index) {
                    final user = employeurs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kCardRadius)),
                      child: ListTile(
                        leading: const CircleAvatar(
                            child: Icon(Icons.business_center_outlined)),
                        title: Text(user.nom ?? 'N/A',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            "N° Affiliation: ${user.numAffiliation?.isNotEmpty ?? false ? user.numAffiliation! : 'Non défini'}"),
                        trailing:
                            const Icon(Icons.info_outline, color: kGreyText),
                        onTap: () => _showEmployerDetails(context, user),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
