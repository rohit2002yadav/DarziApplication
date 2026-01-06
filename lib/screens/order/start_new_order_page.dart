import 'package:flutter/material.dart';

class StartNewOrderPage extends StatelessWidget {
  const StartNewOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50], // Set background to light purple
      appBar: AppBar(
        title: const Text('Start a New Order'),
        backgroundColor: Colors.purple[50], // Match the background color
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            _buildOptionCard(
              context,
              icon: Icons.inventory_2_outlined,
              text: 'I Have My Own Fabric',
              onTap: () {
                // Navigate to the new fabric details page
                Navigator.pushNamed(context, '/fabric-details');
              },
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              icon: Icons.store_outlined,
              text: 'Buy Fabric from Platform',
              onTap: () {
                // TODO: Navigate to the fabric marketplace
              },
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              icon: Icons.person_search_outlined, 
              text: 'Tailor Will Provide Fabric',
              onTap: () {
                // TODO: Navigate to the tailor selection
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Row(
            children: [
              Icon(icon, size: 40, color: primaryColor),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
