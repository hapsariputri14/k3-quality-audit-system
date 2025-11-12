import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'icon': LucideIcons.archive, 'title': 'Dashboard'},
      {'icon': LucideIcons.database, 'title': 'Data Audit'},
      {'icon': LucideIcons.bug, 'title': 'Hazard HIRA'},
      {'icon': LucideIcons.clipboard, 'title': 'Laporan'},
    ];

    return Container(
      width: 220,
      color: Colors.indigo.shade800,
      child: Column(
        children: [
          const SizedBox(height: 28),
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.factory, color: Colors.indigo),
          ),
          const SizedBox(height: 12),
          const Text(
            'Quality Audit',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 18),

          // Daftar menu
          ...menuItems.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final selected = selectedIndex == idx;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Material(
                color: selected ? Colors.indigo.shade600 : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onSelect(idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item['title'] as String,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'v1.0.0',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
