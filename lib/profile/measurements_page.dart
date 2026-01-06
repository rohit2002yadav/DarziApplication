import 'package:flutter/material.dart';
import '../services/measurement_service.dart';

class MeasurementsPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const MeasurementsPage({super.key, required this.userData});

  @override
  State<MeasurementsPage> createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  late List<dynamic> _profiles;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _profiles = widget.userData['customerDetails']?['measurementProfiles'] ?? [];
  }

  Future<void> _deleteProfile(String id) async {
    setState(() => _isLoading = true);
    try {
      final updatedProfiles = await MeasurementService.deleteProfile(widget.userData['phone'], id);
      setState(() {
        _profiles = updatedProfiles;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile deleted!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddProfileSheet() {
    final nameController = TextEditingController();
    String selectedGarment = "Shirt";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add New Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Profile Name (e.g., My Best Fit)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedGarment,
              decoration: const InputDecoration(labelText: "Garment Type", border: OutlineInputBorder()),
              items: ["Shirt", "Pant", "Kurta", "Suit"].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) => selectedGarment = val!,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  Navigator.pop(context);
                  setState(() => _isLoading = true);
                  try {
                    final newProfile = {
                      "profileName": nameController.text,
                      "garmentType": selectedGarment,
                      "measurements": {"Length": "40", "Chest": "38"} // Placeholder default measurements
                    };
                    final updatedProfiles = await MeasurementService.addProfile(widget.userData['phone'], newProfile);
                    setState(() {
                      _profiles = updatedProfiles;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                child: const Text("Save Profile"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("My Measurements")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _profiles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.straighten, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text("No saved measurements yet.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                final profile = _profiles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      child: Icon(Icons.person, color: theme.primaryColor),
                    ),
                    title: Text(profile['profileName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(profile['garmentType']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteProfile(profile['_id']),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProfileSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
