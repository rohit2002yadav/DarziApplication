import 'package:flutter/material.dart';
import '../services/tailor_service.dart';
import 'tailor_profile_page.dart';

class TailorListPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const TailorListPage({super.key, this.userData});

  @override
  State<TailorListPage> createState() => _TailorListPageState();
}

class _TailorListPageState extends State<TailorListPage> {
  late Future<List<Map<String, dynamic>>> _tailorsFuture;

  @override
  void initState() {
    super.initState();
    _tailorsFuture = TailorService.getRegisteredTailors();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verified Tailors"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tailorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No tailors registered yet."));
          }

          final tailors = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tailors.length,
            itemBuilder: (context, index) {
              final tailor = tailors[index];
              final details = tailor['tailorDetails'] ?? {};
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      tailor['name']?[0]?.toUpperCase() ?? "T",
                      style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  title: Text(details['shopName'] ?? tailor['name'], 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(details['tailorType'] ?? "General Tailor", style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          const Text("4.5", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(details['city'] ?? "Nearby", style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.chevron_right, color: theme.primaryColor),
                  onTap: () {
                    // Navigate to profile and pass ALL collected data
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => TailorProfilePage(
                          tailorData: tailor,
                          userData: widget.userData, // Contains fabricDetails from previous step
                        )
                      )
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
