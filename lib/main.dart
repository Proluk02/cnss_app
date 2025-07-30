// lib/main.dart

import 'package:cnss_app/presentations/viewmodels/auth_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/travailleur_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// --- IMPORTS SQFLITE RETIRÉS ---
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:sqflite/sqflite.dart';
// import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'donnees/firebase_service.dart';
import 'firebase_options.dart';
import 'presentations/vues/accueil/splash_screen.dart';
import 'presentations/vues/accueil/welcome_screen.dart';
import 'presentations/vues/admin/gestion_utilisateurs.dart';
import 'presentations/vues/authentification/connexion.dart';
import 'presentations/vues/tableau_bord.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- BLOC D'INITIALISATION SQFLITE POUR LE WEB RETIRÉ ---
  // if (kIsWeb) {
  //   databaseFactory = databaseFactoryFfiWeb;
  // }

  await initializeDateFormatting('fr_FR', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CNSSApp());
}

class CNSSApp extends StatelessWidget {
  const CNSSApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Le AuthViewModel est fourni à la racine pour gérer l'authentification globale.
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: MaterialApp(
        title: 'CnssApp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SessionWrapper(),
      ),
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
          return const SplashScreen();
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<String?>(
            future: FirebaseService().getUserRole(user.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              final role = roleSnapshot.data;
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (_) => TravailleurViewModel(uid: user.uid),
                  ),
                  ChangeNotifierProvider(
                    create: (_) => DeclarationViewModel(uid: user.uid),
                  ),
                ],
                child: Builder(
                  builder: (context) {
                    switch (role) {
                      case 'employeur':
                      case 'chefSES':
                      case 'préposé':
                      case 'décompteur':
                      case 'directeur':
                        return TableauBord(role: role!);
                      case 'administrateur':
                        return const GestionUtilisateurs();
                      default:
                        // Cas où l'utilisateur est authentifié mais son rôle est manquant ou invalide.
                        return const WelcomeScreen();
                    }
                  },
                ),
              );
            },
          );
        } else {
          return const ConnexionPage();
        }
      },
    );
  }
}
