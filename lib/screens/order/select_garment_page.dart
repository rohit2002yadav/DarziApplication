import 'package:flutter/material.dart';

class SelectGarmentPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const SelectGarmentPage({super.key, this.userData});

  @override
  State<SelectGarmentPage> createState() => _SelectGarmentPageState();
}

class _SelectGarmentPageState extends State<SelectGarmentPage> {
  final List<Map<String, dynamic>> _garments = [
    {"name": "Shirt", "icon": Icons.checkroom, "price": 400},
    {"name": "Pant", "icon": Icons.shortcut, "price": 500},
    {"name": "Kurta", "icon": Icons.accessibility_new, "price": 600},
    {"name": "Suit", "icon": Icons.business_center, "price": 2500},
  ];

  String? _selectedGarment;
  int _basePrice = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Select Garment")),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: _garments.length,
              itemBuilder: (context, index) {
                final garment = _garments[index];
                final isSelected = _selectedGarment == garment['name'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGarment = garment['name'];
                      _basePrice = garment['price'];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? theme.primaryColor : Colors.grey.shade200,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? theme.primaryColor.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          garment['icon'],
                          size: 40,
                          color: isSelected ? Colors.white : theme.primaryColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          garment['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Starts at ₹${garment['price']}",
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedGarment == null
                      ? null
                      : () {
                          Navigator.pushNamed(context, '/add-measurements', arguments: {
                            ...?widget.userData,
                            'garmentType': _selectedGarment,
                            'basePrice': _basePrice,
                          });
                        },
                  child: const Text("Next: Measurements"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
