// lib/presentations/vues/admin/admin_dashboard.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/auth_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'tabs/admin_home_tab.dart';
import 'tabs/users_management_tab.dart';
import 'tabs/admin_settings_tab.dart';
import 'tabs/create_user_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  void _navigateToTab(int index) {
    if (index >= 0 && index < 3) {
      setState(() => _selectedIndex = index);
    }
  }

  void _showCreateUserScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateUserScreen()),
    );
  }

  void _logout() async {
    await context.read<AuthViewModel>().logout();
  }

  @override
  Widget build(BuildContext context) {
    // La liste des onglets est maintenant liée aux nouveaux écrans
    final List<Widget> tabs = [
      AdminHomeTab(onNavigate: _navigateToTab),
      const UsersManagementTab(),
      const AdminSettingsTab(),
    ];

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Panel d'Administration",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kAppBarGradient),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 28,
            ),
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    enabled: false,
                    child: Text(
                      "Menu Admin",
                      style: TextStyle(fontWeight: FontWeight.bold),
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
      body: IndexedStack(index: _selectedIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateToTab,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: kGreyText,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Utilisateurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Système',
          ),
        ],
      ),
      floatingActionButton:
          _selectedIndex == 1
              ? FloatingActionButton(
                onPressed: _showCreateUserScreen,
                backgroundColor: kAccentColor,
                foregroundColor: Colors.white,
                tooltip: "Créer un utilisateur",
                child: const Icon(Icons.add),
              )
              : null,
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
                const Text(
                  "Administrateur",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser?.email ?? "admin@cnss.app",
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
                  'Gestion des utilisateurs',
                  Icons.people_alt_outlined,
                ),
                _drawerItem(2, 'Paramètres système', Icons.settings_outlined),
              ],
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'CnssApp v1.0.0 - Admin Panel',
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
