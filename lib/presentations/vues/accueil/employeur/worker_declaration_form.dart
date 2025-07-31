// lib/presentations/vues/dashboard/worker_declaration_form.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/modeles/declaration_modele.dart';
import 'package:cnss_app/donnees/modeles/travailleur_modele.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkerDeclarationForm extends StatefulWidget {
  final TravailleurModele travailleur;
  final DeclarationTravailleurModele ligneBrouillon;

  const WorkerDeclarationForm({
    super.key,
    required this.travailleur,
    required this.ligneBrouillon,
  });

  @override
  State<WorkerDeclarationForm> createState() => _WorkerDeclarationFormState();
}

class _WorkerDeclarationFormState extends State<WorkerDeclarationForm> {
  final _formKey = GlobalKey<FormState>();
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

  void _save() {
    if (_formKey.currentState!.validate()) {
      final salaire = double.tryParse(_salaireController.text.trim()) ?? 0.0;
      final heures = int.tryParse(_heuresController.text.trim()) ?? 0;

      // On met à jour le ViewModel avec les nouvelles valeurs
      context.read<DeclarationViewModel>().updateLigneBrouillon(
        travailleurId: widget.travailleur.id,
        salaireBrut: salaire,
        heuresTravail: heures,
      );

      // On ferme l'écran
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _salaireController.dispose();
    _heuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.travailleur.nomComplet),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kAppBarGradient),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Déclaration pour la période de ${context.read<DeclarationViewModel>().periodeAffichee}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _salaireController,
                decoration: const InputDecoration(
                  labelText: 'Salaire Brut',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heuresController,
                decoration: const InputDecoration(
                  labelText: 'Heures Travaillées',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Enregistrer les informations'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
