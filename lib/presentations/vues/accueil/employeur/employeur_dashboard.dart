// lib/presentations/vues/dashboard/employeur_dashboard.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/auth_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/travailleur_viewmodel.dart';
import 'package:cnss_app/presentations/vues/accueil/employeur/worker_add_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import pour User

import 'dashboard_home.dart';
import 'workers_list.dart';
import 'declaration_entry_screen.dart';

class EmployeurDashboard extends StatefulWidget {
  const EmployeurDashboard({super.key});

  @override
  State<EmployeurDashboard> createState() => _EmployeurDashboardState();
}

class _EmployeurDashboardState extends State<EmployeurDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const DashboardHome(),
    const WorkersList(),
    const DeclarationEntryScreen(),
    const Center(child: Text('Historique des Déclarations')),
    const Center(child: Text('Aide et Support')),
  ];

  final List<Map<String, dynamic>> _bottomNavItems = [
    {'icon': Icons.home_outlined, 'label': 'Accueil'},
    {'icon': Icons.people_outline, 'label': 'Employés'},
    {'icon': Icons.note_add_outlined, 'label': 'Déclarer'},
    {'icon': Icons.history_outlined, 'label': 'Historique'},
    {'icon': Icons.help_outline, 'label': 'Aide'},
  ];

  void _showAddWorkerDialog() {
    final travailleurVM = context.read<TravailleurViewModel>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return ChangeNotifierProvider.value(
          value: travailleurVM,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const WorkerAddForm(),
          ),
        );
      },
    );
  }

  void _logout() async {
    await context.read<AuthViewModel>().logout();
  }

  void _forceSync() {
    // CORRECTION : Appelle les bonnes méthodes de chargement des ViewModels
    context.read<TravailleurViewModel>().chargerTravailleurs();
    context.read<DeclarationViewModel>().chargerBrouillon(notify: true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Synchronisation avec Firebase en cours...'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // On observe le AuthViewModel pour les informations de l'utilisateur
    context.watch<AuthViewModel>();
    final User? currentUser =
        FirebaseAuth.instance.currentUser; // Pour l'affichage

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'E-Déclaration CNSS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kAppBarGradient),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            tooltip: 'Synchroniser avec le serveur',
            onPressed: _forceSync,
          ),
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(gradient: kAppBarGradient),
              // CORRECTION : Affiche dynamiquement les infos de l'utilisateur
              accountName: Text(
                currentUser?.displayName ?? "Nom de l'employeur",
              ),
              accountEmail: Text(currentUser?.email ?? "email@employeur.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person_outline, color: kPrimaryColor),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(0, 'Tableau de bord', Icons.dashboard_outlined),
                  _drawerItem(
                    1,
                    'Gestion des employés',
                    Icons.people_alt_outlined,
                  ),
                  _drawerItem(
                    2,
                    'Nouvelle déclaration',
                    Icons.note_add_outlined,
                  ),
                  _drawerItem(3, 'Historique', Icons.history_outlined),
                  _drawerItem(4, 'Aide & Support', Icons.help_outline_outlined),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Paramètres'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Déconnexion',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(color: Colors.grey[50], child: _tabs[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        items:
            _bottomNavItems
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item['icon']),
                    label: item['label'],
                  ),
                )
                .toList(),
      ),
      floatingActionButton:
          _selectedIndex == 1
              ? FloatingActionButton(
                onPressed: _showAddWorkerDialog,
                backgroundColor: kPrimaryColor,
                elevation: 4,
                child: const Icon(Icons.person_add_alt_1, size: 28),
              )
              : null,
    );
  }

  Widget _drawerItem(int index, String title, IconData icon) {
    final bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? kPrimaryColor : Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? kPrimaryColor : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}
