import 'package:flutter/material.dart';

class AddMeasurementsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const AddMeasurementsPage({super.key, this.userData});

  @override
  State<AddMeasurementsPage> createState() => _AddMeasurementsPageState();
}

class _AddMeasurementsPageState extends State<AddMeasurementsPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  String? _selectedProfileId;

  late List<dynamic> _savedProfiles;
  late String _garmentType;

  @override
  void initState() {
    super.initState();
    _garmentType = widget.userData?['garmentType'] ?? 'Shirt';
    _savedProfiles = (widget.userData?['customerDetails']?['measurementProfiles'] ?? [])
        .where((p) => p['garmentType'] == _garmentType)
        .toList();

    // Initialize controllers for manual entry
    final fields = _getFieldsForGarment(_garmentType);
    for (var field in fields) {
      _controllers[field] = TextEditingController();
    }
  }

  List<String> _getFieldsForGarment(String type) {
    if (type == "Pant") return ["Length", "Waist", "Hip", "Thigh"];
    if (type == "Kurta") return ["Length", "Chest", "Shoulder", "Sleeve"];
    return ["Length", "Chest", "Shoulder", "Sleeve"]; // Default for Shirt/Suit
  }

  void _applyProfile(Map<String, dynamic> profile) {
    setState(() {
      _selectedProfileId = profile['_id'];
      final measurements = profile['measurements'] as Map<String, dynamic>;
      measurements.forEach((key, value) {
        if (_controllers.containsKey(key)) {
          _controllers[key]!.text = value.toString();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text("$_garmentType Measurements")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_savedProfiles.isNotEmpty) ...[
                const Text("Select from Saved Profiles", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _savedProfiles.length,
                    itemBuilder: (context, index) {
                      final profile = _savedProfiles[index];
                      final isSelected = _selectedProfileId == profile['_id'];
                      return GestureDetector(
                        onTap: () => _applyProfile(profile),
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? theme.primaryColor : Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(profile['profileName'], 
                                style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87),
                                textAlign: TextAlign.center,
                              ),
                              Text("Saved Fit", style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],

              const Text("Manual Entry (inches)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ..._controllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: entry.value,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: entry.key,
                      suffixText: "in",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (val) => val!.isEmpty ? "Required" : null,
                  ),
                );
              }).toList(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final measurements = _controllers.map((key, controller) => MapEntry(key, controller.text));
                  Navigator.pushNamed(context, '/fabric-handover', arguments: {
                    ...?widget.userData,
                    'measurements': measurements,
                  });
                }
              },
              child: const Text("Next: Handover & Payment"),
            ),
          ),
        ),
      ),
    );
  }
}
