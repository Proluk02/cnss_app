import 'package:cnss_app/core/constantes.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cnss_app/donnees/modeles/travailleur.dart';

class WorkersList extends StatelessWidget {
  final Function(Travailleur) onWorkerSelected;

  const WorkersList({super.key, required this.onWorkerSelected});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('travailleurs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erreur lors du chargement'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('Aucun travailleur enregistré.'));
        }

        final travailleurs =
            docs.map((doc) => Travailleur.fromDoc(doc)).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(kDefaultPadding),
          itemCount: travailleurs.length,
          itemBuilder: (context, index) {
            final t = travailleurs[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kCardRadius),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(t.nomComplet),
                subtitle: Text(
                  'Matricule: ${t.matricule} | CNSS: ${t.immatriculationCNSS}',
                ),
                trailing: Text(
                  t.typeTravailleur == 1 ? 'Travailleur' : 'Assimilé',
                ),
                onTap: () => onWorkerSelected(t),
              ),
            );
          },
        );
      },
    );
  }
}
