// lib/presentations/vues/dashboard/declaration_entry_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:cnss_app/presentations/vues/accueil/employeur/worker_declaration_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeclarationEntryScreen extends StatefulWidget {
  const DeclarationEntryScreen({super.key});

  @override
  State<DeclarationEntryScreen> createState() => _DeclarationEntryScreenState();
}

class _DeclarationEntryScreenState extends State<DeclarationEntryScreen> {
  Future<void> _onFinaliserPressed() async {
    final viewModel = context.read<DeclarationViewModel>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirmer la Finalisation'),
            content: const Text(
              'Voulez-vous vraiment finaliser et soumettre la déclaration pour cette période ? Cette action est irréversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Oui, Finaliser'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    try {
      await viewModel.finaliserDeclaration();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Déclaration finalisée avec succès !'),
            backgroundColor: kSuccessColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _onWorkerTapped(BuildContext context, String workerId) {
    final viewModel = context.read<DeclarationViewModel>();
    final travailleur = viewModel.tousLesTravailleurs.firstWhere(
      (t) => t.id == workerId,
    );
    final ligneBrouillon = viewModel.brouillonActuel[workerId]!;

    // Navigue vers le nouvel écran de formulaire dédié
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider.value(
              value: viewModel, // Fournit le même ViewModel à l'écran suivant
              child: WorkerDeclarationForm(
                travailleur: travailleur,
                ligneBrouillon: ligneBrouillon,
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeclarationViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.brouillonActuel.isEmpty) {
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
        if (viewModel.tousLesTravailleurs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(kDefaultPadding),
              child: Text(
                "Veuillez d'abord ajouter des employés dans l'onglet 'Employés'.",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Brouillon pour: ${viewModel.periodeAffichee}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        viewModel.lignesBrouillon.isEmpty || viewModel.isLoading
                            ? null
                            : _onFinaliserPressed,
                    child:
                        viewModel.isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text('Finaliser Tout'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(kDefaultPadding),
                itemCount: viewModel.lignesBrouillon.length,
                itemBuilder: (context, index) {
                  final ligne = viewModel.lignesBrouillon[index];
                  final travailleur = viewModel.tousLesTravailleurs.firstWhere(
                    (t) => t.id == ligne.travailleurId,
                  );
                  final bool isCompleted = ligne.salaireBrut > 0;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kCardRadius),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isCompleted ? Colors.green : Colors.grey.shade400,
                        child: Icon(
                          isCompleted ? Icons.check : Icons.edit_note,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        travailleur.nomComplet,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "Salaire Brut: ${ligne.salaireBrut.toStringAsFixed(0)} FC",
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _onWorkerTapped(context, travailleur.id),
                    ),
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
