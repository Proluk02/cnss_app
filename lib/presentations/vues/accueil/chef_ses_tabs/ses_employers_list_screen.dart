// lib/presentations/vues/accueil/chef_ses_tabs/ses_employers_list_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/modeles/utilisateur_modele.dart';
import 'package:cnss_app/presentations/vues/admin/tabs/user_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SesEmployersListScreen extends StatefulWidget {
  const SesEmployersListScreen({super.key});

  @override
  State<SesEmployersListScreen> createState() => _SesEmployersListScreenState();
}

class _SesEmployersListScreenState extends State<SesEmployersListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Liste des Employeurs"),
        flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: kAppBarGradient)),
      ),
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Erreur de chargement."));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Aucun employeur trouvé."));
                }

                // CORRECTION : On utilise `fromFirestore` qui utilise l'ID du document comme UID
                var employeurs = snapshot.data!.docs.map((doc) {
                  return UtilisateurModele.fromFirestore(doc);
                }).toList();

                if (_searchQuery.isNotEmpty) {
                  employeurs = employeurs.where((user) {
                    final query = _searchQuery.toLowerCase();
                    final nom = user.nom?.toLowerCase() ?? '';
                    final affiliation =
                        user.numAffiliation?.toLowerCase() ?? '';
                    return nom.contains(query) || affiliation.contains(query);
                  }).toList();
                }

                if (employeurs.isEmpty) {
                  return const Center(
                      child: Text(
                          "Aucun employeur ne correspond à votre recherche."));
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  itemCount: employeurs.length,
                  itemBuilder: (context, index) {
                    final user = employeurs[index];
                    return Card(
                      elevation: 2,
                      shadowColor: Colors.black12,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kCardRadius)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: kPrimaryColor.withOpacity(0.1),
                          foregroundColor: kPrimaryColor,
                          child: const Icon(Icons.business_center_outlined),
                        ),
                        title: Text(user.nom ?? 'N/A',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            "N° Affiliation: ${user.numAffiliation?.isNotEmpty ?? false ? user.numAffiliation! : 'Non défini'}"),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: kGreyText),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => UserDetailScreen(user: user)),
                          );
                        },
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
