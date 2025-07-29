import 'package:flutter/material.dart';
import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/modeles/travailleur.dart';

class WorkerAddForm extends StatefulWidget {
  final Function(Travailleur) onWorkerAdded;

  const WorkerAddForm({super.key, required this.onWorkerAdded});

  @override
  State<WorkerAddForm> createState() => _WorkerAddFormState();
}

class _WorkerAddFormState extends State<WorkerAddForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _matriculeController = TextEditingController();
  final TextEditingController _immatriculationController =
      TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _postNomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _communeController = TextEditingController();

  int _typeTravailleur = 1;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final travailleur = Travailleur(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        matricule: _matriculeController.text.trim(),
        immatriculationCNSS: _immatriculationController.text.trim(),
        nom: _nomController.text.trim(),
        postNoms: _postNomController.text.trim(),
        prenoms: _prenomController.text.trim(),
        communeAffectation: _communeController.text.trim(),
        typeTravailleur: _typeTravailleur,
      );
      widget.onWorkerAdded(travailleur);
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
            children: [
              TextFormField(
                controller: _matriculeController,
                decoration: const InputDecoration(labelText: 'Matricule'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _immatriculationController,
                decoration: const InputDecoration(
                  labelText: 'Immatriculation CNSS',
                ),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _postNomController,
                decoration: const InputDecoration(labelText: 'Post-noms'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'Prénoms'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _communeController,
                decoration: const InputDecoration(
                  labelText: 'Commune d\'affectation',
                ),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _typeTravailleur,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Travailleur')),
                  DropdownMenuItem(value: 2, child: Text('Assimilé')),
                ],
                onChanged: (value) {
                  setState(() {
                    _typeTravailleur = value ?? 1;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Type de travailleur',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _submit, child: const Text('Ajouter')),
            ],
          ),
        ),
      ),
    );
  }
}
