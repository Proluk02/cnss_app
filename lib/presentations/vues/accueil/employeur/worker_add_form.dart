// lib/presentations/vues/dashboard/worker_add_form.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/modeles/travailleur_modele.dart';
import 'package:cnss_app/presentations/viewmodels/travailleur_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkerAddForm extends StatefulWidget {
  final TravailleurModele? travailleur; // Si non-null, on est en mode édition
  const WorkerAddForm({super.key, this.travailleur});

  @override
  State<WorkerAddForm> createState() => _WorkerAddFormState();
}

class _WorkerAddFormState extends State<WorkerAddForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _postNomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _immatriculationController = TextEditingController();
  final _communeController = TextEditingController();
  int _typeTravailleur = 1;

  bool get isEditing => widget.travailleur != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      // Pré-remplir les champs si on est en mode édition
      final t = widget.travailleur!;
      _nomController.text = t.nom;
      _postNomController.text = t.postNoms;
      _prenomController.text = t.prenoms;
      _matriculeController.text = t.matricule;
      _immatriculationController.text = t.immatriculationCNSS;
      _communeController.text = t.communeAffectation;
      _typeTravailleur = t.typeTravailleur;
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nom': _nomController.text.trim(),
        'postNoms': _postNomController.text.trim(),
        'prenoms': _prenomController.text.trim(),
        'matricule': _matriculeController.text.trim(),
        'immatriculationCNSS': _immatriculationController.text.trim(),
        'communeAffectation': _communeController.text.trim(),
        'typeTravailleur': _typeTravailleur,
      };

      final vm = context.read<TravailleurViewModel>();
      final action =
          isEditing
              ? vm.mettreAJourTravailleur(widget.travailleur!.id, data)
              : vm.ajouterTravailleur(data);

      try {
        await action;
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Employé ${isEditing ? 'mis à jour' : 'ajouté'} !'),
              backgroundColor: kSuccessColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$e"), backgroundColor: kErrorColor),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TravailleurViewModel>();

    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? "Modifier un Employé" : "Ajouter un Employé",
                style: kTitleStyle,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              TextFormField(
                controller: _postNomController,
                decoration: const InputDecoration(labelText: 'Post-nom(s)'),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'Prénom(s)'),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              TextFormField(
                controller: _matriculeController,
                decoration: const InputDecoration(
                  labelText: 'Matricule interne',
                ),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              TextFormField(
                controller: _immatriculationController,
                decoration: const InputDecoration(
                  labelText: 'Immatriculation CNSS',
                ),
              ),
              TextFormField(
                controller: _communeController,
                decoration: const InputDecoration(
                  labelText: 'Commune d\'affectation',
                ),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _typeTravailleur,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Travailleur')),
                  DropdownMenuItem(value: 2, child: Text('Assimilé')),
                ],
                onChanged:
                    (value) => setState(() => _typeTravailleur = value ?? 1),
                decoration: const InputDecoration(
                  labelText: 'Type de travailleur',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: vm.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child:
                    vm.isLoading
                        ? const CircularProgressIndicator()
                        : Text(isEditing ? 'Mettre à jour' : 'Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
