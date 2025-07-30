// presentations/vues/dashboard/worker_add_form.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/travailleur_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkerAddForm extends StatefulWidget {
  const WorkerAddForm({super.key});

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

  void _submit() {
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

      context
          .read<TravailleurViewModel>()
          .ajouterTravailleur(data)
          .then((_) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Travailleur ${data['nom']} ajouté !'),
                backgroundColor: kSuccessColor,
              ),
            );
          })
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Erreur: $error"),
                backgroundColor: Colors.red,
              ),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ajouter un Employé",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                onPressed: _submit,
                child: const Text('Enregistrer l\'employé'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
