// lib/presentations/vues/accueil/chef_ses_tabs/ses_search_declaration_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SesSearchDeclarationScreen extends StatefulWidget {
  const SesSearchDeclarationScreen({super.key});

  @override
  State<SesSearchDeclarationScreen> createState() =>
      _SesSearchDeclarationScreenState();
}

class _SesSearchDeclarationScreenState
    extends State<SesSearchDeclarationScreen> {
  Future<List<Map<String, dynamic>>>? _declarationsFuture;
  final FirebaseService _firebaseService = FirebaseService();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Charger toutes les déclarations au démarrage
    _declarationsFuture =
        _firebaseService.getToutesLesDeclarationsAvecEmployeur();
  }

  // Fonction pour afficher le sélecteur de date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      // Pour une sélection par mois, il faudrait un package custom,
      // mais un DatePicker standard est déjà une grande amélioration.
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Toutes les Déclarations"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kAppBarGradient),
        ),
      ),
      body: Column(
        children: [
          // Barre de filtre
          Container(
            padding: const EdgeInsets.all(kDefaultPadding),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Filtrer par période",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(kButtonRadius),
                          ),
                        ),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'Toutes les périodes'
                            : DateFormat(
                              'MMMM yyyy',
                              'fr_FR',
                            ).format(_selectedDate!),
                        style: kSubtitleStyle.copyWith(color: kDarkText),
                      ),
                    ),
                  ),
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: kErrorColor),
                    onPressed: () => setState(() => _selectedDate = null),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _declarationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Une erreur est survenue: ${snapshot.error}"),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Aucune déclaration trouvée."),
                  );
                }

                // Filtrer la liste en fonction de la date sélectionnée
                var declarations = snapshot.data!;
                if (_selectedDate != null) {
                  final selectedPeriod = DateFormat(
                    'yyyy-MM',
                  ).format(_selectedDate!);
                  declarations =
                      declarations
                          .where((decla) => decla['periode'] == selectedPeriod)
                          .toList();
                }

                if (declarations.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucune déclaration trouvée pour cette période.",
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  itemCount: declarations.length,
                  itemBuilder: (context, index) {
                    final rapport = RapportDeclaration.fromMap(
                      declarations[index],
                    );
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kCardRadius),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.find_in_page_outlined,
                          color: kPrimaryColor,
                        ),
                        title: Text(
                          "Période: ${rapport.periode}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Employeur: ${declarations[index]['employeurNom'] ?? 'N/A'}",
                        ),
                        trailing: Text(
                          rapport.statut.toString().split('.').last,
                        ),
                        onTap: () {
                          // TODO: Naviguer vers les détails.
                          // Cela nécessitera de pouvoir reconstruire les ViewModels de l'employeur cliqué.
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
