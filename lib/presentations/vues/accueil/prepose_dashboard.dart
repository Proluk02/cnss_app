// lib/presentations/vues/accueil/prepose_dashboard.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/auth_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/prepose_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'prepose_tabs/prepose_home_tab.dart';
import 'prepose_tabs/prepose_search_tab.dart';

class PreposeDashboard extends StatefulWidget {
  const PreposeDashboard({super.key});

  @override
  State<PreposeDashboard> createState() => _PreposeDashboardState();
}

class _PreposeDashboardState extends State<PreposeDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const PreposeHomeTab(),
    const PreposeSearchTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PreposeViewModel(),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: const Text("Préposé SES",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: kAppBarGradient)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => context.read<AuthViewModel>().logout(),
            )
          ],
        ),
        drawer: _buildCustomDrawer(context),
        body: IndexedStack(
          index: _selectedIndex,
          children: _tabs,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: kGreyText,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined), label: "Accueil"),
            BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined), label: "Recherche"),
          ],
        ),
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle),
                  child:
                      Image.asset('assets/images/logo_cnss.png', height: 48)),
              const SizedBox(height: 16),
              const Text("Préposé SES",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(currentUser?.email ?? "prepose.ses@cnss.app",
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ]),
          ),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  children: [
                _drawerItem(0, 'Tableau de bord', Icons.dashboard_outlined),
                _drawerItem(1, 'Rechercher un Cotisant', Icons.search_outlined),
              ])),
          const Divider(height: 1),
          const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('CnssApp v1.0.0',
                  style: TextStyle(color: kGreyText, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _drawerItem(int index, String title, IconData icon) {
    final bool isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color:
              isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading:
            Icon(icon, color: isSelected ? kPrimaryColor : Colors.grey[700]),
        title: Text(title,
            style: TextStyle(
                color: isSelected ? kPrimaryColor : kDarkText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        onTap: () {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
