import 'package:flutter/material.dart';
import '../../services/tailor_service.dart';
import '../../models/order_model.dart';
import '../order/order_tracking_page.dart';

class CustomerHomeView extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const CustomerHomeView({super.key, this.userData});

  @override
  State<CustomerHomeView> createState() => _CustomerHomeViewState();
}

class _CustomerHomeViewState extends State<CustomerHomeView> {
  late Future<List<Order>> _ordersFuture;
  late Future<List<Map<String, dynamic>>> _nearbyTailorsFuture;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  void _refreshAll() {
    final phone = widget.userData?['phone'] ?? '';
    final location = widget.userData?['customerDetails']?['location']?['coordinates'];
    
    setState(() {
      _ordersFuture = TailorService.getCustomerOrders(phone);
      if (location != null && location.length == 2) {
        _nearbyTailorsFuture = TailorService.getRegisteredTailors(lat: location[1], lng: location[0]);
      } else {
        _nearbyTailorsFuture = TailorService.getRegisteredTailors();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String name = widget.userData?['name'] ?? 'Guest';
    final String city = widget.userData?['customerDetails']?['city'] ?? 'Pune';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshAll(),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            children: [
              _buildHeader(name, city, theme),
              const SizedBox(height: 24),
              _buildActionButtons(context, theme),
              const SizedBox(height: 32),
              _buildSection(
                title: 'Active Orders', 
                theme: theme,
                onSeeAll: () {
                  Navigator.pushNamed(context, '/order-history', arguments: widget.userData);
                }, 
                child: _buildRecentActiveOrder(theme),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Tailors Near You', 
                theme: theme, 
                onSeeAll: () => Navigator.pushNamed(context, '/tailor-list', arguments: widget.userData), 
                child: _buildNearbyTailors(theme),
              ),
              const SizedBox(height: 24),
              _buildSection(title: 'Fabric Store', theme: theme, actionText: 'Browse All', onSeeAll: () {}, child: _buildFabricStore()),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String city, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Hello, $name 👋', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.location_on, size: 14, color: theme.primaryColor),
              const SizedBox(width: 4),
              Text(city, style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500)),
            ]),
          ]),
        ),
        CircleAvatar(
          radius: 24, 
          backgroundColor: theme.primaryColor.withValues(alpha: 0.1), 
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'G', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold))
        )
      ]),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _actionItem(context, theme, Icons.checkroom, 'Choose Fabric', '/choose-fabric'),
          _actionItem(context, theme, Icons.search, 'Find Tailor', '/tailor-list'),
          _actionItem(context, theme, Icons.cut, 'Stitch Now', '/tailor-list'),
        ],
      ),
    );
  }

  Widget _actionItem(BuildContext context, ThemeData theme, IconData icon, String label, String? route) {
    return Expanded(
      child: GestureDetector(
        onTap: () => route != null ? Navigator.pushNamed(context, route, arguments: widget.userData) : null,
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(children: [
              Icon(icon, color: theme.primaryColor, size: 28),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child, required VoidCallback onSeeAll, required ThemeData theme, String actionText = 'View All'}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: onSeeAll, child: Text(actionText, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)))
          ])),
      const SizedBox(height: 8),
      child
    ]);
  }

  Widget _buildRecentActiveOrder(ThemeData theme) {
    return FutureBuilder<List<Order>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
        }
        
        final activeOrders = snapshot.data?.where((o) => 
          ["PLACED", "ACCEPTED", "CUTTING", "STITCHING", "FINISHING", "READY"].contains(o.status)).toList() ?? [];

        if (activeOrders.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text("No active orders found.", style: TextStyle(color: Colors.black38))),
          );
        }

        return _orderCard(activeOrders.first, theme);
      },
    );
  }

  Widget _orderCard(Order order, ThemeData theme) {
    int currentStep = 0;
    String statusDesc = "Waiting for tailor to accept";
    
    final status = order.status;
    
    if (status == 'ACCEPTED' || status == 'CUTTING' || status == 'STITCHING' || status == 'FINISHING') {
      currentStep = 1;
      statusDesc = status == 'ACCEPTED' 
          ? "Tailor has accepted your order" 
          : status == 'CUTTING' 
              ? "Tailor is cutting the fabric" 
              : status == 'STITCHING' 
                  ? "Your garment is being stitched" 
                  : "Final touches are being added";
    } else if (status == 'READY') {
      currentStep = 2;
      statusDesc = "Your order is ready!";
    } else if (status == 'DELIVERED') {
      currentStep = 3;
      statusDesc = "Garment delivered successfully";
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderTrackingPage(
              order: order, 
              userData: widget.userData
            )
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Order #${order.id.substring(order.id.length - 4).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              order.status, 
              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)
            ),
          ]),
          const SizedBox(height: 8),
          Text(statusDesc, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMiniStep(true, currentStep == 0, "Placed", theme),
              _buildLine(currentStep >= 1, theme),
              _buildMiniStep(currentStep >= 1, currentStep == 1, "Stitching", theme),
              _buildLine(currentStep >= 2, theme),
              _buildMiniStep(currentStep >= 2, currentStep == 2, "Ready", theme),
              _buildLine(currentStep >= 3, theme),
              _buildMiniStep(currentStep >= 3, currentStep == 3, "Delivered", theme),
            ],
          )
        ]),
      ),
    );
  }

  Widget _buildMiniStep(bool isDone, bool isActive, String label, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 14, height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.white : (isDone ? theme.primaryColor : Colors.grey[200]),
            border: Border.all(
              color: isActive ? theme.primaryColor : (isDone ? theme.primaryColor : Colors.grey[300]!),
              width: isActive ? 4 : 1
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label, 
          style: TextStyle(
            fontSize: 9, 
            color: isActive ? theme.primaryColor : (isDone ? Colors.black87 : Colors.grey), 
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal
          )
        ),
      ],
    );
  }

  Widget _buildLine(bool isDone, ThemeData theme) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: isDone ? theme.primaryColor : Colors.grey[200],
      ),
    );
  }

  Widget _buildNearbyTailors(ThemeData theme) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _nearbyTailorsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No tailors found nearby.", style: TextStyle(color: Colors.grey))));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: snapshot.data!.map((tailor) => _tailorCard(tailor, theme)).toList(),
          ),
        );
      },
    );
  }

  Widget _tailorCard(Map<String, dynamic> tailor, ThemeData theme) {
    final details = tailor['tailorDetails'] ?? {};
    final String name = tailor['name'] ?? 'Tailor';
    final String shopName = details['shopName'] ?? name;
    
    // Get distance from backend (in meters) and convert to km
    final double? distanceMeters = tailor['distance']?.toDouble();
    String distanceStr = "";
    if (distanceMeters != null) {
      if (distanceMeters < 1000) {
        distanceStr = "${distanceMeters.toStringAsFixed(0)}m away";
      } else {
        distanceStr = "${(distanceMeters / 1000).toStringAsFixed(1)}km away";
      }
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/tailor-list', arguments: widget.userData),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
            radius: 20, 
            backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'T', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(details['tailorType'] ?? "General", style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.star, color: Colors.amber, size: 14),
            const SizedBox(width: 4),
            Text("${details['rating'] ?? '4.5'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            if (distanceStr.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(distanceStr, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ]
          ])
        ]),
      ),
    );
  }

  Widget _buildFabricStore() {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ['Cotton', 'Silk', 'Linen', 'Velvet'].map((f) => _fabricChip(f)).toList(),
      ),
    );
  }

  Widget _fabricChip(String name) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.shade200)),
      child: Center(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500))),
    );
  }
}
