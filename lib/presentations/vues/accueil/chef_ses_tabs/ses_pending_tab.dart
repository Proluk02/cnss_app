// lib/presentations/vues/accueil/chef_ses_tabs/ses_pending_tab.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/chef_ses_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SesPendingTab extends StatelessWidget {
  const SesPendingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChefSesViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.errorMessage != null) {
          return Center(child: Text("Erreur: ${viewModel.errorMessage}"));
        }
        if (viewModel.declarations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Boîte de réception vide",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Aucune déclaration n'est en attente de validation pour le moment.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kGreyText),
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            // Le stream se met à jour automatiquement, cette action donne un retour visuel.
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(kDefaultPadding),
            itemCount: viewModel.declarations.length,
            itemBuilder: (context, index) {
              final declaration = viewModel.declarations[index];
              return _DeclarationCard(declaration: declaration);
            },
          ),
        );
      },
    );
  }
}

class _DeclarationCard extends StatelessWidget {
  final DeclarationEnAttente declaration;
  const _DeclarationCard({required this.declaration});

  void _showRejectionDialog(BuildContext context) {
    final vm = context.read<ChefSesViewModel>();
    final motifController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Motif du Rejet"),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: motifController,
                decoration: const InputDecoration(
                  hintText: "Expliquez pourquoi la déclaration est rejetée...",
                ),
                maxLines: 3,
                validator:
                    (value) =>
                        value!.trim().isEmpty ? 'Le motif est requis.' : null,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Annuler"),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    vm.rejeterDeclaration(
                      declaration,
                      motifController.text.trim(),
                    );
                    Navigator.of(ctx).pop(); // Ferme le dialogue de rejet
                    Navigator.of(context).pop(); // Ferme le bottom sheet
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: kErrorColor),
                child: const Text("Confirmer le Rejet"),
              ),
            ],
          ),
    );
  }

  void _showActions(BuildContext context) {
    final vm = context.read<ChefSesViewModel>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kCardRadius)),
      ),
      builder:
          (ctx) => Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Actions pour ${declaration.rapport.periode}",
                  style: kTitleStyle,
                ),
                Text(
                  "Employeur: ${declaration.employeurNom}",
                  style: kSubtitleStyle.copyWith(color: kGreyText),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: const Text("Voir les détails"),
                  onTap: () {
                    // TODO: Implémenter la vue de détail pour le Chef SES.
                    // Cela nécessitera de passer plus de données ou de faire une nouvelle requête.
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fonctionnalité à venir.")),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: kSuccessColor,
                  ),
                  title: const Text("Valider la déclaration"),
                  onTap: () {
                    vm.validerDeclaration(declaration);
                    Navigator.of(ctx).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.cancel_outlined,
                    color: kErrorColor,
                  ),
                  title: const Text("Rejeter la déclaration"),
                  onTap: () => _showRejectionDialog(context),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat("#,##0", "fr_FR");
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: InkWell(
        onTap: () => _showActions(context),
        borderRadius: BorderRadius.circular(kCardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                declaration.employeurNom,
                style: kTitleStyle.copyWith(fontSize: 18),
              ),
              Text(
                "Période à valider : ${declaration.rapport.periode}",
                style: kLabelStyle,
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Montant à cotiser"),
                  Text(
                    "${format.format(declaration.rapport.totalDesCotisations)} FC",
                    style: kSubtitleStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Nombre d'employés"),
                  Text(
                    declaration.rapport.nombreTravailleurs.toString(),
                    style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
