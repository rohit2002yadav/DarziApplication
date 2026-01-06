import 'package:flutter/material.dart';

class ChooseFabricPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ChooseFabricPage({super.key, this.userData});

  @override
  State<ChooseFabricPage> createState() => _ChooseFabricPageState();
}

class _ChooseFabricPageState extends State<ChooseFabricPage> {
  String _selectedOption = 'have_fabric';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Choose Fabric'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("How will you provide fabric?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Select an option to continue.", style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 32),
            _buildOption(
              title: 'I already have fabric',
              subtitle: 'Tailor will collect it from your location.',
              value: 'have_fabric',
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildOption(
              title: 'Buy fabric from app',
              subtitle: 'Browse our collection of materials.',
              value: 'buy_from_app',
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildOption(
              title: 'Let tailor provide fabric',
              subtitle: 'Tailor will suggest and provide material.',
              value: 'tailor_provides',
              theme: theme,
            ),
          ],
        ),
      ),
       bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              if (_selectedOption == 'have_fabric') {
                // Restore direct navigation to I Have Fabric page
                Navigator.pushNamed(context, '/i-have-fabric', arguments: widget.userData);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This option is coming soon!')),
                );
              }
            },
            child: const Text('Continue'),
          ),
        ),
      ),
    );
  }

  Widget _buildOption({required String title, required String subtitle, required String value, required ThemeData theme}) {
    final bool isSelected = _selectedOption == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedOption = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withValues(alpha: 0.05) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? theme.primaryColor : Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedOption,
              onChanged: (val) => setState(() => _selectedOption = val!),
              activeColor: theme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
