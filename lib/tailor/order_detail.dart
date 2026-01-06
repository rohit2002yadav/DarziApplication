import 'package:flutter/material.dart';
import '../models/order_model.dart';
import 'update_status_sheet.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Order #${order.id.length > 6 ? order.id.substring(order.id.length - 6).toUpperCase() : order.id}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.primaryColor),
                  const SizedBox(width: 12),
                  Text(
                    "Current Status: ${order.status}",
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle("Measurements (${order.garmentType ?? 'General'})"),
            if (order.measurements == null || order.measurements!.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text("No measurements provided.", style: TextStyle(color: Colors.grey))),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: order.measurements!.entries.map((entry) {
                      return _MeasurementRow(label: entry.key, value: entry.value.toString());
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            _buildSectionTitle("Fabric & Design"),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Items: ${order.items.join(', ')}"),
                    const SizedBox(height: 8),
                    const Text("Fabric Option: Self Provided"),
                    const SizedBox(height: 16),
                    const Text("Design Reference:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => UpdateStatusSheet(
                      orderId: order.id,
                      currentStatus: order.status,
                      onUpdate: () => Navigator.pop(context),
                    ),
                  );
                },
                child: const Text("Update Status"),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _MeasurementRow extends StatelessWidget {
  final String label;
  final String value;
  const _MeasurementRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 15)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}
