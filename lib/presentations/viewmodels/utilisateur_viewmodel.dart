// Logique des utilisateurs
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../donnees/firebase_service.dart';

final authViewModelProvider = Provider((ref) => AuthViewModel());

class AuthViewModel {
  final _firebaseService = FirebaseService();

  Future<void> login(String email, String password) =>
      _firebaseService.login(email, password);

  Future<void> register(String nom, String email, String password) =>
      _firebaseService.register(
        nom: nom,
        email: email,
        password: password,
        role: "employeur", // par défaut
      );

  Future<void> logout() => _firebaseService.logout();

  Stream get userChanges => _firebaseService.userChanges;
}
