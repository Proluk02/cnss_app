// lib/presentations/vues/dashboard/workers_list.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/modeles/travailleur_modele.dart';
import 'package:cnss_app/presentations/viewmodels/travailleur_viewmodel.dart';
import 'package:cnss_app/presentations/vues/accueil/employeur/worker_add_form.dart';
import 'package:cnss_app/presentations/vues/accueil/employeur/worker_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkersList extends StatelessWidget {
  const WorkersList({super.key});

  void _showWorkerForm(BuildContext context, {TravailleurModele? travailleur}) {
    final travailleurVM = context.read<TravailleurViewModel>();
    showDialog(
      context: context,
      builder:
          (dialogContext) => ChangeNotifierProvider.value(
            value: travailleurVM,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kCardRadius),
              ),
              child: WorkerAddForm(travailleur: travailleur),
            ),
          ),
    );
  }

  void _confirmDelete(BuildContext context, TravailleurModele travailleur) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Confirmer la Suppression"),
            content: Text(
              "Voulez-vous vraiment supprimer l'employé ${travailleur.nomComplet} ?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Annuler"),
              ),
              FilledButton(
                onPressed: () {
                  context.read<TravailleurViewModel>().supprimerTravailleur(
                    travailleur.id,
                  );
                  Navigator.of(ctx).pop();
                },
                style: FilledButton.styleFrom(backgroundColor: kErrorColor),
                child: const Text("Supprimer"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Consumer<TravailleurViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.travailleurs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.errorMessage != null) {
            return Center(child: Text("Erreur: ${viewModel.errorMessage}"));
          }
          if (viewModel.travailleurs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Aucun employé enregistré",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Cliquez sur le bouton '+' pour ajouter votre premier employé.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kGreyText),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.chargerTravailleurs(),
            child: ListView(
              padding: const EdgeInsets.all(kDefaultPadding),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Mes Employés (${viewModel.travailleurs.length})",
                      style: kTitleStyle,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.person_add_alt_1_outlined),
                          color: kPrimaryColor,
                          tooltip: "Ajouter un employé",
                          onPressed: () => _showWorkerForm(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.print_outlined),
                          color: kPrimaryColor,
                          tooltip: "Imprimer la liste",
                          onPressed:
                              () => viewModel.imprimerListeTravailleurs(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...viewModel.travailleurs.map(
                  (t) => Card(
                    elevation: 2,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kCardRadius),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: kPrimaryColor.withOpacity(0.1),
                        foregroundColor: kPrimaryColor,
                        child: Text(
                          t.nom.isNotEmpty ? t.nom[0].toUpperCase() : '?',
                        ),
                      ),
                      title: Text(
                        t.nomComplet,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Matricule: ${t.matricule}'),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => WorkerDetailScreen(travailleur: t),
                            ),
                          ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: kGreyText,
                            ),
                            onPressed:
                                () => _showWorkerForm(context, travailleur: t),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: kErrorColor,
                            ),
                            onPressed: () => _confirmDelete(context, t),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
