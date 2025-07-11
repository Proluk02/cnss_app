// Écran d'administration
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GestionUtilisateurs extends StatefulWidget {
  const GestionUtilisateurs({super.key});

  @override
  State<GestionUtilisateurs> createState() => _GestionUtilisateursState();
}

class _GestionUtilisateursState extends State<GestionUtilisateurs> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> roles = [
    'employeur',
    'chefSES',
    'préposé',
    'décompteur',
    'directeur',
    'administrateur',
  ];

  void _modifierRole(String uid, String nouveauRole) {
    _firestore.collection('utilisateurs').doc(uid).update({
      'role': nouveauRole,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestion des utilisateurs")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('utilisateurs').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final utilisateurs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: utilisateurs.length,
            itemBuilder: (context, index) {
              final utilisateur = utilisateurs[index];
              final uid = utilisateur.id;
              final nom = utilisateur['nom'];
              final email = utilisateur['email'];
              final roleActuel = utilisateur['role'];

              return ListTile(
                title: Text('$nom ($email)'),
                subtitle: Text('Rôle : $roleActuel'),
                trailing: DropdownButton<String>(
                  value: roleActuel,
                  onChanged: (String? nouveauRole) {
                    if (nouveauRole != null && nouveauRole != roleActuel) {
                      _modifierRole(uid, nouveauRole);
                    }
                  },
                  items:
                      roles
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
