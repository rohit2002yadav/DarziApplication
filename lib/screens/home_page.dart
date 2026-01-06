import 'package:flutter/material.dart';

import 'customer/customer_home_view.dart';
import 'customer/order_history_page.dart';
import '../tailor/tailor_list_page.dart';
import '../tailor/tailor_home.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const HomePage({super.key, this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String role = widget.userData?['role'] ?? 'customer';

    // If the user is a tailor, show the Tailor Dashboard immediately
    if (role == 'tailor') {
      return TailorHome(userData: widget.userData ?? {});
    }

    final List<Widget> customerPages = [
      CustomerHomeView(userData: widget.userData),
      OrderHistoryPage(userData: widget.userData),
      TailorListPage(userData: widget.userData),
      ProfilePage(userData: widget.userData),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: customerPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
            icon: const Text('🏠', style: TextStyle(fontSize: 24)),
            activeIcon: CircleAvatar(
              radius: 18,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              child: const Text('🏠', style: TextStyle(fontSize: 24)),
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Text('📦', style: TextStyle(fontSize: 24)),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Text('✂️', style: TextStyle(fontSize: 24)),
            label: 'Tailors',
          ),
          const BottomNavigationBarItem(
            icon: Text('👤', style: TextStyle(fontSize: 24)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
