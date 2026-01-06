import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class IHaveFabricPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const IHaveFabricPage({super.key, this.userData});

  @override
  State<IHaveFabricPage> createState() => _IHaveFabricPageState();
}

class _IHaveFabricPageState extends State<IHaveFabricPage> {
  final _formKey = GlobalKey<FormState>();
  final _lengthController = TextEditingController(text: '2.5');
  String? _selectedFabricType;
  String? _selectedFabricColor;
  XFile? _imageXFile;

  final Map<String, Color> _fabricColors = {
    "Red": Colors.red, "Orange": Colors.orange, "Yellow": Colors.yellow,
    "Green": Colors.green, "Blue": Colors.blue, "Purple": Colors.purple,
    "Pink": Colors.pink, "Brown": Colors.brown, "Black": Colors.black,
    "White": Colors.white, "Gray": Colors.grey, "Cream": const Color(0xFFFFFDD0),
    "Navy": const Color(0xFF000080), "Teal": Colors.teal,
  };

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imageXFile = image);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Fabric Details')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text("Enter your fabric details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("This helps the tailor prepare for your order.", style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 32),
            
            _buildPhotoUpload(theme),
            const SizedBox(height: 32),
            
            _buildDropdown(
              'Fabric Type',
              _selectedFabricType,
              ["Cotton", "Silk", "Linen", "Rayon", "Khadi", "Velvet", "Denim", "Satin"],
              (val) => setState(() => _selectedFabricType = val),
              'Select a fabric type',
            ),
            const SizedBox(height: 24),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fabric Length', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lengthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    suffixText: "pieces",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildColorDropdown(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate() && _selectedFabricType != null && _selectedFabricColor != null) {
                // Pass collected fabric data to the Tailor List step
                Navigator.pushNamed(context, '/tailor-list', arguments: {
                  ...?widget.userData,
                  'fabricDetails': {
                    'type': _selectedFabricType,
                    'length': _lengthController.text,
                    'color': _selectedFabricColor,
                    'photoPath': _imageXFile?.path,
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please complete all details")));
              }
            },
            child: const Text('Find Nearby Tailors'),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUpload(ThemeData theme) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 160, width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: _imageXFile != null
            ? ClipRRect(borderRadius: BorderRadius.circular(16), child: kIsWeb ? Image.network(_imageXFile!.path, fit: BoxFit.cover) : Image.file(File(_imageXFile!.path), fit: BoxFit.cover))
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt_outlined, size: 48, color: theme.primaryColor.withValues(alpha: 0.5)), const SizedBox(height: 12), const Text('Upload fabric photo (Optional)', style: TextStyle(color: Colors.black54))]),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: value, hint: Text(hint),
        items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300))),
      ),
    ]);
  }

  Widget _buildColorDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Fabric Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _selectedFabricColor, hint: const Text('Select a color'),
        items: _fabricColors.entries.map((e) => DropdownMenuItem(value: e.key, child: Row(children: [_colorSwatch(e.value), const SizedBox(width: 12), Text(e.key)]))).toList(),
        onChanged: (val) => setState(() => _selectedFabricColor = val),
        decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300))),
      ),
    ]);
  }

  Widget _colorSwatch(Color color) => Container(width: 20, height: 20, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)));
}
