// lib/presentations/vues/accueil/prepose_tabs/prepose_search_tab.dart
// (Assurez-vous que ce fichier est bien appelé par `prepose_dashboard.dart`)

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/modeles/utilisateur_modele.dart';
import 'package:cnss_app/presentations/viewmodels/prepose_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'fiche_compte_screen.dart';

class PreposeSearchTab extends StatefulWidget {
  const PreposeSearchTab({super.key});

  @override
  State<PreposeSearchTab> createState() => _PreposeSearchTabState();
}

class _PreposeSearchTabState extends State<PreposeSearchTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<PreposeViewModel>(
      builder: (context, viewModel, child) {
        final List<UtilisateurModele> filteredList;
        if (_searchQuery.isEmpty) {
          filteredList = viewModel.tousLesEmployeurs;
        } else {
          filteredList = viewModel.tousLesEmployeurs.where((user) {
            final query = _searchQuery.toLowerCase();
            final nom = user.nom?.toLowerCase() ?? '';
            final affiliation = user.numAffiliation?.toLowerCase() ?? '';
            return nom.contains(query) || affiliation.contains(query);
          }).toList();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: const InputDecoration(
                  hintText: "Rechercher un employeur...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(kButtonRadius))),
                ),
              ),
            ),
            Expanded(
              child: _buildResults(context, viewModel, filteredList),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResults(BuildContext context, PreposeViewModel viewModel,
      List<UtilisateurModele> employeurs) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }
    if (viewModel.tousLesEmployeurs.isEmpty) {
      return const Center(
          child: Text("Aucun employeur n'a été trouvé dans le système."));
    }
    if (employeurs.isEmpty && _searchQuery.isNotEmpty) {
      return const Center(
          child: Text("Aucun employeur ne correspond à votre recherche."));
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.chargerTousLesEmployeurs(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
        itemCount: employeurs.length,
        itemBuilder: (context, index) {
          final user = employeurs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kCardRadius)),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.business_center)),
              title: Text(user.nom ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  "N° Affiliation: ${user.numAffiliation?.isNotEmpty ?? false ? user.numAffiliation! : 'N/A'}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                              value:
                                  viewModel, // On passe le ViewModel existant
                              child: FicheCompteScreen(employeur: user),
                            )));
              },
            ),
          );
        },
      ),
    );
  }
}
