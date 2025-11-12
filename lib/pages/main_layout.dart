
import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import 'dashboard_page.dart';
import 'data_audit_page.dart';
import 'hazard_page.dart';
import 'laporan_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    DashboardPage(),
    DataAuditPage(),
    HazardPage(),
    LaporanPage(),
  ];

  void onSelectMenu(int index) => setState(() => selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(selectedIndex: selectedIndex, onSelect: onSelectMenu),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                Expanded(child: pages[selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
