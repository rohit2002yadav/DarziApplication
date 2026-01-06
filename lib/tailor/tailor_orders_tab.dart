import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/tailor_service.dart';
import 'order_detail.dart';

class TailorOrdersTab extends StatefulWidget {
  final String status;
  const TailorOrdersTab({super.key, required this.status});

  @override
  State<TailorOrdersTab> createState() => _TailorOrdersTabState();
}

class _TailorOrdersTabState extends State<TailorOrdersTab> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = TailorService.getOrders(widget.status);
    });
  }

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'ACCEPTED': return 'CUTTING';
      case 'CUTTING': return 'STITCHING';
      case 'STITCHING': return 'FINISHING';
      case 'FINISHING': return 'READY';
      case 'READY': return 'DELIVERED';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNewTab = widget.status == "PLACED";
    final isOngoingTab = widget.status == "ONGOING";

    return RefreshIndicator(
      onRefresh: () async => _refreshOrders(),
      child: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("No orders in ${widget.status.toLowerCase()}", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final nextStatus = _getNextStatus(order.status);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderDetailScreen(order: order)),
                    ).then((_) => _refreshOrders());
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text("₹${order.totalAmount}", style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.checkroom, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(order.items.join(", "), style: const TextStyle(color: Colors.black87)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.watch_later_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text("Pickup: ${order.pickupDate ?? 'TBD'}, ${order.pickupTime ?? ''}", style: const TextStyle(color: Colors.black54, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (isNewTab) 
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _handleAction(TailorService.rejectOrder(order.id)),
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                                  child: const Text("Reject"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _handleAction(TailorService.acceptOrder(order.id)),
                                  child: const Text("Accept"),
                                ),
                              ),
                            ],
                          )
                        else if (isOngoingTab && nextStatus.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _handleAction(
                                TailorService.updateStatus(order.id),
                              ),

                              child: Text("Mark as $nextStatus"),
                            ),
                          )
                        else if (order.status == 'DELIVERED')
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                              SizedBox(width: 8),
                              Text("Delivered", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleAction(Future<void> action) async {
    try {
      await action;
      _refreshOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}
