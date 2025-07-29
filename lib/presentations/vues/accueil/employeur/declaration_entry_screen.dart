import 'package:flutter/material.dart';
import '../../../../core/constantes.dart';
import 'package:cnss_app/donnees/modeles/travailleur.dart';

class DeclarationEntryScreen extends StatefulWidget {
  final Travailleur? travailleur;
  final Function(Map<String, dynamic>)? onDeclarationSaved;

  const DeclarationEntryScreen({
    super.key,
    this.travailleur,
    this.onDeclarationSaved,
  });

  @override
  State<DeclarationEntryScreen> createState() => _DeclarationEntryScreenState();
}

class _DeclarationEntryScreenState extends State<DeclarationEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _periodeController = TextEditingController();
  final TextEditingController _salaireController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final declaration = {
        'travailleurId': widget.travailleur!.id,
        'periode': _periodeController.text.trim(),
        'salaire': double.tryParse(_salaireController.text.trim()) ?? 0.0,
        'timestamp': DateTime.now().toIso8601String(),
      };
      widget.onDeclarationSaved?.call(declaration);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.travailleur == null) {
      return const Center(child: Text('Veuillez sélectionner un travailleur.'));
    }

    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'Travailleur : ${widget.travailleur!.nomComplet}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _periodeController,
              decoration: const InputDecoration(
                labelText: 'Période (ex: 07/2025)',
              ),
              validator: (value) => value!.isEmpty ? 'Champ requis' : null,
            ),
            TextFormField(
              controller: _salaireController,
              decoration: const InputDecoration(labelText: 'Salaire brut'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Enregistrer la déclaration'),
            ),
          ],
        ),
      ),
    );
  }
}
