import 'package:cnss_app/presentations/vues/admin/admin_dashboard.dart';
import 'package:cnss_app/presentations/vues/tableau_bord.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../donnees/firebase_service.dart';
import '../authentification/connexion.dart';

class SessionWrapper extends StatelessWidget {
  const SessionWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseService().userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<String?>(
            future: FirebaseService().getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final role = roleSnapshot.data;
              switch (role) {
                case 'employeur':
                case 'chefSES':
                case 'préposé':
                case 'décompteur':
                case 'directeur':
                  return const TableauBord(role: '');
                case 'administrateur':
                  return const AdminDashboard();
                default:
                  return const ConnexionPage();
              }
            },
          );
        } else {
          return const ConnexionPage();
        }
      },
    );
  }
}
