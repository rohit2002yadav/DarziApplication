import 'package:flutter/material.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfilePage({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    final name = userData?['name'] ?? 'User';
    final email = userData?['email'] ?? 'user@example.com';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildProfileHeader(name, email),
          const SizedBox(height: 20),
          const Divider(),
          _buildProfileMenuItem(
            context,
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () {
              Navigator.pushNamed(context, '/edit-profile', arguments: userData);
            },
          ),
          _buildProfileMenuItem(
            context,
            icon: Icons.straighten_outlined,
            title: 'My Measurements',
            onTap: () {
              Navigator.pushNamed(context, '/measurements', arguments: userData);
            },
          ),
          _buildProfileMenuItem(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () { /* TODO */ },
          ),
          _buildProfileMenuItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () { /* TODO */ },
          ),
          _buildProfileMenuItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () { /* TODO */ },
          ),
          const Divider(),
          _buildProfileMenuItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            color: Colors.red,
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.purple.shade100,
            child: Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    final Color itemColor = color ?? Colors.black87;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: itemColor),
      title: Text(title, style: TextStyle(color: itemColor, fontWeight: FontWeight.w600, fontSize: 16)),
      trailing: color == null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }
}
