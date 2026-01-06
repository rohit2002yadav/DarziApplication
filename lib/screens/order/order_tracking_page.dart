import 'package:flutter/material.dart';
import '../../models/order_model.dart';

class OrderTrackingPage extends StatelessWidget {
  final Order order;
  final Map<String, dynamic>? userData;
  const OrderTrackingPage({super.key, required this.order, this.userData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define workflow steps exactly as defined in the background system
    final List<Map<String, dynamic>> steps = [
      {"status": "PLACED", "label": "Order Placed", "desc": "Waiting for tailor to accept"},
      {"status": "ACCEPTED", "label": "Order Accepted", "desc": "Tailor has confirmed your order"},
      {"status": "CUTTING", "label": "Fabric Cutting", "desc": "Tailor is preparing the fabric"},
      {"status": "STITCHING", "label": "Stitching", "desc": "Your garment is being stitched"},
      {"status": "FINISHING", "label": "Final Finishing", "desc": "Adding final touches"},
      {"status": "READY", "label": "Ready for Pickup", "desc": "Your garment is ready!"},
      {"status": "DELIVERED", "label": "Delivered", "desc": "Order completed successfully"},
    ];

    int currentStepIndex = steps.indexWhere((s) => s['status'] == order.status);
    if (currentStepIndex == -1) currentStepIndex = 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Order Confirmation"),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false, arguments: userData);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSuccessHeader(),
            const SizedBox(height: 24),
            _buildSummaryCard(theme),
            const SizedBox(height: 32),
            const Text("Track Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTimeline(steps, currentStepIndex, theme),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false, arguments: userData);
                },
                child: const Text("Back to Dashboard", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Row(
      children: [
        const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.check_circle, color: Colors.green)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Order Confirmed 🎉", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Order #${order.id.length > 4 ? order.id.substring(order.id.length - 4).toUpperCase() : order.id}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _summaryRow(Icons.checkroom_rounded, "Garment", order.garmentType ?? "Custom Wear", theme),
            const Divider(height: 32),
            _summaryRow(Icons.handyman_rounded, "Handover", order.pickupAddress == "Drop at Shop" ? "Drop at Shop" : "Pickup from Home", theme),
            const Divider(height: 32),
            _summaryRow(Icons.calendar_month_rounded, "Schedule", "${order.pickupDate ?? 'TBD'}, ${order.pickupTime ?? ''}", theme),
            const Divider(height: 32),
            _summaryRow(Icons.straighten_rounded, "Measurements", "Taken by Tailor", theme),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline(List<Map<String, dynamic>> steps, int currentStepIndex, ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final isCompleted = index < currentStepIndex;
        final isActive = index == currentStepIndex;
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted || isActive ? theme.primaryColor : Colors.grey.shade200,
                    ),
                    child: isCompleted 
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : isActive 
                        ? Container(margin: const EdgeInsets.all(5), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))
                        : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 2, color: isCompleted ? theme.primaryColor : Colors.grey.shade200),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[index]['label'], 
                      style: TextStyle(
                        fontSize: 15, 
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w600, 
                        color: isActive ? theme.primaryColor : isCompleted ? Colors.black87 : Colors.grey
                      )
                    ),
                    Text(
                      steps[index]['desc'], 
                      style: TextStyle(fontSize: 12, color: isActive ? Colors.black54 : Colors.grey)
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
