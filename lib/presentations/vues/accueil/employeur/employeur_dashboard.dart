// lib/presentations/vues/dashboard/employeur_dashboard.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/auth_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/travailleur_viewmodel.dart';
import 'package:cnss_app/presentations/vues/accueil/employeur/worker_add_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dashboard_home.dart';
import 'workers_list.dart';
import 'declaration_entry_screen.dart';
import 'history_screen.dart';
import 'help_screen.dart';

// Écrans placeholders pour la navigation
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Notifications")),
    body: const Center(child: Text("Écran des Notifications")),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Paramètres")),
    body: const Center(child: Text("Écran des Paramètres")),
  );
}

class EmployeurDashboard extends StatefulWidget {
  const EmployeurDashboard({super.key});

  @override
  State<EmployeurDashboard> createState() => _EmployeurDashboardState();
}

class _EmployeurDashboardState extends State<EmployeurDashboard> {
  int _selectedIndex = 0;

  void _navigateToTab(int index) {
    if (index >= 0 && index < 5) {
      setState(() => _selectedIndex = index);
    }
  }

  void _showAddWorkerDialog() {
    final travailleurVM = context.read<TravailleurViewModel>();
    showDialog(
      context: context,
      builder:
          (dialogContext) => ChangeNotifierProvider.value(
            value: travailleurVM,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kCardRadius),
              ),
              child: const WorkerAddForm(),
            ),
          ),
    );
  }

  void _logout() async {
    await context.read<AuthViewModel>().logout();
  }

  void _forceSync() {
    context.read<TravailleurViewModel>().chargerTravailleurs();
    context.read<DeclarationViewModel>().initialiser();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Synchronisation avec le serveur...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      DashboardHome(onNavigate: _navigateToTab),
      const WorkersList(),
      const DeclarationEntryScreen(),
      const HistoryScreen(),
      const HelpScreen(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          'Tableau de Bord',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kAppBarGradient),
        ),
        elevation: 4,
        shadowColor: kPrimaryColor.withOpacity(0.5),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            tooltip: 'Forcer la synchronisation',
            onPressed: _forceSync,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout')
                _logout();
              else if (value == 'settings')
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              else if (value == 'notifications')
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
            },
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 28,
            ),
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'notifications',
                    child: ListTile(
                      leading: Icon(Icons.notifications_outlined),
                      title: Text('Notifications'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings_outlined),
                      title: Text('Paramètres'),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: kErrorColor),
                      title: Text(
                        'Déconnexion',
                        style: TextStyle(color: kErrorColor),
                      ),
                    ),
                  ),
                ],
          ),
        ],
      ),
      drawer: _buildCustomDrawer(context),
      body: Container(color: kBackgroundColor, child: tabs[_selectedIndex]),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToTab(2),
        backgroundColor:
            _selectedIndex == 2
                ? kPrimaryColor
                : kSecondaryColor.withOpacity(0.9),
        elevation: 2.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.file_copy, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: _NotchedBottomBar(
        selectedIndex: _selectedIndex,
        onTap: _navigateToTab,
      ),
    );
  }

  Widget _buildCustomDrawer(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(gradient: kAppBarGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/images/logo_cnss.png', height: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  currentUser?.displayName ?? "Nom de l'Employeur",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser?.email ?? "email@employeur.com",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: [
                _drawerItem(0, 'Tableau de bord', Icons.dashboard_outlined),
                _drawerItem(
                  1,
                  'Gestion des employés',
                  Icons.people_alt_outlined,
                ),
                _drawerItem(2, 'Nouvelle déclaration', Icons.note_add_outlined),
                _drawerItem(3, 'Historique', Icons.history_outlined),
                _drawerItem(4, 'Aide & Support', Icons.help_outline_outlined),
              ],
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'CnssApp v1.0.0',
              style: TextStyle(color: kGreyText, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(int index, String title, IconData icon) {
    final bool isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? kPrimaryColor : Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? kPrimaryColor : kDarkText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          _navigateToTab(index);
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _NotchedBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _NotchedBottomBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // CORRECTION : Le BuildContext est maintenant disponible ici.
    return BottomAppBar(
      elevation: 10.0,
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.home_filled,
                  index: 0,
                  label: "Accueil",
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.people,
                  index: 1,
                  label: "Employés",
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.history,
                  index: 3,
                  label: "Historique",
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.help,
                  index: 4,
                  label: "Aide",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required int index,
    required String label,
  }) {
    final isSelected = selectedIndex == index;
    return SizedBox(
      width:
          MediaQuery.of(context).size.width /
          5, // Utilise le BuildContext valide
      height: 60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? kPrimaryColor : kGreyText,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? kPrimaryColor : kGreyText,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
