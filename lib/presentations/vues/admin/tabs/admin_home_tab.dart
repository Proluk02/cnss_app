// lib/presentations/vues/admin/tabs/admin_home_tab.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:cnss_app/presentations/vues/admin/tabs/create_user_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AdminHomeTab extends StatelessWidget {
  final Function(int) onNavigate;
  const AdminHomeTab({super.key, required this.onNavigate});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour,';
    if (hour < 18) return 'Bon après-midi,';
    return 'Bonsoir,';
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final adminName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Administrateur';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('utilisateurs').snapshots(),
      builder: (context, userSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: firebaseService.getDeclarationsEnAttenteStream(),
          builder: (context, declarationSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting ||
                declarationSnapshot.connectionState ==
                    ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userSnapshot.hasError || declarationSnapshot.hasError) {
              return Center(
                child: Text(
                  "Erreur de chargement: ${userSnapshot.error ?? declarationSnapshot.error}",
                ),
              );
            }

            if (!userSnapshot.hasData || !declarationSnapshot.hasData) {
              return const Center(child: Text("Aucune donnée disponible."));
            }

            final allUsersDocs = userSnapshot.data!.docs;
            final pendingDeclarationsCount =
                declarationSnapshot.data!.docs.length;
            final userCount = allUsersDocs.length;
            final recentUsers = allUsersDocs.reversed.take(3).toList();

            final rolesCount = <String, double>{};
            for (var doc in allUsersDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final role = data['role'] as String? ?? 'inconnu';
              rolesCount[role] = (rolesCount[role] ?? 0) + 1;
            }

            return RefreshIndicator(
              onRefresh: () async {},
              child: ListView(
                padding: const EdgeInsets.all(kDefaultPadding),
                children: [
                  Text(
                    _getGreeting(),
                    style: kSubtitleStyle.copyWith(color: kGreyText),
                  ),
                  Text(
                    adminName,
                    style: kTitleStyle.copyWith(fontSize: 28, color: kDarkText),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Actions Rapides",
                    style: kTitleStyle.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  // CORRECTION : Le Row a été retiré, il ne reste qu'un seul ActionCard
                  _ActionCard(
                    icon: Icons.person_add_outlined,
                    label: "Créer un Utilisateur",
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateUserScreen(),
                          ),
                        ),
                  ),
                  const SizedBox(height: 24),

                  _StatCard(
                    title: "Utilisateurs Inscrits",
                    value: userCount.toString(),
                    icon: Icons.people,
                    color: kPrimaryColor,
                    onTap: () => onNavigate(1),
                  ),
                  const SizedBox(height: 16),
                  _StatCard(
                    title: "Déclarations en Attente",
                    value: pendingDeclarationsCount.toString(),
                    icon: Icons.hourglass_top,
                    color: kWarningColor,
                    isClickable: true,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Répartition des Rôles",
                    style: kTitleStyle.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _RolesPieChart(rolesCount: rolesCount),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Derniers Utilisateurs Inscrits",
                    style: kTitleStyle.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  if (recentUsers.isEmpty)
                    const Center(child: Text("Aucun utilisateur récent."))
                  else
                    Column(
                      children:
                          recentUsers
                              .map((doc) => _RecentUserTile(doc: doc))
                              .toList(),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kCardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: kPrimaryColor),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isClickable;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isClickable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(title, style: const TextStyle(color: kGreyText)),
                ],
              ),
              if (isClickable || onTap != null) ...[
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 16, color: kGreyText),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RolesPieChart extends StatelessWidget {
  final Map<String, double> rolesCount;
  const _RolesPieChart({required this.rolesCount});

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sections = [];
    final colors = [
      kPrimaryColor,
      kAccentColor,
      kSecondaryColor,
      Colors.blueGrey,
      Colors.teal,
    ];
    int colorIndex = 0;

    rolesCount.forEach((role, count) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: count,
          title: '${count.toInt()}',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: PieChart(
                PieChartData(sections: sections, centerSpaceRadius: 20),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    rolesCount.keys.map((role) {
                      final index = rolesCount.keys.toList().indexOf(role);
                      return _Indicator(
                        color: colors[index % colors.length],
                        text: role,
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  const _Indicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 16, height: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentUserTile extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _RecentUserTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final nom = data['nom'] as String? ?? 'N/A';
    final email = data['email'] as String? ?? 'N/A';
    final role = data['role'] as String? ?? 'N/A';

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kPrimaryColor.withOpacity(0.1),
          child: const Icon(Icons.person, color: kPrimaryColor),
        ),
        title: Text(nom, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(email),
        trailing: Text(role, style: const TextStyle(color: kGreyText)),
      ),
    );
  }
}
