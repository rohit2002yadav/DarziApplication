import 'package:flutter/material.dart';
import 'tailor_orders_tab.dart';
import '../services/tailor_service.dart';

class TailorHome extends StatefulWidget {
  final Map<String, dynamic> userData;
  const TailorHome({super.key, required this.userData});

  @override
  State<TailorHome> createState() => _TailorHomeState();
}

class _TailorHomeState extends State<TailorHome> {
  int _todayCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchTodayCount();
  }

  Future<void> _fetchTodayCount() async {
    try {
      final analytics = await TailorService.getAnalytics();
      if (mounted) {
        setState(() {
          _todayCount = analytics['todayOrders'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Error fetching analytics: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.userData['name'] ?? 'Tailor';
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100, // Increased for two-line header
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white24,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'T',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text("Hi, $name! 👋", style: const TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 44),
                child: Text(
                  "Today's Orders: $_todayCount",
                  style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Logout',
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "New"),
              Tab(text: "In Progress"),
              Tab(text: "Completed"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TailorOrdersTab(status: "PLACED"),
            TailorOrdersTab(status: "ONGOING"),
            TailorOrdersTab(status: "DELIVERED"),
          ],
        ),
      ),
    );
  }
}
