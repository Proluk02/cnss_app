// lib/presentations/vues/admin/tabs/users_management_tab.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/modeles/utilisateur_modele.dart';
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

              // Conversion en UtilisateurModele dès le début
              var utilisateurs =
                  snapshot.data!.docs
                      .map(
                        (doc) => UtilisateurModele.fromMap(
                          doc.data() as Map<String, dynamic>,
                        ),
                      )
                      .where((user) => user.uid != _currentAdminId)
                      .toList();

              if (_searchQuery.isNotEmpty) {
                utilisateurs =
                    utilisateurs.where((user) {
                      final query = _searchQuery.toLowerCase();
                      final nom = user.nom?.toLowerCase() ?? '';
                      final email = user.email?.toLowerCase() ?? '';
                      return nom.contains(query) || email.contains(query);
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
                  // On passe directement l'objet UtilisateurModele
                  return _UserCard(user: utilisateurs[index]);
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
  final UtilisateurModele user;
  const _UserCard({required this.user});

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
      builder:
          (ctx) => AlertDialog(
            title: Text("Changer le rôle de $nom"),
            content: StatefulBuilder(
              // Utiliser StatefulBuilder pour que le Dropdown se mette à jour visuellement
              builder: (BuildContext context, StateSetter setState) {
                return DropdownButton<String>(
                  value: selectedRole,
                  isExpanded: true,
                  items:
                      roles
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedRole = value;
                      });
                    }
                  },
                );
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
          ),
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
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: ListTile(
        onTap: () {
          // On passe l'objet UtilisateurModele directement, ce qui est plus propre
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserDetailScreen(user: user)),
          );
        },
        leading: CircleAvatar(
          backgroundColor: kPrimaryColor.withOpacity(0.1),
          foregroundColor: kPrimaryColor,
          child: Text(
            user.nom?.isNotEmpty == true ? user.nom![0].toUpperCase() : '?',
          ),
        ),
        title: Text(
          user.nom ?? "Nom non défini",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user.email ?? "Email non défini"),
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
                user.role ?? 'N/A',
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
                  _showChangeRoleDialog(
                    context,
                    user.uid,
                    user.nom ?? '',
                    user.role ?? '',
                  );
                else if (value == 'delete')
                  _confirmDelete(context, user.uid, user.nom ?? '');
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
