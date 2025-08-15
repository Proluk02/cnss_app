// lib/presentations/vues/accueil/prepose_tabs/prepose_search_tab.dart

import 'package:cnss_app/core/constantes.dart';
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
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PreposeViewModel>();

    // Le PreposeViewModel doit être disponible pour être passé à la route suivante
    final preposeVMProvider = context.read<PreposeViewModel>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              // On appelle la méthode de recherche du ViewModel
              viewModel.rechercherEmployeurs(value);
            },
            decoration: const InputDecoration(
              hintText: "Rechercher un employeur...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(kButtonRadius)),
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildResults(viewModel, preposeVMProvider),
        ),
      ],
    );
  }

  Widget _buildResults(
      PreposeViewModel viewModel, PreposeViewModel preposeVMProvider) {
    if (viewModel.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.searchErrorMessage != null) {
      return Center(
        child: Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Text(viewModel.searchErrorMessage!,
                textAlign: TextAlign.center)),
      );
    }
    if (_searchController.text.length < 3) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: kGreyText),
              SizedBox(height: 16),
              Text("Entrez au moins 3 caractères pour lancer la recherche.",
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    if (viewModel.searchResults.isEmpty) {
      return const Center(
          child: Text("Aucun employeur trouvé pour cette recherche."));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      itemCount: viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final user = viewModel.searchResults[index];
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
              // Si la page peut retourner une valeur (cas de la sélection pour un rapport)
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop(user);
              } else {
                // Sinon, on navigue vers la fiche de compte (cas de l'onglet du Préposé)
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                              value: preposeVMProvider,
                              child: FicheCompteScreen(employeur: user),
                            )));
              }
            },
          ),
        );
      },
    );
  }
}
