// presentations/vues/dashboard/declaration_entry_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/modeles/declaration_modele.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeclarationEntryScreen extends StatelessWidget {
  const DeclarationEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeclarationViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.erreurMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Text(
                "Erreur: ${viewModel.erreurMessage}",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Column(
          children: [
            // Entête avec la période et le bouton de finalisation
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Période: ${viewModel.periodeAffichee}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Logique de confirmation avant de finaliser
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('Confirmer la Finalisation'),
                              content: const Text(
                                'Voulez-vous vraiment finaliser et soumettre cette déclaration ? Cette action est irréversible.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Annuler'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Finaliser'),
                                ),
                              ],
                            ),
                      );
                      if (confirmed == true) {
                        viewModel.finaliserDeclaration().catchError((e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        });
                      }
                    },
                    child: const Text('Finaliser'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Liste des travailleurs à déclarer
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(kDefaultPadding),
                itemCount: viewModel.lignesBrouillon.length,
                itemBuilder: (context, index) {
                  final ligne = viewModel.lignesBrouillon[index];
                  // Trouver le nom du travailleur correspondant
                  final travailleur = viewModel.tousLesTravailleurs.firstWhere(
                    (t) => t.id == ligne.travailleurId,
                  );
                  return DeclarationRowItem(
                    key: ValueKey(
                      ligne.id,
                    ), // Important pour que Flutter gère bien la liste
                    travailleurNom: travailleur.nomComplet,
                    ligneBrouillon: ligne,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// Widget pour une seule ligne de déclaration (un travailleur)
class DeclarationRowItem extends StatefulWidget {
  final String travailleurNom;
  final DeclarationTravailleurModele ligneBrouillon;

  const DeclarationRowItem({
    super.key,
    required this.travailleurNom,
    required this.ligneBrouillon,
  });

  @override
  State<DeclarationRowItem> createState() => _DeclarationRowItemState();
}

class _DeclarationRowItemState extends State<DeclarationRowItem> {
  late final TextEditingController _salaireController;
  late final TextEditingController _heuresController;

  @override
  void initState() {
    super.initState();
    _salaireController = TextEditingController(
      text: widget.ligneBrouillon.salaireBrut.toString(),
    );
    _heuresController = TextEditingController(
      text: widget.ligneBrouillon.heuresTravail.toString(),
    );
  }

  @override
  void dispose() {
    _salaireController.dispose();
    _heuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.travailleurNom,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _salaireController,
                    decoration: const InputDecoration(
                      labelText: 'Salaire Brut',
                      prefixIcon: Icon(Icons.money),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final salaire = double.tryParse(value) ?? 0.0;
                      context.read<DeclarationViewModel>().updateLigneBrouillon(
                        travailleurId: widget.ligneBrouillon.travailleurId,
                        salaireBrut: salaire,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _heuresController,
                    decoration: const InputDecoration(
                      labelText: 'Heures Trav.',
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final heures = int.tryParse(value) ?? 0;
                      context.read<DeclarationViewModel>().updateLigneBrouillon(
                        travailleurId: widget.ligneBrouillon.travailleurId,
                        heuresTravail: heures,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
