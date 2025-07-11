import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'donnees/firebase_service.dart';
import 'configuration/routes.dart';
import 'presentations/vues/authentification/connexion.dart';
import 'presentations/vues/accueil/welcome_screen.dart';
import 'presentations/vues/admin/gestion_utilisateurs.dart';
import 'presentations/vues/tableau_bord.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // <-- Ajout ici
  );

  runApp(const CNSSApp());
}

class CNSSApp extends StatelessWidget {
  const CNSSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CNSSApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      onGenerateRoute: generateRoute,
      home: const SessionWrapper(),
    );
  }
}

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
                  return const TableauBord(); // Dashboard commun avec redirection interne
                case 'administrateur':
                  return const GestionUtilisateurs();
                default:
                  return const WelcomeScreen();
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
