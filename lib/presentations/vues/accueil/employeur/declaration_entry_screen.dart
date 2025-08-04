// lib/presentations/vues/dashboard/declaration_entry_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/modeles/declaration_modele.dart';
import 'package:cnss_app/donnees/modeles/travailleur_modele.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeclarationEntryScreen extends StatefulWidget {
  final String? highlightedWorkerId;
  const DeclarationEntryScreen({super.key, this.highlightedWorkerId});

  @override
  State<DeclarationEntryScreen> createState() => _DeclarationEntryScreenState();
}

class _DeclarationEntryScreenState extends State<DeclarationEntryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.highlightedWorkerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToWorker(widget.highlightedWorkerId!);
      });
    }
  }

  void _scrollToWorker(String workerId) {
    final viewModel = context.read<DeclarationViewModel>();
    final index = viewModel.lignesBrouillon.indexWhere(
      (ligne) => ligne.travailleurId == workerId,
    );
    if (index != -1 && _scrollController.hasClients) {
      final itemHeight = 150.0;
      _scrollController.animateTo(
        index * itemHeight,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onFinaliserPressed() async {
    final viewModel = context.read<DeclarationViewModel>();
    final isCorrectionMode =
        viewModel.declarationsRecentes.isNotEmpty &&
        viewModel.declarationsRecentes.first.statut ==
            StatutDeclaration.REJETEE;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              isCorrectionMode
                  ? 'Confirmer la Resoumission'
                  : 'Confirmer la Finalisation',
            ),
            content: const Text(
              'Voulez-vous vraiment soumettre cette déclaration ? Cette action est irréversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Oui, Soumettre'),
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
            content: Text('Déclaration soumise avec succès !'),
            backgroundColor: kSuccessColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: kErrorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeclarationViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.brouillonActuel.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.erreurMessage != null) {
          return Center(child: Text("Erreur: ${viewModel.erreurMessage}"));
        }
        if (viewModel.tousLesTravailleurs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(kDefaultPadding),
              child: Text(
                "Veuillez d'abord ajouter des employés.",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final bool isEditable = viewModel.isBrouillonEditable;
        final bool isCorrectionMode =
            viewModel.declarationsRecentes.isNotEmpty &&
            viewModel.declarationsRecentes.first.statut ==
                StatutDeclaration.REJETEE;
        final bool isPending = !isEditable && !isCorrectionMode;

        return Column(
          children: [
            if (isCorrectionMode)
              _buildInfoBanner(
                "Déclaration Rejetée",
                "Veuillez corriger les informations ci-dessous et soumettre à nouveau.",
                kErrorColor,
              )
            else if (isPending)
              _buildInfoBanner(
                "Déclaration en Attente",
                "Cette déclaration a été soumise et est en attente de validation. Elle n'est plus modifiable.",
                kWarningColor,
              ),

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
                        viewModel.lignesBrouillon.isEmpty ||
                                viewModel.isLoading ||
                                !isEditable
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
                            : Text(
                              isCorrectionMode
                                  ? 'Soumettre à Nouveau'
                                  : 'Finaliser Tout',
                            ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(kDefaultPadding),
                itemCount: viewModel.lignesBrouillon.length,
                itemBuilder: (context, index) {
                  final ligne = viewModel.lignesBrouillon[index];
                  final travailleur = viewModel.tousLesTravailleurs.firstWhere(
                    (t) => t.id == ligne.travailleurId,
                    orElse: () => TravailleurModele.empty(),
                  );
                  final isHighlighted =
                      ligne.travailleurId == widget.highlightedWorkerId;

                  return _DeclarationRowItem(
                    key: ValueKey(ligne.id),
                    travailleurNom: travailleur.nomComplet,
                    ligneBrouillon: ligne,
                    isHighlighted: isHighlighted,
                    isEnabled: isEditable,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoBanner(String title, String message, Color color) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DeclarationRowItem extends StatefulWidget {
  final String travailleurNom;
  final DeclarationTravailleurModele ligneBrouillon;
  final bool isHighlighted;
  final bool isEnabled;

  const _DeclarationRowItem({
    super.key,
    required this.travailleurNom,
    required this.ligneBrouillon,
    this.isHighlighted = false,
    required this.isEnabled,
  });

  @override
  State<_DeclarationRowItem> createState() => _DeclarationRowItemState();
}

class _DeclarationRowItemState extends State<_DeclarationRowItem> {
  late final TextEditingController _salaireController;
  late final TextEditingController _heuresController;

  @override
  void initState() {
    super.initState();
    _salaireController = TextEditingController(
      text: widget.ligneBrouillon.salaireBrut.toStringAsFixed(0),
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
      color: widget.isHighlighted ? Colors.blue[50] : null,
      elevation: widget.isHighlighted ? 4 : 1,
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
                    enabled: widget.isEnabled,
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
                    enabled: widget.isEnabled,
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
