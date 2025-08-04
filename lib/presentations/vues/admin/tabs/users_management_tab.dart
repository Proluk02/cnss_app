// lib/presentations/vues/admin/tabs/users_management_tab.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/vues/admin/tabs/user_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersManagementTab extends StatefulWidget {
  const UsersManagementTab({super.key});

  @override
  State<UsersManagementTab> createState() => _UsersManagementTabState();
}

class _UsersManagementTabState extends State<UsersManagementTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _currentAdminId = FirebaseAuth.instance.currentUser?.uid;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: const InputDecoration(
              hintText: "Rechercher par nom ou email...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(kButtonRadius)),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('utilisateurs').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Une erreur est survenue."));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Aucun utilisateur trouvé."));
              }

              var utilisateurs =
                  snapshot.data!.docs
                      .where((doc) => doc.id != _currentAdminId)
                      .toList();

              if (_searchQuery.isNotEmpty) {
                utilisateurs =
                    utilisateurs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final nom = (data['nom'] as String? ?? '').toLowerCase();
                      final email =
                          (data['email'] as String? ?? '').toLowerCase();
                      return nom.contains(_searchQuery.toLowerCase()) ||
                          email.contains(_searchQuery.toLowerCase());
                    }).toList();
              }

              if (utilisateurs.isEmpty) {
                return const Center(
                  child: Text(
                    "Aucun utilisateur ne correspond à votre recherche.",
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  kDefaultPadding,
                  0,
                  kDefaultPadding,
                  kDefaultPadding,
                ),
                itemCount: utilisateurs.length,
                itemBuilder: (context, index) {
                  return _UserCard(userDoc: utilisateurs[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final QueryDocumentSnapshot userDoc;
  const _UserCard({required this.userDoc});

  void _modifierRole(String uid, String nouveauRole) {
    FirebaseFirestore.instance.collection('utilisateurs').doc(uid).update({
      'role': nouveauRole,
    });
  }

  void _supprimerUtilisateur(String uid) {
    FirebaseFirestore.instance.collection('utilisateurs').doc(uid).delete();
  }

  void _showChangeRoleDialog(
    BuildContext context,
    String uid,
    String nom,
    String roleActuel,
  ) {
    const roles = [
      'employeur',
      'chefSES',
      'préposé',
      'décompteur',
      'directeur',
    ];
    String selectedRole = roleActuel;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Changer le rôle de $nom"),
          content: DropdownButton<String>(
            value: selectedRole,
            isExpanded: true,
            items:
                roles
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role)),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) selectedRole = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Annuler"),
            ),
            FilledButton(
              onPressed: () {
                _modifierRole(uid, selectedRole);
                Navigator.of(ctx).pop();
              },
              child: const Text("Valider"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String uid, String nom) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Confirmer la Suppression"),
            content: Text(
              "Voulez-vous vraiment supprimer l'utilisateur $nom ? Cette action est irréversible.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Annuler"),
              ),
              FilledButton(
                onPressed: () {
                  _supprimerUtilisateur(uid);
                  Navigator.of(ctx).pop();
                },
                style: FilledButton.styleFrom(backgroundColor: kErrorColor),
                child: const Text("Supprimer"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = userDoc.id;
    final data = userDoc.data() as Map<String, dynamic>;
    final nom = data['nom'] as String? ?? 'N/A';
    final email = data['email'] as String? ?? 'N/A';
    final roleActuel = data['role'] as String? ?? 'N/A';

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserDetailScreen(userDoc: userDoc),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: kPrimaryColor.withOpacity(0.1),
          foregroundColor: kPrimaryColor,
          child: Text(nom.isNotEmpty ? nom[0].toUpperCase() : '?'),
        ),
        title: Text(nom, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: kAccentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                roleActuel,
                style: const TextStyle(
                  color: kAccentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit')
                  _showChangeRoleDialog(context, uid, nom, roleActuel);
                else if (value == 'delete')
                  _confirmDelete(context, uid, nom);
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text("Modifier le rôle"),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        "Supprimer",
                        style: TextStyle(color: kErrorColor),
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
