import 'package:flutter/material.dart';
import '../../services/tailor_service.dart';
import '../../models/order_model.dart';
import '../order/order_tracking_page.dart';

class OrderHistoryPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const OrderHistoryPage({super.key, this.userData});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  void _refreshOrders() {
    final phone = widget.userData?['phone'] ?? '';
    setState(() {
      _ordersFuture = TailorService.getCustomerOrders(phone);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("My Orders"),
          bottom: const TabBar(
            isScrollable: false,
            tabs: [
              Tab(text: "Active"),
              Tab(text: "Completed"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: FutureBuilder<List<Order>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text("No orders found.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            final allOrders = snapshot.data!;
            
            // STATUS -> TAB MAPPING
            final activeOrders = allOrders.where((o) => 
              ["PLACED", "ACCEPTED", "CUTTING", "STITCHING", "FINISHING", "READY"].contains(o.status)).toList();
            final completedOrders = allOrders.where((o) => o.status == 'DELIVERED').toList();
            final cancelledOrders = allOrders.where((o) => ["REJECTED", "CANCELLED"].contains(o.status)).toList();

            return TabBarView(
              children: [
                _buildActiveList(activeOrders),
                _buildCompletedList(completedOrders),
                _buildCancelledList(cancelledOrders),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveList(List<Order> orders) {
    if (orders.isEmpty) return const _EmptyState(msg: "No active orders");
    return RefreshIndicator(
      onRefresh: () async => _refreshOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => _ActiveOrderCard(order: orders[index], userData: widget.userData),
      ),
    );
  }

  Widget _buildCompletedList(List<Order> orders) {
    if (orders.isEmpty) return const _EmptyState(msg: "No completed orders");
    return RefreshIndicator(
      onRefresh: () async => _refreshOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => _CompletedOrderCard(order: orders[index]),
      ),
    );
  }

  Widget _buildCancelledList(List<Order> orders) {
    if (orders.isEmpty) return const _EmptyState(msg: "No cancelled orders");
    return RefreshIndicator(
      onRefresh: () async => _refreshOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => _CancelledOrderCard(order: orders[index]),
      ),
    );
  }
}

// --- CARD WIDGETS ---

class _ActiveOrderCard extends StatelessWidget {
  final Order order;
  final Map<String, dynamic>? userData;
  const _ActiveOrderCard({required this.order, this.userData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int currentStep = 0;
    if (["ACCEPTED", "CUTTING", "STITCHING", "FINISHING"].contains(order.status)) currentStep = 1;
    if (order.status == 'READY') currentStep = 2;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #${order.id.substring(order.id.length - 4).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(order.status, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Text("Tailor: Registered Tailor", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            Text("Garment: ${order.items.join(', ')}", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            // Milestone Stepper
            Row(
              children: [
                _miniStep(true, currentStep == 0, "Placed", theme),
                _line(currentStep >= 1, theme),
                _miniStep(currentStep >= 1, currentStep == 1, "Stitching", theme),
                _line(currentStep >= 2, theme),
                _miniStep(currentStep >= 2, currentStep == 2, "Ready", theme),
                _line(false, theme),
                _miniStep(false, false, "Delivered", theme),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingPage(order: order, userData: userData)));
                },
                child: const Text("Track Order"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStep(bool done, bool active, String label, ThemeData theme) {
    return Column(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? Colors.white : (done ? theme.primaryColor : Colors.grey[200]), border: active ? Border.all(color: theme.primaryColor, width: 3) : null)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 8, color: done || active ? Colors.black87 : Colors.grey)),
    ]);
  }

  Widget _line(bool done, ThemeData theme) => Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 12), color: done ? theme.primaryColor : Colors.grey[200]));
}

class _CompletedOrderCard extends StatelessWidget {
  final Order order;
  const _CompletedOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #${order.id.substring(order.id.length - 4).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text("DELIVERED", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text("Garment: ${order.items.join(', ')}"),
            Text("Delivered on: ${order.updatedAt?.day ?? ''} ${_getMonth(order.updatedAt?.month ?? 1)}", style: const TextStyle(color: Colors.grey)),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () {}, child: const Text("Rate Tailor"))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () {}, child: const Text("Reorder"))),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _CancelledOrderCard extends StatelessWidget {
  final Order order;
  const _CancelledOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #${order.id.substring(order.id.length - 4).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(order.status, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            const Text("Reason: Tailor unavailable", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {}, 
                child: const Text("Find Another Tailor")
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String msg;
  const _EmptyState({required this.msg});
  @override
  Widget build(BuildContext context) => Center(child: Text(msg, style: const TextStyle(color: Colors.grey)));
}

String _getMonth(int m) => ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][m-1];
