// presentations/vues/dashboard/workers_list.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/travailleur_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkersList extends StatelessWidget {
  const WorkersList({super.key});

  @override
  Widget build(BuildContext context) {
    // Utiliser Consumer pour reconstruire l'UI quand les données changent
    return Consumer<TravailleurViewModel>(
      builder: (context, viewModel, child) {
        // Afficher un indicateur de chargement
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Afficher un message si la liste est vide
        if (viewModel.travailleurs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(kDefaultPadding),
              child: Text(
                "Aucun travailleur enregistré. Cliquez sur le bouton '+' pour en ajouter un.",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Afficher la liste des travailleurs
        return ListView.builder(
          padding: const EdgeInsets.all(kDefaultPadding),
          itemCount: viewModel.travailleurs.length,
          itemBuilder: (context, index) {
            final t = viewModel.travailleurs[index];
            final bool isSynced = t.syncStatus == 'synced';
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kCardRadius),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSynced ? Colors.green : Colors.orange,
                  child: Icon(
                    isSynced
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_upload_outlined,
                    color: Colors.white,
                  ),
                ),
                title: Text(t.nomComplet),
                subtitle: Text(
                  'Matricule: ${t.matricule} | CNSS: ${t.immatriculationCNSS}',
                ),
                trailing: Text(
                  t.typeTravailleur == 1 ? 'Travailleur' : 'Assimilé',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  // TODO: Naviguer vers un écran de détails/modification du travailleur
                },
              ),
            );
          },
        );
      },
    );
  }
}
