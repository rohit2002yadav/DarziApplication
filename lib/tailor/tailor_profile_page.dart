import 'package:flutter/material.dart';

class TailorProfilePage extends StatelessWidget {
  final Map<String, dynamic> tailorData;
  final Map<String, dynamic>? userData;

  const TailorProfilePage({super.key, required this.tailorData, this.userData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = tailorData['tailorDetails'] ?? {};
    final String name = tailorData['name'] ?? 'Tailor';
    final String shopName = details['shopName'] ?? 'Boutique';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(shopName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              background: Container(
                color: theme.primaryColor,
                child: const Icon(Icons.store, size: 80, color: Colors.white24),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(details['tailorType'] ?? "Specialist", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 18, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text("${details['rating'] ?? '4.8'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  _buildInfoSection(Icons.location_on_outlined, "Location", "${details['address'] ?? 'Shop Address'}, ${details['city']}"),
                  const SizedBox(height: 16),
                  _buildInfoSection(Icons.history, "Experience", "10+ Years"),
                  const SizedBox(height: 16),
                  _buildInfoSection(Icons.timer_outlined, "Typical Delivery", "5-7 Days"),
                  const SizedBox(height: 32),
                  const Text("Specialties", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _chip("Blouse"),
                      _chip("Kurti"),
                      _chip("Lehenga"),
                      _chip("Alterations"),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/fabric-handover', arguments: {
                  ...?userData,
                  'selectedTailorId': tailorData['_id'],
                  'selectedTailorName': shopName,
                  'selectedTailorAddress': details['address'] ?? 'Shop Address',
                  'selectedTailorCity': details['city'] ?? 'City',
                });
              },
              child: const Text("Book Now"),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _chip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
    );
  }
}
