
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Quality Audit System', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(LucideIcons.bell)),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  icon: CircleAvatar(child: Text(user?.email?.substring(0,1).toUpperCase() ?? 'U')),
                  items: const [
                    DropdownMenuItem(value: 'profile', child: Text('Profil')),
                    DropdownMenuItem(value: 'logout', child: Text('Keluar')),
                  ],
                  onChanged: (v) {
                    if (v == 'logout') FirebaseAuth.instance.signOut().then((_) => Navigator.pushReplacementNamed(context, '/'));
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
